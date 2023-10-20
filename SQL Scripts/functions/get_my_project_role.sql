CREATE OR REPLACE FUNCTION get_my_project_role(_project_id uuid)
    RETURNS varchar
AS
$body$
DECLARE
    _role_name varchar;
BEGIN
    SELECT INTO _role_name r.name
    FROM public.roles r
             INNER JOIN public.project_groups g ON g.role_id = r.id AND g.project_id = _project_id
             INNER JOIN public.group_users gu ON gu.group_type = 'project' AND gu.type_id = g.id
    WHERE gu.user_id = auth.uid();

    RETURN _role_name;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;
