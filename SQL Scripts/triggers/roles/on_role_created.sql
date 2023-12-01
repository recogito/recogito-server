DROP TRIGGER IF EXISTS on_role_created
    ON public.roles;
CREATE TRIGGER on_role_created
    BEFORE INSERT ON public.roles
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
