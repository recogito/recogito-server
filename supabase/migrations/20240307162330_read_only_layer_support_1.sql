create type "public"."context_role_type" as enum ('admin', 'default');

drop policy "Users with correct policies can DELETE on contexts" on "public"."contexts";

drop policy "Users with correct policies can INSERT on contexts" on "public"."contexts";

drop policy "Users with correct policies can SELECT on contexts" on "public"."contexts";

drop policy "Users with correct policies can UPDATE on contexts" on "public"."contexts";

drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

drop policy "Users with correct policies can DELETE on group_users" on "public"."group_users";

drop policy "Users with correct policies can INSERT on group_users" on "public"."group_users";

drop policy "Users with correct policies can SELECT on group_users" on "public"."group_users";

drop policy "Users with correct policies can UPDATE on group_users" on "public"."group_users";

drop function if exists "public"."check_action_policy_layer_from_context"(user_id uuid, table_name character varying, operation operation_types, context_id uuid);

drop function if exists "public"."check_action_policy_layer_from_document"(user_id uuid, table_name character varying, operation operation_types, document_id uuid);

drop function if exists "public"."check_action_policy_layer_from_group_user"(user_id uuid, table_name character varying, operation operation_types, group_type group_types, type_id uuid);

create table "public"."context_documents" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "context_id" uuid,
    "document_id" uuid,
    "is_archived" boolean default false
);


alter table "public"."context_documents" enable row level security;

create table "public"."context_users" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "context_id" uuid,
    "user_id" uuid,
    "role_id" uuid
);


alter table "public"."context_users" enable row level security;

alter table "public"."layer_contexts" add column "is_active_layer" boolean default false;

CREATE UNIQUE INDEX context_documents_context_id_document_id_key ON public.context_documents USING btree (context_id, document_id);

CREATE UNIQUE INDEX context_documents_pkey ON public.context_documents USING btree (id);

CREATE UNIQUE INDEX context_users_context_id_user_id_key ON public.context_users USING btree (context_id, user_id);

CREATE UNIQUE INDEX context_users_pkey ON public.context_users USING btree (id);

alter table "public"."context_documents" add constraint "context_documents_pkey" PRIMARY KEY using index "context_documents_pkey";

alter table "public"."context_users" add constraint "context_users_pkey" PRIMARY KEY using index "context_users_pkey";

alter table "public"."context_documents" add constraint "context_documents_context_id_document_id_key" UNIQUE using index "context_documents_context_id_document_id_key";

alter table "public"."context_documents" add constraint "context_documents_context_id_fkey" FOREIGN KEY (context_id) REFERENCES contexts(id) not valid;

alter table "public"."context_documents" validate constraint "context_documents_context_id_fkey";

alter table "public"."context_documents" add constraint "context_documents_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."context_documents" validate constraint "context_documents_created_by_fkey";

alter table "public"."context_documents" add constraint "context_documents_document_id_fkey" FOREIGN KEY (document_id) REFERENCES documents(id) not valid;

alter table "public"."context_documents" validate constraint "context_documents_document_id_fkey";

alter table "public"."context_documents" add constraint "context_documents_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."context_documents" validate constraint "context_documents_updated_by_fkey";

alter table "public"."context_users" add constraint "context_users_context_id_fkey" FOREIGN KEY (context_id) REFERENCES contexts(id) not valid;

alter table "public"."context_users" validate constraint "context_users_context_id_fkey";

alter table "public"."context_users" add constraint "context_users_context_id_user_id_key" UNIQUE using index "context_users_context_id_user_id_key";

alter table "public"."context_users" add constraint "context_users_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."context_users" validate constraint "context_users_created_by_fkey";

alter table "public"."context_users" add constraint "context_users_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) not valid;

alter table "public"."context_users" validate constraint "context_users_role_id_fkey";

alter table "public"."context_users" add constraint "context_users_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."context_users" validate constraint "context_users_updated_by_fkey";

alter table "public"."context_users" add constraint "context_users_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) not valid;

alter table "public"."context_users" validate constraint "context_users_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_document_to_context_rpc(_context_id uuid, _document_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _layer_id uuid;
BEGIN
    -- Find the project for this context  
    SELECT id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Didn't find the project for this context
    IF NOT FOUND THEN
        RAISE EXCEPTION 'project not found for context % ', _context_id;
    END IF;

    -- Check project policy that contexts can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF;  

    -- Add a context_document record
    INSERT INTO public.context_documents
            (created_by, created_at, context_id, document_id)
        VALUES (auth.uid(), NOW(), _context_id, _document_id);

    -- Add a layer for this document
    _layer_id = extensions.uuid_generate_v4();
    INSERT INTO public.layers
            (id, created_by, created_at, document_id, project_id)
        VALUES (_layer_id, auth.uid(), NOW(), _document_id, _project_id);

    -- Add a layer context
    INSERT INTO public.layer_contexts
            (created_by, created_at, layer_id, context_id, is_active_layer)
        VALUES (auth.uid(), NOW(), _layer_id, _context_id, TRUE);

    RETURN TRUE;
END
$function$
;

create type "public"."add_user_type" as ("user_id" uuid, "role" context_role_type);

