DROP TRIGGER IF EXISTS on_tag_created
    ON public.tags;
CREATE TRIGGER on_tag_created
    BEFORE INSERT ON public.tags
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
