drop trigger if exists "on_group_user_created" on "public"."group_users";

drop trigger if exists "on_group_user_updated" on "public"."group_users";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_for_group_membership(_user_id uuid, _group_type group_types, _type_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_group_user_with_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF public.check_for_group_membership(NEW.user_id, NEW.group_type, NEW.type_id) IS TRUE THEN
        RETURN NULL;
    END IF;
    NEW.created_at = NOW();
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_group_user_with_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF public.check_for_group_membership(NEW.user_id, NEW.group_type, NEW.type_id) IS TRUE THEN
        RETURN NULL;
    END IF;
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    -- These should never change --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER on_group_user_created BEFORE INSERT ON public.group_users FOR EACH ROW EXECUTE FUNCTION create_group_user_with_check();

CREATE TRIGGER on_group_user_updated BEFORE UPDATE ON public.group_users FOR EACH ROW EXECUTE FUNCTION update_group_user_with_check();


