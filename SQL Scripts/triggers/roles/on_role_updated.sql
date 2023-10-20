DROP TRIGGER IF EXISTS on_role_updated
    ON public.roles;
CREATE TRIGGER on_role_updated
    BEFORE UPDATE ON public.roles
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
