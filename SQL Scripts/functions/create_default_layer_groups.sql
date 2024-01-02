CREATE
OR        REPLACE FUNCTION CREATE_DEFAULT_LAYER_GROUPS () RETURNS TRIGGER AS $$
DECLARE
    _layer_group_id uuid;
    _role_id        uuid;
    _name           varchar;
    _description    varchar;
    _is_admin       bool;
    _is_default     bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin, _is_default IN SELECT role_id, name, description, is_admin, is_default
                                                    FROM public.default_groups
                                                    WHERE group_type = 'layer'
        LOOP
            _layer_group_id = extensions.uuid_generate_v4();
            INSERT INTO public.layer_groups
                (id, layer_id, role_id, name, description, is_admin, is_default)
            VALUES (_layer_group_id, NEW.id, _role_id, _name, _description, _is_admin, _is_default);

            IF _is_admin IS TRUE AND NEW.created_by IS NOT NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('layer', _layer_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
