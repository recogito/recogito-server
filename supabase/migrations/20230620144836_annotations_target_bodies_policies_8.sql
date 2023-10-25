drop policy "Users with correct policies can INSERT on bodies" on "public"."bodies";

drop policy "Users with correct policies can UPDATE on bodies" on "public"."bodies";

drop policy "Users with correct policies can DELETE on targets" on "public"."targets";

drop policy "Users with correct policies can INSERT on targets" on "public"."targets";

drop policy "Users with correct policies can UPDATE on targets" on "public"."targets";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_for_creating_user(user_id uuid, annotation_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.annotations a
                  WHERE a.id = $2
                    AND a.created_by = $1);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_for_first_body(annotation_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.bodies a
                  WHERE a.annotation_id = $1);
END;
$function$
;

create policy "Users with correct policies can INSERT on bodies"
on "public"."bodies"
as permissive
for insert
to authenticated
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND ((check_for_first_body(annotation_id) AND check_for_creating_user(auth.uid(), annotation_id) AND check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types, layer_id)) OR (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'INSERT'::operation_types, layer_id)))));


create policy "Users with correct policies can UPDATE on bodies"
on "public"."bodies"
as permissive
for update
to authenticated
using (((check_for_private_annotation(auth.uid(), annotation_id) AND (check_for_creating_user(auth.uid(), annotation_id) AND check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))) OR (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))))
with check (((check_for_private_annotation(auth.uid(), annotation_id) AND (check_for_creating_user(auth.uid(), annotation_id) AND check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))) OR (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'UPDATE'::operation_types, layer_id))));


create policy "Users with correct policies can DELETE on targets"
on "public"."targets"
as permissive
for delete
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'DELETE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'DELETE'::operation_types, layer_id) OR (check_action_policy_layer(auth.uid(), 'targets'::character varying, 'DELETE'::operation_types, layer_id) AND check_for_creating_user(auth.uid(), annotation_id)))));


create policy "Users with correct policies can INSERT on targets"
on "public"."targets"
as permissive
for insert
to authenticated
with check ((check_for_creating_user(auth.uid(), annotation_id) AND check_action_policy_layer(auth.uid(), 'targets'::character varying, 'INSERT'::operation_types, layer_id)));


create policy "Users with correct policies can UPDATE on targets"
on "public"."targets"
as permissive
for update
to authenticated
using ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) OR (check_action_policy_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) AND check_for_creating_user(auth.uid(), annotation_id)))))
with check ((check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) OR (check_action_policy_layer(auth.uid(), 'targets'::character varying, 'UPDATE'::operation_types, layer_id) AND check_for_creating_user(auth.uid(), annotation_id)))));


drop policy IF EXISTS "Users with correct policies can DELETE on objects" on "storage"."objects";

create policy "Users with correct policies can DELETE on objects"
on "storage"."objects"
as permissive
for delete
to authenticated
using (true);


drop policy IF EXISTS "Users with correct policies can INSERT on objects" on "storage"."objects";

create policy "Users with correct policies can INSERT on objects"
on "storage"."objects"
as permissive
for insert
to authenticated
with check (true);


drop policy IF EXISTS "Users with correct policies can SELECT on objects" on "storage"."objects";

create policy "Users with correct policies can SELECT on objects"
on "storage"."objects"
as permissive
for select
to authenticated
using (true);

drop policy IF EXISTS "Users with correct policies can UPDATE on objects" on "storage"."objects";

create policy "Users with correct policies can UPDATE on objects"
on "storage"."objects"
as permissive
for update
to authenticated
using (true)
with check (true);



