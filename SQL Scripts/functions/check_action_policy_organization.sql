CREATE OR REPLACE FUNCTION check_action_policy_organization(user_id uuid, table_name varchar, operation operation_types)
    RETURNS bool
AS
$body$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.organization_groups ag
                           INNER JOIN public.group_users gu
                                      ON ag.id = gu.type_id AND gu.group_type = 'organization' AND gu.user_id = $1
                           INNER JOIN public.roles r ON ag.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END ;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
