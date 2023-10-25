DROP TRIGGER IF EXISTS on_role_policy_updated
    ON public.role_policies;
CREATE TRIGGER on_role_policy_updated
    BEFORE UPDATE ON public.role_policies
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
