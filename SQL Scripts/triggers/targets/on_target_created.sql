DROP TRIGGER IF EXISTS on_target_created
    ON public.targets;
CREATE TRIGGER on_target_created
    BEFORE INSERT ON public.targets
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
