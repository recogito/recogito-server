CREATE
    OR REPLACE FUNCTION public.check_archive_layer()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.annotations AS a SET is_archived = TRUE WHERE a.layer_id = OLD.id;
        UPDATE public.layer_contexts AS l SET is_archived = TRUE WHERE l.layer_id = OLD.id;
        UPDATE public.layer_groups AS g SET is_archived = TRUE WHERE g.layer_id = OLD.id;
    END IF;
    RETURN NEW;
END;
$$
;
