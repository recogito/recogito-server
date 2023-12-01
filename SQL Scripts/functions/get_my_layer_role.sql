CREATE OR REPLACE FUNCTION get_my_layer_role(_layer_id uuid)
    RETURNS varchar
AS
$body$
DECLARE
    _role_name varchar;
BEGIN
    SELECT INTO _role_name r.name
    FROM public.roles r
             INNER JOIN public.layer_groups g ON g.role_id = r.id AND g.layer_id = _layer_id
             INNER JOIN public.group_users gu ON gu.group_type = 'layer' AND gu.type_id = g.id
    WHERE gu.user_id = auth.uid();

    RETURN _role_name;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;
