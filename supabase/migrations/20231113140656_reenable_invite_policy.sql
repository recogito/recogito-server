drop policy "Enable All access for authentocated users" on "public"."invites";

create policy "Users with correct policies can DELETE on invites"
on "public"."invites"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'invites'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'invites'::character varying, 'DELETE'::operation_types, project_id)));


create policy "Users with correct policies can INSERT on invites"
on "public"."invites"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'invites'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'invites'::character varying, 'INSERT'::operation_types, project_id)));


create policy "Users with correct policies can SELECT on invites"
on "public"."invites"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'invites'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'invites'::character varying, 'SELECT'::operation_types, project_id))));


create policy "Users with correct policies can UPDATE on invites"
on "public"."invites"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'invites'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'invites'::character varying, 'UPDATE'::operation_types, project_id)))
with check ((check_action_policy_organization(auth.uid(), 'invites'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'invites'::character varying, 'UPDATE'::operation_types, project_id)));



