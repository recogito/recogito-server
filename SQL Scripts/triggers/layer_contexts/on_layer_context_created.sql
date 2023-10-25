DROP TRIGGER IF EXISTS on_layer_context_created
    ON public.layer_contexts;
CREATE TRIGGER on_layer_context_created
    BEFORE INSERT ON public.layer_contexts
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
