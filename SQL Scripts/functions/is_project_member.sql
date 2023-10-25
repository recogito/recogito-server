CREATE OR REPLACE FUNCTION is_project_member(_project_id uuid, _email varchar)
    RETURNS boolean AS
$$
DECLARE
    _user auth.users;
BEGIN
    SELECT * INTO _user FROM auth.users a WHERE a.email = _email;
    RETURN EXISTS(SELECT 1
                  FROM public.group_users u
                           INNER JOIN public.project_groups p ON p.project_id = _project_id
                  WHERE u.group_type = 'project'
                    AND u.type_id = p.id
                    AND u.user_id = _user.id);
END ;
$$ LANGUAGE plpgsql SECURITY DEFINER;
