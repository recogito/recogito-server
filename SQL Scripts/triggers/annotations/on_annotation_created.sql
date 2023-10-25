DROP TRIGGER IF EXISTS on_annotation_created
    ON public.annotations;
CREATE TRIGGER on_annotation_created
    BEFORE INSERT ON public.annotations
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
