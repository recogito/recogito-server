drop policy "Users with correct policies can SELECT on tag_definitions" on "public"."tag_definitions";

create policy "Users with correct policies can SELECT on tag_definitions"
on "public"."tag_definitions"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (((scope = 'organization'::tag_scope_types) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types)) OR ((scope = 'project'::tag_scope_types) AND (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types, scope_id))) OR ((scope = 'system'::tag_scope_types) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types)))));



