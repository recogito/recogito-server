CREATE OR REPLACE FUNCTION is_admin_layer(user_id uuid, layer_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_groups pg ON pg.layer_id = $2
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'layer' AND gu.user_id = $1
                  WHERE pg.is_admin = TRUE);
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
