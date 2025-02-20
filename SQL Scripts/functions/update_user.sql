CREATE
    OR REPLACE FUNCTION public.update_user()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    IF NEW.is_sso_user IS TRUE
    THEN
        IF NEW.raw_user_meta_data->'custom_claims' IS NOT NULL 
        AND (NEW.raw_user_meta_data->'custom_claims'->>'first_name' IS NOT NULL 
        OR NEW.raw_user_meta_data->'custom_claims'->>'last_name' IS NOT NULL)
        THEN
            UPDATE public.profiles
            SET email = NEW.email,
                first_name = NEW.raw_user_meta_data->'custom_claims'->>'first_name',
                last_name = NEW.raw_user_meta_data->'custom_claims'->>'last_name'
            WHERE id = NEW.id;
        ELSE 
            UPDATE public.profiles
            SET email = NEW.email
            WHERE id = NEW.id;            
        END IF;    
    ELSE
        UPDATE public.profiles
        SET email = NEW.email
        WHERE id = NEW.id;
    END IF;
    RETURN new;
END;
$$
;
