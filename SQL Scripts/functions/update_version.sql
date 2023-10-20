CREATE
    OR REPLACE FUNCTION public.update_version()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$
;
