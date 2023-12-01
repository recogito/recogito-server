DROP TRIGGER IF EXISTS on_context_created
    ON public.contexts;
CREATE TRIGGER on_context_created
    BEFORE INSERT ON public.contexts
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
