DROP TRIGGER IF EXISTS on_group_user_updated
    ON public.group_users;
CREATE TRIGGER on_group_user_updated
    BEFORE UPDATE ON public.group_users
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
