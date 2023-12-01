drop policy "Users with correct policies can INSERT on targets" on "public"."targets";

create policy "Users with correct policies can INSERT on targets"
on "public"."targets"
as permissive
for insert
to authenticated
with check ((check_for_creating_user(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'INSERT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'targets'::character varying, 'INSERT'::operation_types, layer_id))));



