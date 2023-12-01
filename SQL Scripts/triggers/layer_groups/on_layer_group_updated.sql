DROP TRIGGER IF EXISTS on_layer_group_updated
    ON public.layer_groups;
CREATE TRIGGER on_layer_group_updated
    BEFORE UPDATE ON public.layer_groups
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
