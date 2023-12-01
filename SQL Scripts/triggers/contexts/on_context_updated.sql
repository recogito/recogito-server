DROP TRIGGER IF EXISTS on_context_updated
    ON public.contexts;
CREATE TRIGGER on_context_updated
    BEFORE UPDATE ON public.contexts
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
