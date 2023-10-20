drop policy "Users with correct policies can DELETE on layer_contexts" on "public"."layer_contexts";

drop policy "Users with correct policies can INSERT on layer_contexts" on "public"."layer_contexts";

drop policy "Users with correct policies can SELECT on layer_contexts" on "public"."layer_contexts";

drop policy "Users with correct policies can UPDATE on layer_contexts" on "public"."layer_contexts";

create policy "Users with correct policies can DELETE on layer_contexts"
on "public"."layer_contexts"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'DELETE'::operation_types, context_id) OR check_action_policy_layer(auth.uid(), 'layer_contexts'::character varying, 'DELETE'::operation_types, layer_id)));


create policy "Users with correct policies can INSERT on layer_contexts"
on "public"."layer_contexts"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'INSERT'::operation_types, context_id) OR check_action_policy_layer(auth.uid(), 'layer_contexts'::character varying, 'INSERT'::operation_types, layer_id)));


create policy "Users with correct policies can SELECT on layer_contexts"
on "public"."layer_contexts"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types, context_id) OR check_action_policy_layer(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types, layer_id))));


create policy "Users with correct policies can UPDATE on layer_contexts"
on "public"."layer_contexts"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types, context_id) OR check_action_policy_layer(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types, layer_id)))
with check ((check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types, context_id) OR check_action_policy_layer(auth.uid(), 'layer_contexts'::character varying, 'UPDATE'::operation_types, layer_id)));



