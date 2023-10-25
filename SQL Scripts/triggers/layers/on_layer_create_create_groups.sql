DROP TRIGGER IF EXISTS on_layer_created_create_groups
    ON public.layers;
CREATE TRIGGER on_layer_created_create_groups
    AFTER INSERT ON public.layers
    FOR EACH ROW EXECUTE PROCEDURE create_default_layer_groups();
