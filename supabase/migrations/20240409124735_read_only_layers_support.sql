create type "public"."context_role_type" as enum ('admin', 'default');

drop policy "Users with correct policies can SELECT on annotations" on "public"."annotations";

drop policy "Users with correct policies can SELECT on bodies" on "public"."bodies";

drop policy "Users with correct policies can SELECT on contexts" on "public"."contexts";

drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

drop policy "Users with correct policies can DELETE on group_users" on "public"."group_users";

drop policy "Users with correct policies can INSERT on group_users" on "public"."group_users";

drop policy "Users with correct policies can SELECT on group_users" on "public"."group_users";

drop policy "Users with correct policies can UPDATE on group_users" on "public"."group_users";

drop policy "Users with correct policies can SELECT on layers" on "public"."layers";

drop policy "Users with correct policies can SELECT on targets" on "public"."targets";

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

CREATE OR REPLACE FUNCTION public.add_documents_to_context_rpc(_context_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
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

    -- Iterate through the document ids
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
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
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.add_documents_to_project_rpc(_project_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _context_id uuid;
    _layer_id uuid;
    _document_id uuid;
BEGIN
    -- Check project policy that project documents can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF; 

    -- Find the default context for this project  
    SELECT c.id INTO _context_id FROM public.contexts c 
      WHERE c.project_id = _project_id AND c.is_project_default IS TRUE;

    -- Didn't find the default context for this project
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Default context not found for project % ', _project_id;
    END IF; 

    -- Iterate through the document ids and add to project_documents and context_documents for the default context
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Add the document to project_documents
        INSERT INTO public.project_documents 
            (created_by, created_at, project_id, document_id)
            VALUES (auth.uid(), NOW(), _project_id, _document_id);
        
        -- Add a context_document record to the default context
        INSERT INTO public.context_documents
            (created_by, created_at, context_id, document_id)
            VALUES (auth.uid(), NOW(), _context_id, _document_id);

        -- Add the default layer
        _layer_id = uuid_generate_v4();

        INSERT INTO public.layers 
            (id, document_id, project_id)
            VALUES (_layer_id, _document_id, _project_id);

        -- Add the layer_context
        INSERT INTO public.layer_contexts
            (layer_id, context_id, is_active_layer)
            VALUES (_layer_id, _context_id, TRUE);
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.add_read_only_layers_rpc(_context_id uuid, _layer_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id       uuid;
    _layer_id         uuid;
    _layer_project_id public.layers %rowtype;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
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

    -- Iterate through the layer ids
    FOREACH _layer_id IN ARRAY _layer_ids 
    LOOP
        -- Should only add layers which belong to the current project
        SELECT l.project_id INTO _layer_project_id FROM public.layers l 
          WHERE l.id = _layer_id AND l.project_id = _project_id;

        -- Didn't find this layer in this project
        IF NOT FOUND THEN
            RAISE EXCEPTION 'layer % not found for project % ', _layer_id, _project_id;
        END IF;          

        -- Add a layer context and add them as the non-active layer
        INSERT INTO public.layer_contexts
                (created_by, created_at, layer_id, context_id, is_active_layer)
            VALUES (auth.uid(), NOW(), _layer_id, _context_id, FALSE);
    END LOOP;

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
    SELECT p.id INTO _project_id FROM public.projects p 
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
    SELECT g.role_id INTO _admin_role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_admin = TRUE;
    SELECT g.role_id INTO _default_role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_default = TRUE;

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

CREATE OR REPLACE FUNCTION public.archive_context_documents_rpc(_context_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check project policy that context documents can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'context_documents', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids and archive them in project_documents and all context_documents
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Archive the context_documents record
        UPDATE public.context_document cd 
          SET is_archived = TRUE 
          WHERE cd.document_id = _document_id AND cd.context_id = _context_id;
        
        -- Archive any related layers
        FOR _row IN SELECT * FROM public.layers l 
          INNER JOIN public.layer_contexts lc ON lc.context_id = _context_id
          WHERE l.document_id = _document_id
        LOOP 
          UPDATE public.layers 
            SET is_archived = TRUE 
            WHERE id = _row.id;

          UPDATE public.layer_contexts lc
            SET is_archived = TRUE
            WHERE lc.context_id = _context_id AND lc.layer_id = _row.id;
        END LOOP;
          
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.archive_context_documents_rpc(_project_id uuid, _context_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
BEGIN
    -- Check project policy that context documents can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'context_documents', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids and archive them in project_documents and all context_documents
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Archive the context_documents record
        UPDATE public.context_document cd 
          SET is_archived = TRUE 
          WHERE cd.document_id = _document_id AND cd.context_id = _context_id;
        
        -- Archive any related layers
        FOR _row IN SELECT * FROM public.layers l 
          INNER JOIN public.layer_contexts lc ON lc.context_id = _context_id
          WHERE l.document_id = _document_id
        LOOP 
          UPDATE public.layers 
            SET is_archived = TRUE 
            WHERE id = _row.id;

          UPDATE public.layer_contexts lc
            SET is_archived = TRUE
            WHERE lc.context_id = _context_id AND lc.layer_id = _row.id;
        END LOOP;
          
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.archive_context_rpc(_context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
    _row_2 RECORD;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check project policy that context documents can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
        RAISE LOG 'Check action policy failed for project %', _project_id;
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids in this context and archive them in all context_documents
    FOR _row IN SELECT * FROM public.context_documents cd WHERE cd.context_id = _context_id 
    LOOP
        -- Archive the context_documents record
        UPDATE public.context_documents cd 
          SET is_archived = TRUE 
          WHERE cd.id = _row.id;
        
        -- Archive any related layers
        FOR _row_2 IN SELECT * FROM public.layers l 
          INNER JOIN public.layer_contexts lc ON lc.context_id = _context_id
          WHERE l.document_id = _row.document_id
        LOOP 
          UPDATE public.layers 
            SET is_archived = TRUE 
            WHERE id = _row_2.id;

          UPDATE public.layer_contexts lc
            SET is_archived = TRUE
            WHERE lc.context_id = _context_id AND lc.layer_id = _row_2.id;
        END LOOP;
          
    END LOOP;

    UPDATE public.contexts 
      SET is_archived = TRUE 
      WHERE id = _context_id;
    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.archive_project_documents_rpc(_project_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _context_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
BEGIN
    -- Check project policy that project documents can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids and archive them in project_documents and all context_documents
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Archive the project_documents record
        UPDATE public.project_documents pd 
          SET is_archived = TRUE 
          WHERE pd.document_id = _document_id AND pd.project_id = _project_id;
        
        -- Archive the document in all contexts that contain it
        FOR _row IN SELECT * FROM public.contexts c WHERE c.project_id = _project_id
        LOOP 
          UPDATE public.context_documents 
            SET is_archived = TRUE 
            WHERE document_id = _document_id;
        END LOOP;
          
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_context(user_id uuid, table_name character varying, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.context_users cu ON cu.context_id = $3 AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = 'SELECT');
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_context_select(user_id uuid, table_name character varying, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.context_users cu ON cu.context_id = $3 AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = 'SELECT');
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_document(user_id uuid, table_name character varying, document_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layers l ON l.document_id = $3
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = l.id
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = 'SELECT');

    RETURN _exists;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_select(user_id uuid, table_name character varying, layer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

        FROM public.profiles pr
                  INNER JOIN public.layer_contexts lc ON lc.layer_id = $3
                  INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                  INNER JOIN public.roles r ON cu.role_id = r.id
                  INNER JOIN public.role_policies rp ON r.id = rp.role_id
                  INNER JOIN public.policies p ON rp.policy_id = p.id
        
        WHERE p.table_name = $2
          AND p.operation = 'SELECT');
END;
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

    INSERT INTO public.contexts 
        (id, created_by, created_at, name, description, project_id) 
        VALUES (_context_id, auth.uid(), NOW(), _name, _description, _project_id);
    
    RETURN QUERY SELECT * FROM public.contexts WHERE id = _context_id;
END
$function$
;

CREATE OR REPLACE FUNCTION public.remove_users_from_context_rpc(_context_id uuid, _user_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _user uuid;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
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

    -- Remove the users from the context_users table
    FOREACH _user IN ARRAY _user_ids 
    LOOP
      DELETE FROM public.context_users WHERE context_id = _context_id AND user_id = _user;
    END LOOP;

    RETURN TRUE;
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
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = $4 AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id
                  
                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_context(user_id uuid, table_name character varying, operation operation_types, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_context lc ON lc.context_id = $4 AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_document(user_id uuid, table_name character varying, operation operation_types, document_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layers l ON l.document_id = $4
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = l.id AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);

    RETURN _exists;
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

create policy "Users with correct policies can DELETE on context_documents"
on "public"."context_documents"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'context_documents'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'context_documents'::character varying, 'DELETE'::operation_types, context_id) OR check_action_policy_layer_from_context(auth.uid(), 'context_documents'::character varying, 'DELETE'::operation_types, context_id)));


create policy "Users with correct policies can INSERT on context_documents"
on "public"."context_documents"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'context_documents'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'context_documents'::character varying, 'INSERT'::operation_types, context_id) OR check_action_policy_layer_from_context(auth.uid(), 'context_documents'::character varying, 'INSERT'::operation_types, context_id)));


create policy "Users with correct policies can SELECT on context_documents"
on "public"."context_documents"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'context_documents'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'context_documents'::character varying, 'SELECT'::operation_types, context_id) OR check_action_policy_layer_from_context_select(auth.uid(), 'context_documents'::character varying, context_id))));


