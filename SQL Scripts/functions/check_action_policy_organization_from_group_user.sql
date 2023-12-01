CREATE OR REPLACE FUNCTION check_action_policy_organization_from_group_user(user_id uuid, table_name varchar,
                                                                            operation operation_types,
                                                                            _group_type group_types, _type_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.profiles pr
                           INNER JOIN public.group_users xgu ON group_type = $4 AND type_id = $5
                           INNER JOIN public.project_groups xpg ON xpg.id = xgu.id
                           INNER JOIN public.project_groups pg ON pg.project_id = xpg.project_id
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END ;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
