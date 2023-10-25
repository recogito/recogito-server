set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_group_user(user_id uuid, table_name character varying, operation operation_types, group_type group_types, type_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF $4 != 'layer' THEN RETURN FALSE; END IF;
    RETURN EXISTS(SELECT 1
                  FROM public.profiles pr
                           INNER JOIN public.layer_groups pg ON pg.layer_id = $4
                           INNER JOIN public.group_users gu
                                      ON pg.id = $5 AND gu.group_type = 'layer' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_organization_from_group_user(user_id uuid, table_name character varying, operation operation_types, group_type group_types, type_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF $4 != 'organization' THEN RETURN FALSE; END IF;
    RETURN EXISTS(SELECT 1
                  FROM public.organization_groups ag
                           INNER JOIN public.group_users gu
                                      ON ag.id = $5 AND gu.group_type = 'organization' AND gu.user_id = $1
                           INNER JOIN public.roles r ON ag.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END ;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_project_from_group_user(user_id uuid, table_name character varying, operation operation_types, group_type group_types, type_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF $4 != 'project' THEN RETURN FALSE; END IF;
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.id = $5
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

create policy "Users with correct policies can DELETE on group_users"
on "public"."group_users"
as permissive
for delete
to authenticated
using ((check_action_policy_organization_from_group_user(auth.uid(), 'group_users'::character varying, 'DELETE'::operation_types, group_type, type_id) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'DELETE'::operation_types, group_type, type_id) OR check_action_policy_layer_from_group_user(auth.uid(), 'group_users'::character varying, 'DELETE'::operation_types, group_type, type_id)));


create policy "Users with correct policies can INSERT on group_users"
on "public"."group_users"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization_from_group_user(auth.uid(), 'group_users'::character varying, 'INSERT'::operation_types, group_type, type_id) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'INSERT'::operation_types, group_type, type_id) OR check_action_policy_layer_from_group_user(auth.uid(), 'group_users'::character varying, 'INSERT'::operation_types, group_type, type_id)));


create policy "Users with correct policies can SELECT on group_users"
on "public"."group_users"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization_from_group_user(auth.uid(), 'group_users'::character varying, 'SELECT'::operation_types, group_type, type_id) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'SELECT'::operation_types, group_type, type_id) OR check_action_policy_layer_from_group_user(auth.uid(), 'group_users'::character varying, 'SELECT'::operation_types, group_type, type_id))));


create policy "Users with correct policies can UPDATE on group_users"
on "public"."group_users"
as permissive
for update
to authenticated
using ((check_action_policy_organization_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id) OR check_action_policy_layer_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id)))
with check ((check_action_policy_organization_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id) OR check_action_policy_project_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id) OR check_action_policy_layer_from_group_user(auth.uid(), 'group_users'::character varying, 'UPDATE'::operation_types, group_type, type_id)));



