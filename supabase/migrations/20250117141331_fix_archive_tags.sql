set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_archive_project()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.contexts AS c SET is_archived = TRUE WHERE c.project_id = OLD.id;
        UPDATE public.invites AS i SET is_archived = TRUE WHERE i.project_id = OLD.id;
        UPDATE public.layers AS l SET is_archived = TRUE WHERE l.project_id = OLD.id;
        UPDATE public.project_groups AS p SET is_archived = TRUE WHERE p.project_id = OLD.id;
        PERFORM public.archive_tags_for_target('project', OLD.id);
    END IF;
    RETURN NEW;
END;
$function$
;


