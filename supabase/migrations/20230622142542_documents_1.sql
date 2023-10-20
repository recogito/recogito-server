drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_document(user_id uuid, table_name character varying, operation operation_types, document_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layers l ON l.document_id = $4
                           INNER JOIN public.layer_groups pg ON pg.layer_id = l.id
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'layer' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_project_from_document(user_id uuid, table_name character varying, operation operation_types, document_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layers l ON l.document_id = $4
                           INNER JOIN public.project_groups pg ON pg.project_id = l.project_id
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on documents"
on "public"."documents"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can SELECT on documents"
on "public"."documents"
as permissive
for select
to authenticated
using ((check_action_policy_organization(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id)));


create policy "Users with correct policies can UPDATE on documents"
on "public"."documents"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id)))
with check ((check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id)));



