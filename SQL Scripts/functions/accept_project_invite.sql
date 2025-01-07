CREATE OR REPLACE FUNCTION accept_project_invite()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.accepted IS TRUE THEN
        INSERT INTO public.group_users
            (group_type, user_id, type_id)
        VALUES ('project', auth.uid(), NEW.project_group_id);

        PERFORM do_assign_all_check_for_user(NEW.project_id, auth.uid());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