CREATE OR REPLACE FUNCTION public.add_users_to_context_rpc(_context_id uuid, _users add_user_type[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _user add_user_type;
    _admin_role_id uuid;
    _default_role_id uuid;
    _role_id uuid;
BEGIN
    -- Find the project for this context  
    SELECT id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Didn't find the project for this context
    IF NOT FOUND THEN
        RAISE EXCEPTION 'project not found for context % ', _context_id;
    END IF;

    -- Check project policy that contexts can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF;  

    -- Get the role ids
    SELECT id INTO _admin_role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_admin = TRUE;
    SELECT id INTO _default_role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_default = TRUE;

    -- Add the users to the context_users table
    FOREACH _user IN ARRAY _users 
    LOOP
      _role_id = NULL;
      IF _user.role = 'admin' THEN
        _role_id = _admin_role_id;
        ELSE IF _user.role = 'default' THEN
          _role_id = _default_role_id;
        END IF;
      END IF;

      IF _role_id IS NOT NULL THEN
        INSERT INTO public.context_users
              (context_id, user_id, role_id) 
          VALUES(_context_id, _user.user_id, _role_id);
      END IF;
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.create_context_rpc(_project_id uuid, _name character varying, _description character varying)
 RETURNS SETOF contexts
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _context_id uuid;
BEGIN
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'INSERT', _project_id) THEN
        RETURN;
    END IF;    

    _context_id = extensions.uuid_generate_v4();

    INSERT INTO public.contexts (id, created_by, created_at, _project_id) VALUES (_context_id, auth.uid(), NOW(), _project_id);
    
    RETURN QUERY SELECT * FROM public.contexts WHERE id = _context_id;
END
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer(user_id uuid, table_name character varying, operation operation_types, layer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = $4 AND lc.is_active_layer IS TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_ud = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

grant delete on table "public"."context_documents" to "anon";

grant insert on table "public"."context_documents" to "anon";

grant references on table "public"."context_documents" to "anon";

grant select on table "public"."context_documents" to "anon";

grant trigger on table "public"."context_documents" to "anon";

grant truncate on table "public"."context_documents" to "anon";

grant update on table "public"."context_documents" to "anon";

grant delete on table "public"."context_documents" to "authenticated";

grant insert on table "public"."context_documents" to "authenticated";

grant references on table "public"."context_documents" to "authenticated";

grant select on table "public"."context_documents" to "authenticated";

grant trigger on table "public"."context_documents" to "authenticated";

grant truncate on table "public"."context_documents" to "authenticated";

grant update on table "public"."context_documents" to "authenticated";

grant delete on table "public"."context_documents" to "service_role";

grant insert on table "public"."context_documents" to "service_role";

grant references on table "public"."context_documents" to "service_role";

grant select on table "public"."context_documents" to "service_role";

grant trigger on table "public"."context_documents" to "service_role";

grant truncate on table "public"."context_documents" to "service_role";

grant update on table "public"."context_documents" to "service_role";

grant delete on table "public"."context_users" to "anon";

grant insert on table "public"."context_users" to "anon";

grant references on table "public"."context_users" to "anon";

grant select on table "public"."context_users" to "anon";

grant trigger on table "public"."context_users" to "anon";

grant truncate on table "public"."context_users" to "anon";

grant update on table "public"."context_users" to "anon";

grant delete on table "public"."context_users" to "authenticated";

grant insert on table "public"."context_users" to "authenticated";

grant references on table "public"."context_users" to "authenticated";

grant select on table "public"."context_users" to "authenticated";

grant trigger on table "public"."context_users" to "authenticated";

grant truncate on table "public"."context_users" to "authenticated";

grant update on table "public"."context_users" to "authenticated";

grant delete on table "public"."context_users" to "service_role";

grant insert on table "public"."context_users" to "service_role";

grant references on table "public"."context_users" to "service_role";

grant select on table "public"."context_users" to "service_role";

grant trigger on table "public"."context_users" to "service_role";

grant truncate on table "public"."context_users" to "service_role";

grant update on table "public"."context_users" to "service_role";

create policy "Enable ALL access for authenticated users"
on "public"."context_documents"
as permissive
for all
to authenticated
using (true)
with check (true);


create policy "Enable ALL access for Authenticated users"
on "public"."context_users"
as permissive
for all
to authenticated
using (true)
with check (true);


create policy "Users with correct policies can DELETE on contexts"
on "public"."contexts"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'DELETE'::operation_types, project_id)));


create policy "Users with correct policies can INSERT on contexts"
on "public"."contexts"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'INSERT'::operation_types, project_id)));


create policy "Users with correct policies can SELECT on contexts"
on "public"."contexts"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types, project_id))));


create policy "Users with correct policies can UPDATE on contexts"
on "public"."contexts"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types, project_id)))
with check ((check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types, project_id)));


create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND ((collection_id IS NULL) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on documents"
on "public"."documents"
as permissive
for insert
to authenticated
with check (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND ((collection_id IS NULL) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can SELECT on documents"
on "public"."documents"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND ((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can UPDATE on documents"
on "public"."documents"
as permissive
for update
to authenticated
using (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR (((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id))))
with check (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND ((collection_id IS NULL) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR (((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id))));


create policy "Users with correct policies can DELETE on group_users"
on "public"."group_users"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'group_users'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'DELETE'::operation_types, group_type, type_id)));


create policy "Users with correct policies can INSERT on group_users"
on "public"."group_users"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'group_users'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'INSERT'::operation_types, group_type, type_id)));


create policy "Users with correct policies can SELECT on group_users"
on "public"."group_users"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'group_users'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'SELECT'::operation_types, group_type, type_id))));


create policy "Users with correct policies can UPDATE on group_users"
on "public"."group_users"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id)))
with check ((check_action_policy_organization(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id)));



