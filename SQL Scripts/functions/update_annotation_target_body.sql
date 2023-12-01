CREATE OR REPLACE FUNCTION update_annotation_target_body()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = NOW();
    -- created_at and created_by cannot be changed --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    NEW.updated_by = auth.uid();
    -- increment version ---
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
