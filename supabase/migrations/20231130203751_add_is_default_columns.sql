alter table "public"."layer_groups" add column "is_default" boolean default false;

alter table "public"."project_groups" add column "is_default" boolean default false;

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
$function$
;


