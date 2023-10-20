CREATE OR REPLACE FUNCTION get_my_projects()
    RETURNS TABLE
            (
                id          uuid,
                created_at  timestamptz,
                created_by  uuid,
                updated_at  timestamptz,
                updated_by  uuid,
                is_archived bool,
                name        varchar,
                description varchar
            )
AS
$body$
BEGIN
    RETURN QUERY SELECT p.id,
                        p.created_at,
                        p.created_by,
                        p.updated_at,
                        p.updated_by,
                        p.is_archived,
                        p.name,
                        p.description
                 FROM public.projects p
                          INNER JOIN public.project_groups pg ON pg.project_id = p.id
                          INNER JOIN public.group_users gu
                                     ON pg.id = gu.type_id AND gu.group_type = 'project'
                 WHERE gu.user_id = auth.uid()
                   AND p.is_archived = FALSE;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;

--DROP FUNCTION get_my_projects;
