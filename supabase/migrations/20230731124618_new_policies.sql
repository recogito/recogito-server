drop policy "Enable All access for Authenticated users" on "public"."default_groups";

drop policy "Enable ALL access for all authenticated users" on "public"."invites";

drop policy "Enable ALL access for authenticated users" on "public"."layer_groups";

drop policy "Enable ALL access for authenticated users" on "public"."policies";

drop policy "Enable ALL access for authenticated users" on "public"."role_policies";

drop policy "Enable All access for Authenticated users" on "public"."tag_definitions";

drop policy "Enable ALL access for authenticated users" on "public"."tags";

create policy "Users with correct policies can DELETE on default_groups"
on "public"."default_groups"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'default_groups'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on default_groups"
on "public"."default_groups"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'default_groups'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on default_groups"
on "public"."default_groups"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'default_groups'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can UPDATE on default_groups"
on "public"."default_groups"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'default_groups'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'default_groups'::character varying, 'UPDATE'::operation_types));


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


create policy "Users with correct policies can DELETE on layer_groups"
on "public"."layer_groups"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layer_groups'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'layer_groups'::character varying, 'DELETE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'layer_groups'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on layer_groups"
on "public"."layer_groups"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'layer_groups'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'layer_groups'::character varying, 'INSERT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'layer_groups'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can SELECT on layer_groups"
on "public"."layer_groups"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'layer_groups'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'layer_groups'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'layer_groups'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can UPDATE on layer_groups"
on "public"."layer_groups"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layer_groups'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'layer_groups'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'layer_groups'::character varying, 'UPDATE'::operation_types, id)))
with check ((check_action_policy_organization(auth.uid(), 'layer_groups'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'layer_groups'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'layer_groups'::character varying, 'UPDATE'::operation_types, id)));


create policy "Users with correct policies can DELETE on policies"
on "public"."policies"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'policies'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on policies"
on "public"."policies"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'policies'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on policies"
on "public"."policies"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'policies'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can UPDATE on policies"
on "public"."policies"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'policies'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'policies'::character varying, 'UPDATE'::operation_types));


create policy "Users with correct policies can DELETE on role_policies"
on "public"."role_policies"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'role_policies'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on role_policies"
on "public"."role_policies"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'role_policies'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on role_policies"
on "public"."role_policies"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'role_policies'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can UPDATE on role_policies"
on "public"."role_policies"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'role_policies'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'role_policies'::character varying, 'UPDATE'::operation_types));


create policy "Users with correct policies can DELETE on roles"
on "public"."roles"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'roles'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on roles"
on "public"."roles"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'roles'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on roles"
on "public"."roles"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'roles'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can UPDATE on roles"
on "public"."roles"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'roles'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'roles'::character varying, 'UPDATE'::operation_types));


create policy "Users with correct policies can DELETE on tag_definitions"
on "public"."tag_definitions"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on tag_definitions"
on "public"."tag_definitions"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on tag_definitions"
on "public"."tag_definitions"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can UPDATE on tag_definitions"
on "public"."tag_definitions"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types));


create policy "Users with correct policies can DELETE on tags"
on "public"."tags"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on tags"
on "public"."tags"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on tags"
on "public"."tags"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'tags'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can UPDATE on tags"
on "public"."tags"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'UPDATE'::operation_types));



