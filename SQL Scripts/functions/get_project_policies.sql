CREATE OR REPLACE FUNCTION get_project_policies(_project_id uuid)
    RETURNS TABLE
            (
                user_id    uuid,
                project_id uuid,
                table_name varchar,
                operation  operation_types
            )
AS
$body$
BEGIN
    RETURN QUERY SELECT gu.user_id, pg.project_id, p.table_name, p.operation
                 FROM public.project_groups pg
                          INNER JOIN public.group_users gu
                                     ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = auth.uid()
                          INNER JOIN public.roles r ON pg.role_id = r.id
                          INNER JOIN public.role_policies rp ON r.id = rp.role_id
                          INNER JOIN public.policies p ON rp.policy_id = p.id
                 WHERE gu.user_id = auth.uid()
                   AND pg.project_id = $1;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;

