CREATE
    OR REPLACE FUNCTION storage.handle_new_storage_object()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
    DECLARE _type varchar;
BEGIN
    _type = (NEW.metadata->>'mimetype')::varchar;
    RAISE LOG 'Type = %', _type;
    INSERT INTO public.documents (id, name, bucket_id, content_type)
    VALUES (NEW.id, NEW.name, NEW.bucket_id, CAST(_type AS public.content_types_type));
    RETURN NEW;
END;
$$
;
