drop policy "Users with correct policies can INSERT on bodies" on "public"."bodies";

create policy "Users with correct policies can INSERT on bodies"
on "public"."bodies"
as permissive
for insert
to authenticated
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND ((check_for_first_body(annotation_id) AND check_for_creating_user(auth.uid(), annotation_id) AND check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types, layer_id)) OR ((check_for_first_body(annotation_id) IS FALSE) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types, layer_id))))));



