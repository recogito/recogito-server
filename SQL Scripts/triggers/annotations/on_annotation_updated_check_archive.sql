DROP TRIGGER IF EXISTS on_annotation_updated_check_archive
    ON public.annotations;
CREATE TRIGGER on_annotation_updated_check_archive
    BEFORE UPDATE ON public.annotations
    FOR EACH ROW EXECUTE PROCEDURE check_archive_annotation();
