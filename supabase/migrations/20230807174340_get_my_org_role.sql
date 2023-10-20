set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_my_org_role()
 RETURNS character varying
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _role_name varchar;
BEGIN
    SELECT INTO _role_name r.name
                 FROM public.roles r
                          INNER JOIN public.organization_groups g ON g.role_id = r.id
                          INNER JOIN public.group_users gu ON gu.group_type = 'organization' AND gu.type_id = g.id
                 WHERE gu.user_id = auth.uid();

    RETURN _role_name;
END ;
$function$
;


