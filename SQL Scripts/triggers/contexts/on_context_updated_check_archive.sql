DROP TRIGGER IF EXISTS on_context_updated_check_archive
    ON public.contexts;
CREATE TRIGGER on_context_updated_check_archive
    BEFORE UPDATE ON public.contexts
    FOR EACH ROW EXECUTE PROCEDURE check_archive_context();
