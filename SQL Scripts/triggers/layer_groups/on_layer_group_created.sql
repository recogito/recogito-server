DROP TRIGGER IF EXISTS on_layer_group_created
    ON public.layer_groups;
CREATE TRIGGER on_layer_group_created
    BEFORE INSERT ON public.layer_groups
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
