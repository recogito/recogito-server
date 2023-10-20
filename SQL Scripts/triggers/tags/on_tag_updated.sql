DROP TRIGGER IF EXISTS on_tag_updated
    ON public.tags;
CREATE TRIGGER on_tag_updated
    BEFORE UPDATE ON public.tags
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
