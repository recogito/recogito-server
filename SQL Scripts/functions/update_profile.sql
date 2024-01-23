CREATE
OR REPLACE FUNCTION update_profile () RETURNS TRIGGER AS $$
BEGIN
    -- id's cannot be changed
    NEW.id = OLD.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;