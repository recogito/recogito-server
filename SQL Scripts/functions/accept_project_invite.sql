CREATE OR REPLACE FUNCTION accept_project_invite()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not create a group_user for the importing user on import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    IF NEW.accepted IS TRUE THEN
        INSERT INTO public.group_users
            (group_type, user_id, type_id)
        VALUES ('project', auth.uid(), NEW.project_group_id);

        PERFORM do_assign_all_check_for_user(NEW.project_id, auth.uid());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
