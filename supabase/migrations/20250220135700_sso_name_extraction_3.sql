set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _id UUID;
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    IF NEW.is_sso_user IS TRUE
    AND NEW.raw_user_meta_data->>custom_claims IS NOT NULL 
    AND (NEW.raw_user_meta_data->>custom_claims->>first_name IS NOT NULL 
    OR NEW.raw_user_meta_data->>custom_claims->>last_name IS NOT NULL)
    THEN
        INSERT INTO public.profiles (id, email, first_name, last_name)
        VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>custom_claims->>first_name, NEW.raw_user_meta_data->>custom_claims->>last_name);
    ELSE
        INSERT INTO public.profiles (id, email)
        VALUES (NEW.id, NEW.email);
    END IF;

    
    IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE)
    THEN
        SELECT id INTO _id FROM public.organization_groups WHERE is_default = TRUE;
        INSERT INTO public.group_users (user_id, group_type, type_id) VALUES (NEW.id, 'organization', _id);
    END IF;
    RETURN new;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.is_sso_user IS TRUE
    AND NEW.raw_user_meta_data->>custom_claims IS NOT NULL 
    AND (NEW.raw_user_meta_data->>custom_claims->>first_name IS NOT NULL 
    OR NEW.raw_user_meta_data->>custom_claims->>last_name IS NOT NULL)
    THEN
        UPDATE public.profiles
        SET email = NEW.email,
            first_name = NEW.raw_user_meta_data->>custom_claims->>first_name,
            last_name = NEW.raw_user_meta_data->>custom_claims->>last_name
        WHERE id = NEW.id;
    ELSE
        UPDATE public.profiles
        SET email = NEW.email
        WHERE id = NEW.id;
    END IF;
    RETURN new;
END;
$function$
;


