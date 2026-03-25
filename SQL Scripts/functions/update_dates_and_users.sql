CREATE OR REPLACE FUNCTION update_dates_and_user()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not modify date or user during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    -- These should never change --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

