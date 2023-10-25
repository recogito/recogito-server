DROP TRIGGER IF EXISTS on_group_user_created
    ON public.group_users;
CREATE TRIGGER on_group_user_created
    BEFORE INSERT ON public.group_users
    FOR EACH ROW EXECUTE PROCEDURE create_group_user_with_check();
