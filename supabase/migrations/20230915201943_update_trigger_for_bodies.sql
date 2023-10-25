set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_annotation_target_body()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    NEW.updated_at = NOW();
    -- created_at and created_by cannot be changed --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    NEW.updated_by = auth.uid();
    -- increment version ---
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$function$
;


