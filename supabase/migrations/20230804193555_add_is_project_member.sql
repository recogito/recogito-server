set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.is_project_member(_project_id uuid, _email character varying)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;


