CREATE OR REPLACE FUNCTION create_dates_and_user()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not modify date or user during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    NEW.created_at = NOW();
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
