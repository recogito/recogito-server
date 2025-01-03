CREATE OR REPLACE FUNCTION check_action_policy_layer_from_context(user_id uuid, table_name varchar, operation operation_types, context_id uuid)
    RETURNS bool
AS
$body$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_contexts lc ON lc.context_id = $4 AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;