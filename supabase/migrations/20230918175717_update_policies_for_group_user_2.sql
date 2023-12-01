set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_group_user(user_id uuid, table_name character varying, operation operation_types, group_type group_types, type_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF $4 != 'layer' THEN RETURN FALSE; END IF;
    RETURN EXISTS(SELECT 1
                  FROM public.profiles pr
                           INNER JOIN public.layer_groups pg ON pg.layer_id = $5
                           INNER JOIN public.group_users gu
                                      ON pg.id = $5 AND gu.group_type = 'layer' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;


