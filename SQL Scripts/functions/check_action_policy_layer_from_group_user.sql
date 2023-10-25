CREATE OR REPLACE FUNCTION check_action_policy_layer_from_group_user(user_id uuid, table_name varchar,
                                                                     operation operation_types,
                                                                     group_type group_types, type_id uuid)
    RETURNS bool
AS
$body$
DECLARE
    _layer_id uuid;
BEGIN
    IF $4 = 'organization' THEN RETURN FALSE; END IF;
    IF $4 = 'layer' THEN
        SELECT INTO _layer_id lg.layer_id FROM public.layer_groups lg WHERE id = $5;
    ELSE
        SELECT INTO _layer_id lg.layer_id
        FROM public.layer_groups lg
                 INNER JOIN public.layers l ON l.id = lg.layer_id
                 INNER JOIN public.projects p ON p.id = l.project_id
        WHERE lg.id = $5;
    END IF;

    RETURN EXISTS(SELECT 1
                  FROM public.profiles pr
                           INNER JOIN public.layer_groups pg ON pg.layer_id = _layer_id
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'layer' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
