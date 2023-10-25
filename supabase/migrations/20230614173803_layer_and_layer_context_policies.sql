set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_project_from_context(user_id uuid, table_name character varying, operation operation_types, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.contexts c ON c.id = $4
                           INNER JOIN public.project_groups pg ON pg.project_id = c.project_id
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

create policy "Users with correct policies can DELETE on layer_contexts"
on "public"."layer_contexts"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'DELETE'::operation_types, context_id)));


create policy "Users with correct policies can INSERT on layer_contexts"
on "public"."layer_contexts"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'INSERT'::operation_types, context_id)));


create policy "Users with correct policies can SELECT on layer_contexts"
on "public"."layer_contexts"
as permissive
for select
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types, context_id)));


create policy "Users with correct policies can UPDATE on layer_contexts"
on "public"."layer_contexts"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types, context_id)))
with check ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types, context_id)));


create policy "Users with correct policies can DELETE on layers"
on "public"."layers"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on layers"
on "public"."layers"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on layers"
on "public"."layers"
as permissive
for select
to authenticated
using (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types));


create policy "Users with correct policies can UPDATE on layers"
on "public"."layers"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types));



