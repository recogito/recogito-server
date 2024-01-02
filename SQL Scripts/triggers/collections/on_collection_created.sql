DROP TRIGGER IF EXISTS on_collection_created
    ON public.collections;
CREATE TRIGGER on_collection_created
    BEFORE INSERT ON public.collections
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
