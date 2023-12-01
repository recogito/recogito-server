DROP TRIGGER IF EXISTS on_layer_created
    ON public.layers;
CREATE TRIGGER on_layer_created
    BEFORE INSERT ON public.layers
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
