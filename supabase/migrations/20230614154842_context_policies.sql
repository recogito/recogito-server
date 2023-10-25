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
using ((check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types, project_id)));


create policy "Users with correct policies can UPDATE on contexts"
on "public"."contexts"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types, project_id)))
with check ((check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'UPDATE'::operation_types, project_id)));



