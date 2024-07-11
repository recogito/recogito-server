drop policy "Users with correct policies can SELECT on layer_contexts" on "public"."layer_contexts";

create policy "Users with correct policies can SELECT on layer_contexts"
on "public"."layer_contexts"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types, context_id) OR check_action_policy_layer_select(auth.uid(), 'layer_contexts'::character varying, layer_id))));



