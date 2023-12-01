drop policy "Users with correct policies can DELETE on annotations" on "public"."annotations";

drop policy "Users with correct policies can UPDATE on annotations" on "public"."annotations";

drop policy "Users with correct policies can UPDATE on bodies" on "public"."bodies";

drop policy "Users with correct policies can UPDATE on targets" on "public"."targets";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.is_admin_layer(user_id uuid, layer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_groups pg ON pg.layer_id = $2
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'layer' AND gu.user_id = $1
                  WHERE pg.is_admin = TRUE);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin_organization(user_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.organization_groups og
                           INNER JOIN public.group_users gu
                                      ON og.id = gu.type_id AND gu.group_type = 'organization' AND gu.user_id = $1
                  WHERE og.is_admin = TRUE);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin_project(user_id uuid, project_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.project_id = $2
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                  WHERE pg.is_admin = TRUE);
END;
$function$
;

create policy "Users with correct policies can DELETE on annotations"
on "public"."annotations"
as permissive
for delete
to authenticated
using ((check_for_private_annotation(auth.uid(), id) AND ((created_by = auth.uid()) OR is_admin_layer(auth.uid(), layer_id)) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'DELETE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'DELETE'::operation_types, layer_id))));


create policy "Users with correct policies can UPDATE on annotations"
on "public"."annotations"
as permissive
for update
to authenticated
using ((check_for_private_annotation(auth.uid(), id) AND ((created_by = auth.uid()) OR is_admin_layer(auth.uid(), layer_id)) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id))))
with check ((check_for_private_annotation(auth.uid(), id) AND ((created_by = auth.uid()) OR is_admin_layer(auth.uid(), layer_id)) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id))));


create policy "Users with correct policies can UPDATE on bodies"
on "public"."bodies"
as permissive
for update
to authenticated
using (((check_for_private_annotation(auth.uid(), annotation_id) AND ((created_by = auth.uid()) OR is_admin_layer(auth.uid(), layer_id)) AND (check_for_creating_user(auth.uid(), annotation_id) AND check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))) OR (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))))
with check (((check_for_private_annotation(auth.uid(), annotation_id) AND (check_for_creating_user(auth.uid(), annotation_id) AND ((created_by = auth.uid()) OR is_admin_layer(auth.uid(), layer_id)) AND check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))) OR (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))));


create policy "Users with correct policies can UPDATE on targets"
on "public"."targets"
as permissive
for update
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND ((created_by = auth.uid()) OR is_admin_layer(auth.uid(), layer_id)) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) OR (check_action_policy_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) AND check_for_creating_user(auth.uid(), annotation_id)))))
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND ((created_by = auth.uid()) OR is_admin_layer(auth.uid(), layer_id)) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) OR (check_action_policy_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) AND check_for_creating_user(auth.uid(), annotation_id)))));



