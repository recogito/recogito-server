DROP TRIGGER IF EXISTS on_policy_created
    ON public.policies;
CREATE TRIGGER on_policy_created
    BEFORE INSERT ON public.policies
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
