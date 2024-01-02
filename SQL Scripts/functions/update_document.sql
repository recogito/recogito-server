CREATE
OR        REPLACE FUNCTION PUBLIC.UPDATE_DOCUMENT () RETURNS TRIGGER LANGUAGE PLPGSQL SECURITY DEFINER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    -- These should never change --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    IF NEW.is_private = TRUE AND auth.uid() != OLD.created_by THEN
        NEW.is_private = FALSE;
    END IF;
    RETURN NEW;
END;
$$;