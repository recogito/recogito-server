drop policy "Enable All access for authenticated users" on "public"."tag_definitions";

drop policy "Enable All access for authenticated users" on "public"."tags";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_project_from_tag_definition(user_id uuid, table_name character varying, operation operation_types, tag_definition_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    SELECT scope, scope_id FROM public.tag_definitions WHERE id = $4;

    RETURN scope = 'project' AND EXISTS(SELECT 1
                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.project_id = scope_id 
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END ;
$function$
;

create policy "Users with correct policies can DELETE on tag_definitions"
on "public"."tag_definitions"
as permissive
for delete
to authenticated
using (((scope <> 'system'::tag_scope_types) AND (is_archived IS FALSE) AND (((scope = 'organization'::tag_scope_types) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'DELETE'::operation_types)) OR ((scope = 'project'::tag_scope_types) AND (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'tag_definitions'::character varying, 'DELETE'::operation_types, scope_id))))));


create policy "Users with correct policies can INSERT on tag_definitions"
on "public"."tag_definitions"
as permissive
for insert
to authenticated
with check (((scope <> 'system'::tag_scope_types) AND (is_archived IS FALSE) AND (((scope = 'organization'::tag_scope_types) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'INSERT'::operation_types)) OR ((scope = 'project'::tag_scope_types) AND (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'tag_definitions'::character varying, 'INSERT'::operation_types, scope_id))))));


create policy "Users with correct policies can SELECT on tag_definitions"
on "public"."tag_definitions"
as permissive
for select
to authenticated
using (((scope <> 'system'::tag_scope_types) AND (is_archived IS FALSE) AND (((scope = 'organization'::tag_scope_types) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types)) OR ((scope = 'project'::tag_scope_types) AND (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'tag_definitions'::character varying, 'SELECT'::operation_types, scope_id))))));


create policy "Users with correct policies can UPDATE on tag_definitions"
on "public"."tag_definitions"
as permissive
for update
to authenticated
using (((scope <> 'system'::tag_scope_types) AND (is_archived IS FALSE) AND (((scope = 'organization'::tag_scope_types) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types)) OR ((scope = 'project'::tag_scope_types) AND (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types, scope_id))))))
with check (((scope <> 'system'::tag_scope_types) AND (is_archived IS FALSE) AND (((scope = 'organization'::tag_scope_types) AND check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types)) OR ((scope = 'project'::tag_scope_types) AND (check_action_policy_organization(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'tag_definitions'::character varying, 'UPDATE'::operation_types, scope_id))))));


create policy "Users with correct policies can DELETE on tags"
on "public"."tags"
as permissive
for delete
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_tag_definition(auth.uid(), 'tags'::character varying, 'DELETE'::operation_types, tag_definition_id))));


create policy "Users with correct policies can INSERT on tags"
on "public"."tags"
as permissive
for insert
to authenticated
with check (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_tag_definition(auth.uid(), 'tags'::character varying, 'INSERT'::operation_types, tag_definition_id))));


create policy "Users with correct policies can SELECT on tags"
on "public"."tags"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_tag_definition(auth.uid(), 'tags'::character varying, 'SELECT'::operation_types, tag_definition_id))));


create policy "Users with correct policies can UPDATE on tags"
on "public"."tags"
as permissive
for update
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_tag_definition(auth.uid(), 'tags'::character varying, 'UPDATE'::operation_types, tag_definition_id))))
with check (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'tags'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_tag_definition(auth.uid(), 'tags'::character varying, 'UPDATE'::operation_types, tag_definition_id))));



