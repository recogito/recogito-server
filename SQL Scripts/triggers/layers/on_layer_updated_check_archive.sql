DROP TRIGGER IF EXISTS on_layer_updated_check_archive
    ON public.layers;
CREATE TRIGGER on_layer_updated_check_archive
    BEFORE UPDATE ON public.layers
    FOR EACH ROW EXECUTE PROCEDURE check_archive_layer();
