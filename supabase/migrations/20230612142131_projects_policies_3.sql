set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer(user_id uuid, table_name character varying, operation operation_types, layer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_groups pg ON pg.layer_id = $4
                           INNER JOIN public.groups g ON ag.group_id = g.id
                           INNER JOIN public.group_users gu ON g.id = gu.group_id AND gu.user_id = $1
                           INNER JOIN public.roles r ON g.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_organization(user_id uuid, table_name character varying, operation operation_types)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.organization_groups ag
                           INNER JOIN public.groups g ON ag.group_id = g.id
                           INNER JOIN public.group_users gu ON g.id = gu.group_id AND gu.user_id = $1
                           INNER JOIN public.roles r ON g.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_project(user_id uuid, table_name character varying, operation operation_types, project_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.project_id = $4
                           INNER JOIN public.groups g ON pg.group_id = g.id
                           INNER JOIN public.group_users gu ON g.id = gu.group_id AND gu.user_id = $1
                           INNER JOIN public.roles r ON g.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;


