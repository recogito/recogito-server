--drop policy "Users with correct policies can INSERT on project_groups" on "public"."project_groups";

--drop policy "Users with correct policies can SELECT on project_groups" on "public"."project_groups";

--drop policy "Users with correct policies can UPDATE on project_groups" on "public"."project_groups";

create policy "Users with correct policies can DELETE on project_groups"
on "public"."project_groups"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'project_groups'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'project_groups'::character varying, 'DELETE'::operation_types, project_id)));


create policy "Users with correct policies can INSERT on project_groups"
on "public"."project_groups"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'project_groups'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'project_groups'::character varying, 'INSERT'::operation_types, project_id)));


create policy "Users with correct policies can SELECT on project_groups"
on "public"."project_groups"
as permissive
for select
to authenticated
using ((check_action_policy_organization(auth.uid(), 'project_groups'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'project_groups'::character varying, 'SELECT'::operation_types, project_id)));


create policy "Users with correct policies can UPDATE on project_groups"
on "public"."project_groups"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'project_groups'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'project_groups'::character varying, 'UPDATE'::operation_types, project_id)))
with check ((check_action_policy_organization(auth.uid(), 'project_groups'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'project_groups'::character varying, 'UPDATE'::operation_types, project_id)));



