DROP TRIGGER IF EXISTS on_role_policy_created
    ON public.role_policies;
CREATE TRIGGER on_role_policy_created
    BEFORE INSERT ON public.role_policies
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
