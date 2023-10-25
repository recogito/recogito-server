CREATE OR REPLACE FUNCTION update_profile()
    RETURNS trigger AS
$$
BEGIN
    -- id's cannot be changed
    NEW.id = OLD.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
