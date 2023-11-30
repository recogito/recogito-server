CREATE
OR        REPLACE FUNCTION CREATE_DEFAULT_PROJECT_GROUPS () RETURNS TRIGGER AS $$
DECLARE
    _project_group_id uuid;
    _role_id          uuid;
    _name             varchar;
    _description      varchar;
    _is_admin         bool;
    _is_default       bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin, _is_default IN SELECT role_id, name, description, is_admin, is_default
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            _project_group_id = extensions.uuid_generate_v4();
            INSERT INTO public.project_groups
                (id, project_id, role_id, name, description, is_admin, is_default)
            VALUES (_project_group_id, NEW.id, _role_id, _name, _description, _is_admin, _is_default);

            IF _is_admin IS TRUE AND NEW.created_by IS NOT NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('project', _project_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
