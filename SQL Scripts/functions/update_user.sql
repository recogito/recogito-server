CREATE
OR REPLACE FUNCTION public.update_user () RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    UPDATE public.profiles
    SET email = NEW.email, user_meta_data = NEW.raw_user_meta_data
    WHERE id = NEW.id;
        RETURN new;
END;
$$;