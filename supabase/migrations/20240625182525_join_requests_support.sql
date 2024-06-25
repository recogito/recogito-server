create table "public"."join_requests" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "user_id" uuid not null,
    "project_id" uuid,
    "accepted" boolean default false,
    "ignored" boolean default false
);


alter table "public"."join_requests" enable row level security;

CREATE UNIQUE INDEX join_requests_pkey ON public.join_requests USING btree (id);

alter table "public"."join_requests" add constraint "join_requests_pkey" PRIMARY KEY using index "join_requests_pkey";

alter table "public"."join_requests" add constraint "join_requests_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) not valid;

alter table "public"."join_requests" validate constraint "join_requests_project_id_fkey";

alter table "public"."join_requests" add constraint "join_requests_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."join_requests" validate constraint "join_requests_updated_by_fkey";

alter table "public"."join_requests" add constraint "join_requests_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) not valid;

alter table "public"."join_requests" validate constraint "join_requests_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.accept_join_request_rpc(_project_id uuid, _request_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _default_group_id uuid;
    _request public.join_requests % rowtype;
BEGIN
    -- Check project policy that contexts can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'projects', 'UPDATE') 
      OR check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _project_id)) 
    THEN
        RETURN FALSE;
    END IF;

    --  Get the request
    SELECT * INTO _request FROM public.join_requests jr WHERE jr.id = _request_id LIMIT 1;

    -- Get the group id
    SELECT g.id INTO _default_group_id FROM public.project_groups g WHERE g.project_id = _project_id AND g.is_default = TRUE;

    -- Add the user to the project
    INSERT INTO public.group_users
          (group_type, type_id, user_id) 
      VALUES('project', _default_group_id, _request.user_id);

    -- Delete the request
    DELETE FROM public.join_requests WHERE id = _request_id;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.request_join_project_rpc(_project_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN

    -- They at least have to be authenticated
    IF NOT check_action_policy_organization(auth.uid(), 'documents', 'SELECT') 
      THEN
        RETURN FALSE;
    END IF;    

    IF EXISTS(SELECT * FROM public.projects p WHERE p.id = _project_id)
      THEN

      -- Cannot have multiple requests for some project from same person
      IF NOT EXISTS(SELECT * FROM public.join_requests jr WHERE jr.user_id = auth.uid() AND jr.project_id = _project_id)
        THEN
          INSERT INTO public.join_requests
            (user_id, project_id)
            VALUES (auth.uid(), _project_id);

          RETURN TRUE;
      END IF;  
    END IF;

    RETURN FALSE;
END
$function$
;

grant delete on table "public"."join_requests" to "anon";

grant insert on table "public"."join_requests" to "anon";

grant references on table "public"."join_requests" to "anon";

grant select on table "public"."join_requests" to "anon";

grant trigger on table "public"."join_requests" to "anon";

grant truncate on table "public"."join_requests" to "anon";

grant update on table "public"."join_requests" to "anon";

grant delete on table "public"."join_requests" to "authenticated";

grant insert on table "public"."join_requests" to "authenticated";

grant references on table "public"."join_requests" to "authenticated";

grant select on table "public"."join_requests" to "authenticated";

grant trigger on table "public"."join_requests" to "authenticated";

grant truncate on table "public"."join_requests" to "authenticated";

grant update on table "public"."join_requests" to "authenticated";

grant delete on table "public"."join_requests" to "service_role";

grant insert on table "public"."join_requests" to "service_role";

grant references on table "public"."join_requests" to "service_role";

grant select on table "public"."join_requests" to "service_role";

grant trigger on table "public"."join_requests" to "service_role";

grant truncate on table "public"."join_requests" to "service_role";

grant update on table "public"."join_requests" to "service_role";

create policy "Users with correct policies can DELETE on join_requests"
on "public"."join_requests"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'join_requests'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'join_requests'::character varying, 'DELETE'::operation_types, project_id)));


create policy "Users with correct policies can INSERT on join_requests"
on "public"."join_requests"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'join_requests'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'join_requests'::character varying, 'INSERT'::operation_types, project_id)));


create policy "Users with correct policies can SELECT on join_requests"
on "public"."join_requests"
as permissive
for select
to authenticated
using ((check_action_policy_organization(auth.uid(), 'join_requests'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'join_requests'::character varying, 'SELECT'::operation_types, project_id)));


create policy "Users with correct policies can UPDATE on join_requests"
on "public"."join_requests"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'join_requests'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'join_requests'::character varying, 'UPDATE'::operation_types, project_id)))
with check ((check_action_policy_organization(auth.uid(), 'join_requests'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'join_requests'::character varying, 'UPDATE'::operation_types, project_id)));



