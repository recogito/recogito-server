CREATE
    OR REPLACE FUNCTION public.handle_new_user()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email);
    RETURN new;
END;
$$
;
