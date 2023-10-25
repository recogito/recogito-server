CREATE OR REPLACE FUNCTION is_admin_organization(user_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.organization_groups og
                           INNER JOIN public.group_users gu
                                      ON og.id = gu.type_id AND gu.group_type = 'organization' AND gu.user_id = $1
                  WHERE og.is_admin = TRUE);
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
