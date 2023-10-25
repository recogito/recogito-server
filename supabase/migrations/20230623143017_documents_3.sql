drop policy "Users with correct policies can DELETE on layers" on "public"."layers";

drop policy "Users with correct policies can INSERT on layers" on "public"."layers";

drop policy "Users with correct policies can SELECT on layers" on "public"."layers";

drop policy "Users with correct policies can UPDATE on layers" on "public"."layers";

create policy "Users with correct policies can DELETE on layers"
on "public"."layers"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layers'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'DELETE'::operation_types, project_id) OR check_action_policy_layer(auth.uid(), 'layers'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on layers"
on "public"."layers"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'layers'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'INSERT'::operation_types, project_id) OR check_action_policy_layer(auth.uid(), 'layers'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can SELECT on layers"
on "public"."layers"
as permissive
for select
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types, project_id) OR check_action_policy_layer(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types, id)));


create policy "Users with correct policies can UPDATE on layers"
on "public"."layers"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types, project_id) OR check_action_policy_layer(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types, id)))
with check ((check_action_policy_organization(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types, project_id) OR check_action_policy_layer(auth.uid(), 'layers'::character varying, 'UPDATE'::operation_types, id)));



