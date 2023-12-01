CREATE OR REPLACE FUNCTION create_date_and_user()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.created_at = NOW();
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
