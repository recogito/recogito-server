CREATE OR REPLACE FUNCTION update_dates_and_user()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    -- These should never change --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

