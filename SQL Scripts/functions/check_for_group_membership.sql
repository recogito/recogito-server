CREATE OR REPLACE FUNCTION check_for_group_membership(_user_id uuid, _group_type group_types, _type_id uuid)
    RETURNS bool AS
$$
DECLARE
    _project_id uuid;
    _layer_id   uuid;
BEGIN
    IF _group_type = 'organization' THEN
        RETURN EXISTS(SELECT * FROM public.group_users WHERE user_id = _user_id AND group_type = 'organization');
    ELSE
        IF _group_type = 'project' THEN
            SELECT INTO _project_id p.project_id FROM public.project_groups p WHERE p.id = _type_id;
            RETURN EXISTS(SELECT 1
                          FROM public.group_users gu
                                   INNER JOIN public.project_groups pg ON pg.project_id = _project_id
                          WHERE gu.user_id = _user_id AND gu.type_id = pg.id);
        ELSE
            IF _group_type = 'layer' THEN
                SELECT INTO _layer_id l.layer_id FROM public.layer_groups l WHERE l.id = _type_id;
                RETURN EXISTS(SELECT 1
                              FROM public.group_users gu
                                       INNER JOIN public.layer_groups lg ON lg.layer_id = _layer_id
                              WHERE gu.user_id = _user_id AND gu.type_id = lg.id);
            END IF;
        END IF;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
