CREATE
    OR REPLACE FUNCTION public.check_archive_context()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    _count      int;
    _layer_id   uuid;
BEGIN
    IF NEW.is_archived IS TRUE THEN
        SELECT layer_id INTO _layer_id FROM public.layer_contexts lc WHERE lc.context_id = OLD.id;
        SELECT INTO _count count(*) FROM public.layer_contexts lc WHERE lc.context_id = OLD.id;
        UPDATE public.layer_contexts AS lc SET is_archived = TRUE WHERE lc.context_id = OLD.id;
        IF _count = 1 THEN
            UPDATE public.layers AS ly SET is_archived = TRUE WHERE ly.id = _layer_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$
;
