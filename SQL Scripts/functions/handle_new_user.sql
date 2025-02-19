CREATE
OR REPLACE FUNCTION public.handle_new_user () RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    _id UUID;
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    IF NEW.is_sso_user 
    AND (NEW.raw_user_meta_data->custom_claims->first_name OR NEW.raw_user_meta_data->custom_claims->last_name)
    THEN
        INSERT INTO public.profiles (id, email, first_name, last_name)
        VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->custom_claims->first_name, NEW.raw_user_meta_data->custom_claims->last_name);
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
$$;