create policy "Users with correct policies can UPDATE on context_documents"
on "public"."context_documents"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'context_documents'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'context_documents'::character varying, 'UPDATE'::operation_types, context_id) OR check_action_policy_layer_from_context(auth.uid(), 'context_documents'::character varying, 'UPDATE'::operation_types, context_id)))
with check ((check_action_policy_organization(auth.uid(), 'context_documents'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'context_documents'::character varying, 'UPDATE'::operation_types, context_id) OR check_action_policy_layer_from_context(auth.uid(), 'context_documents'::character varying, 'UPDATE'::operation_types, context_id)));


create policy "Enable ALL access for Authenticated users"
on "public"."context_users"
as permissive
for all
to authenticated
using (true)
with check (true);


create policy "Users with correct policies can SELECT on annotations"
on "public"."annotations"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer_select(auth.uid(), 'annotations'::character varying, layer_id))));


create policy "Users with correct policies can SELECT on bodies"
on "public"."bodies"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer_select(auth.uid(), 'bodies'::character varying, layer_id))));


create policy "Users with correct policies can SELECT on contexts"
on "public"."contexts"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types, project_id) OR check_action_policy_layer_from_context_select(auth.uid(), 'contexts'::character varying, id))));


create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND ((collection_id IS NULL) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id)));


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


