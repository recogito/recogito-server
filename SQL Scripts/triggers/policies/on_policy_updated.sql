DROP TRIGGER IF EXISTS on_policy_updated
    ON public.policies;
CREATE TRIGGER on_policy_updated
    BEFORE UPDATE ON public.policies
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
