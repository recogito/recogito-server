DROP TRIGGER IF EXISTS on_layer_context_updated
    ON public.layer_contexts;
CREATE TRIGGER on_layer_context_updated
    BEFORE UPDATE ON public.layer_contexts
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
