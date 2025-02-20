CREATE
    OR REPLACE FUNCTION public.update_user()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    IF NEW.is_sso_user 
    AND (NEW.raw_user_meta_data->custom_claims->first_name OR NEW.raw_user_meta_data->custom_claims->last_name)
    THEN
        UPDATE public.profiles
        SET email = NEW.email,
            first_name = NEW.raw_user_meta_data->custom_claims->first_name,
            last_name = NEW.raw_user_meta_data->custom_claims->last_name
        WHERE id = NEW.id;
    ELSE
        UPDATE public.profiles
        SET email = NEW.email
        WHERE id = NEW.id;
    END IF;
    RETURN new;
END;
$$
;
