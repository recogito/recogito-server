CREATE
    OR REPLACE FUNCTION public.check_archive_annotation()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.bodies AS b SET is_archived = TRUE WHERE b.annotation_id = OLD.id AND b.is_archived IS NOT TRUE;
        UPDATE public.targets AS t SET is_archived = TRUE WHERE t.annotation_id = OLD.id AND t.is_archived IS NOT TRUE;
    END IF;
    RETURN NEW;
END;
$$
;
