DROP TRIGGER IF EXISTS on_annotation_updated
    ON public.annotations;
CREATE TRIGGER on_annotation_updated
    BEFORE UPDATE ON public.annotations
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
