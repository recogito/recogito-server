CREATE
    OR REPLACE FUNCTION storage.handle_delete_storage_object()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    DELETE FROM public.documents WHERE id = OLD.id;
    RETURN OLD;
END;
$$
;