create policy "Users with correct policies can SELECT on layers"
on "public"."layers"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types, project_id) OR check_action_policy_layer_select(auth.uid(), 'layers'::character varying, id))));


create policy "Users with correct policies can SELECT on targets"
on "public"."targets"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer_select(auth.uid(), 'targets'::character varying, layer_id)))));

DO $$
DECLARE
  _t_row_group public.group_users % rowtype;
  _t_row_layer public.layers % rowtype;
  _context_id uuid;
  _default_layer_role_id uuid;
  _layer_group_id uuid;
BEGIN
  -- This is the migration to support moving from layer_groups to context_users 
  FOR _t_row_layer IN SELECT * FROM public.layers l WHERE l.is_archived IS FALSE 
  LOOP
    -- Get the context id.  At this point there should only be one per layer
    SELECT lc.context_id INTO _context_id FROM public.layer_contexts lc WHERE lc.layer_id = _t_row_layer.id;

    -- Make this the active layer context
    UPDATE public.layer_contexts SET is_active_layer = TRUE WHERE context_id = _context_id;

    -- Create the context_documents entry
    INSERT INTO public.context_documents (context_id, document_id) VALUES (_context_id, _t_row_layer.document_id) ON CONFLICT DO NOTHING;
 
    -- Now create the context_user entry
    -- At this point there should only be the default layer groups with users
    SELECT dg.role_id INTO _default_layer_role_id 
      FROM public.default_groups dg 
      WHERE dg.group_type = 'layer' AND dg.is_default IS TRUE;

    -- Get the layer_group id
    SELECT lg.id INTO _layer_group_id 
      FROM public.layer_groups lg 
      WHERE lg.layer_id = _t_row_layer.id AND lg.role_id = _default_layer_role_id;

    -- For each member of the group add them to the context_users table if they do not already exist
    FOR _t_row_group  IN SELECT * 
      FROM public.group_users gu 
      WHERE gu.group_type = 'layer' AND gu.type_id = _layer_group_id 
      LOOP
        INSERT INTO public.context_users (context_id, user_id, role_id)
          VALUES (_context_id, _t_row_group.user_id, _default_layer_role_id) ON CONFLICT DO NOTHING;
      END LOOP;
  END LOOP;
END
$$

