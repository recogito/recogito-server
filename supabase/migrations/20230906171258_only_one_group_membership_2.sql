
set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_group_user_with_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.type_id != OLD.type_id AND public.check_for_group_membership(NEW.user_id, NEW.group_type, NEW.type_id) IS TRUE THEN
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


