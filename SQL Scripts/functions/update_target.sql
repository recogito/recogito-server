CREATE OR REPLACE FUNCTION update_annotation()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = NOW();
    NEW.created_at = OLD.created_at;
    NEW.created_by = auth.uid();
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
