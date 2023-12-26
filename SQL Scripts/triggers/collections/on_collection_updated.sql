DROP TRIGGER IF EXISTS on_collection_updated
    ON public.collections;
CREATE TRIGGER on_collection_updated
    BEFORE UPDATE ON public.collections
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
