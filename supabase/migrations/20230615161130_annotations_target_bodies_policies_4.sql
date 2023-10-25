drop policy "Users with correct policies can INSERT on annotations" on "public"."annotations";

create policy "Users with correct policies can INSERT on annotations"
on "public"."annotations"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'INSERT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'INSERT'::operation_types, layer_id)));



