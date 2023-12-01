set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_for_private_annotation(user_id uuid, annotation_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.annotations a
                  WHERE a.id = $2
                    AND (a.is_private IS NOT TRUE OR a.created_by = $1));
END;
$function$
;

create policy "Users with correct policies can DELETE on annotations"
on "public"."annotations"
as permissive
for delete
to authenticated
using ((check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'DELETE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'DELETE'::operation_types, layer_id))));


create policy "Users with correct policies can INSERT on annotations"
on "public"."annotations"
as permissive
for insert
to authenticated
with check ((check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'INSERT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'INSERT'::operation_types, layer_id))));


create policy "Users with correct policies can SELECT on annotations"
on "public"."annotations"
as permissive
for select
to authenticated
using ((check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types, layer_id))));


create policy "Users with correct policies can UPDATE on annotations"
on "public"."annotations"
as permissive
for update
to authenticated
using ((check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id))))
with check ((check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'UPDATE'::operation_types, layer_id))));


create policy "Users with correct policies can DELETE on bodies"
on "public"."bodies"
as permissive
for delete
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'DELETE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'DELETE'::operation_types, layer_id))));


create policy "Users with correct policies can INSERT on bodies"
on "public"."bodies"
as permissive
for insert
to authenticated
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types, layer_id))));


create policy "Users with correct policies can SELECT on bodies"
on "public"."bodies"
as permissive
for select
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types, layer_id))));


create policy "Users with correct policies can UPDATE on bodies"
on "public"."bodies"
as permissive
for update
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))))
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))));


create policy "Users with correct policies can DELETE on targets"
on "public"."targets"
as permissive
for delete
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'DELETE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'targets'::character varying, 'DELETE'::operation_types, layer_id))));


create policy "Users with correct policies can INSERT on targets"
on "public"."targets"
as permissive
for insert
to authenticated
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'INSERT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'targets'::character varying, 'INSERT'::operation_types, layer_id))));


create policy "Users with correct policies can SELECT on targets"
on "public"."targets"
as permissive
for select
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types, layer_id))));


create policy "Users with correct policies can UPDATE on targets"
on "public"."targets"
as permissive
for update
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id))))
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id))));



