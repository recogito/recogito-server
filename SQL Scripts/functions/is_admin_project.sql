CREATE OR REPLACE FUNCTION is_admin_project(user_id uuid, project_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.project_id = $2
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                  WHERE pg.is_admin = TRUE);
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
