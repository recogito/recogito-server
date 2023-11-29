CREATE
OR REPLACE FUNCTION public.handle_new_user () RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    _id UUID;
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email);
      IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE)
        THEN
            SELECT id INTO _id FROM public.organization_groups WHERE is_default = TRUE;
            INSERT INTO public.group_users (user_id, group_type, type_id) VALUES (NEW.id, 'organization', _id);
        END IF;
    RETURN new;
END;
$$;

