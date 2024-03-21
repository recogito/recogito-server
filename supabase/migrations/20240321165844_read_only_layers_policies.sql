drop policy "Users with correct policies can SELECT on annotations" on "public"."annotations";

drop policy "Users with correct policies can SELECT on bodies" on "public"."bodies";

drop policy "Users with correct policies can SELECT on contexts" on "public"."contexts";

drop policy "Users with correct policies can SELECT on layers" on "public"."layers";

drop policy "Users with correct policies can SELECT on targets" on "public"."targets";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_read_only_layers_rpc(_context_id uuid, _layer_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id       uuid;
    _layer_id         uuid;
    _layer_project_id public.layers %rowtype;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Didn't find the project for this context
    IF NOT FOUND THEN
        RAISE EXCEPTION 'project not found for context % ', _context_id;
    END IF;

    -- Check project policy that contexts can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF;  

    -- Iterate through the layer ids
    FOREACH _layer_id IN ARRAY _layer_ids 
    LOOP
        -- Should only add layers which belong to the current project
        SELECT l.project_id INTO _layer_project_id FROM public.layers l 
          WHERE l.id = _layer_id AND l.project_id = _project_id;

        -- Didn't find this layer in this project
        IF NOT FOUND THEN
            RAISE EXCEPTION 'layer % not found for project % ', _layer_id, _project_id;
        END IF;          

        -- Add a layer context and add them as the non-active layer
        INSERT INTO public.layer_contexts
                (created_by, created_at, layer_id, context_id, is_active_layer)
            VALUES (auth.uid(), NOW(), _layer_id, _context_id, FALSE);
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_context(user_id uuid, table_name character varying, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.context_users cu ON cu.context_id = $3 AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = 'SELECT');
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_context_select(user_id uuid, table_name character varying, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.context_users cu ON cu.context_id = $3 AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = 'SELECT');
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_document(user_id uuid, table_name character varying, document_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layers l ON l.document_id = $3
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = l.id
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = 'SELECT');

    RETURN _exists;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_select(user_id uuid, table_name character varying, layer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

        FROM public.profiles pr
                  INNER JOIN public.layer_contexts lc ON lc.layer_id = $3
                  INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                  INNER JOIN public.roles r ON cu.role_id = r.id
                  INNER JOIN public.role_policies rp ON r.id = rp.role_id
                  INNER JOIN public.policies p ON rp.policy_id = p.id
        
        WHERE p.table_name = $2
          AND p.operation = 'SELECT');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer(user_id uuid, table_name character varying, operation operation_types, layer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = $4 AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id
                  
                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_context(user_id uuid, table_name character varying, operation operation_types, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_context lc ON lc.context_id = $4 AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_document(user_id uuid, table_name character varying, operation operation_types, document_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layers l ON l.document_id = $4
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = l.id AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);

    RETURN _exists;
END;
$function$
;

create policy "Users with correct policies can SELECT on annotations"
on "public"."annotations"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer_select(auth.uid(), 'annotations'::character varying, layer_id))));


create policy "Users with correct policies can SELECT on bodies"
on "public"."bodies"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer_select(auth.uid(), 'bodies'::character varying, layer_id))));


create policy "Users with correct policies can SELECT on contexts"
on "public"."contexts"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types, project_id) OR check_action_policy_layer_from_context_select(auth.uid(), 'contexts'::character varying, id))));


create policy "Users with correct policies can SELECT on layers"
on "public"."layers"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types, project_id) OR check_action_policy_layer_select(auth.uid(), 'layers'::character varying, id))));


create policy "Users with correct policies can SELECT on targets"
on "public"."targets"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer_select(auth.uid(), 'targets'::character varying, layer_id)))));



