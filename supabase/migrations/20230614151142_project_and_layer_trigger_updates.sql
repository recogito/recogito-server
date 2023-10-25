set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_default_layer_groups()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _layer_group_id uuid;
    _role_id        uuid;
    _name           varchar;
    _description    varchar;
    _is_admin       bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            _layer_group_id = uuid_generate_v4();
            INSERT INTO public.layer_groups
                (id, layer_id, role_id, name, description)
            VALUES (_layer_group_id, NEW.id, _role_id, _name, _description);

            IF _is_admin AND NEW.created_by != NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('layer', _layer_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$function$
;

CREATE OR REPLACE FUNCTION public.create_default_project_groups()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_group_id uuid;
    _role_id          uuid;
    _name             varchar;
    _description      varchar;
    _is_admin         bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            _project_group_id = uuid_generate_v4();
            INSERT INTO public.project_groups
                (id, project_id, role_id, name, description)
            VALUES (_project_group_id, NEW.id, _role_id, _name, _description);

            IF _is_admin AND NEW.created_by != NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('project', _project_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$function$
;


