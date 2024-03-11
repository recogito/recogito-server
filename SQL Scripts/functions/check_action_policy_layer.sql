CREATE OR REPLACE FUNCTION check_action_policy_layer(user_id uuid, table_name varchar, operation operation_types,
                                                     layer_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_contexts lc ON lc.layer_id = $4
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id
                  
                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
