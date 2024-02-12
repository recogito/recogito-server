CREATE
    OR REPLACE FUNCTION public.anonymize_profile()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    UPDATE public.profiles
    SET first_name = '', last_name = '', nickname = '', email = '', avatar_url = '' 
    WHERE id = OLD.id;
    RETURN new;
END;
$$
;
