DROP TRIGGER IF EXISTS on_layer_updated
    ON public.layers;
CREATE TRIGGER on_layer_updated
    BEFORE UPDATE ON public.layers
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
