drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

alter table "public"."collections" add column "custom_css" text;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_layer_policies(_layer_id uuid)
 RETURNS TABLE(user_id uuid, layer_id uuid, table_name character varying, operation operation_types)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
BEGIN
    SELECT INTO _project_id l.project_id FROM public.layers l WHERE l.id = layer_id;
    RETURN QUERY SELECT gu.user_id, pg.layer_id, p.table_name, p.operation
                 FROM public.layer_groups pg
                          INNER JOIN public.group_users gu
                                     ON pg.id = gu.type_id AND gu.group_type = 'layer' AND gu.user_id = auth.uid()
                          INNER JOIN public.roles r ON pg.role_id = r.id
                          INNER JOIN public.role_policies rp ON r.id = rp.role_id
                          INNER JOIN public.policies p ON rp.policy_id = p.id
                 WHERE gu.user_id = auth.uid()
                   AND pg.layer_id = $1
                UNION
                SELECT gu2.user_id, $1, p2.table_name, p2.operation
                 FROM public.project_groups pg2
                          INNER JOIN public.group_users gu2
                                     ON pg2.id = gu2.type_id AND gu2.group_type = 'project' AND gu2.user_id = auth.uid()
                          INNER JOIN public.roles r2 ON pg2.role_id = r2.id
                          INNER JOIN public.role_policies rp2 ON r2.id = rp2.role_id
                          INNER JOIN public.policies p2 ON rp2.policy_id = p2.id
                 WHERE gu2.user_id = auth.uid()
                   AND pg2.project_id = _project_id
                UNION
                SELECT gu3.user_id, $1, p3.table_name, p3.operation
                 FROM public.organization_groups ag3
                          INNER JOIN public.group_users gu3
                                     ON ag3.id = gu3.type_id AND gu3.group_type = 'organization' AND
                                        gu3.user_id = auth.uid()
                          INNER JOIN public.roles r3 ON ag3.role_id = r3.id
                          INNER JOIN public.role_policies rp3 ON r3.id = rp3.role_id
                          INNER JOIN public.policies p3 ON rp3.policy_id = p3.id
                 WHERE gu3.user_id = auth.uid();
END ;
$function$
;

CREATE OR REPLACE FUNCTION public.get_project_policies(_project_id uuid)
 RETURNS TABLE(user_id uuid, project_id uuid, table_name character varying, operation operation_types)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY SELECT gu.user_id, pg.project_id, p.table_name, p.operation
                 FROM public.project_groups pg
                          INNER JOIN public.group_users gu
                                     ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = auth.uid()
                          INNER JOIN public.roles r ON pg.role_id = r.id
                          INNER JOIN public.role_policies rp ON r.id = rp.role_id
                          INNER JOIN public.policies p ON rp.policy_id = p.id
                 WHERE gu.user_id = auth.uid()
                   AND pg.project_id = $1
                UNION
                SELECT gu3.user_id, $1, p3.table_name, p3.operation
                 FROM public.organization_groups ag3
                          INNER JOIN public.group_users gu3
                                     ON ag3.id = gu3.type_id AND gu3.group_type = 'organization' AND
                                        gu3.user_id = auth.uid()
                          INNER JOIN public.roles r3 ON ag3.role_id = r3.id
                          INNER JOIN public.role_policies rp3 ON r3.id = rp3.role_id
                          INNER JOIN public.policies p3 ON rp3.policy_id = p3.id
                 WHERE gu3.user_id = auth.uid();
END ;
$function$
;

create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on documents"
on "public"."documents"
as permissive
for insert
to authenticated
with check (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can SELECT on documents"
on "public"."documents"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND ((((is_private = false) OR (created_by = auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can UPDATE on documents"
on "public"."documents"
as permissive
for update
to authenticated
using (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR (((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id))))
with check (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR (((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id))));



