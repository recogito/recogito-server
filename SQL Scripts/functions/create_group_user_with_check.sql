CREATE OR REPLACE FUNCTION create_group_user_with_check()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not modify date or user during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;

    IF public.check_for_group_membership(NEW.user_id, NEW.group_type, NEW.type_id) IS TRUE THEN
        RETURN NULL;
    END IF;
    NEW.created_at = NOW();
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
