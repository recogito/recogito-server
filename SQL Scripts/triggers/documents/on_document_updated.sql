DROP TRIGGER IF EXISTS on_document_updated
    ON public.documents;
CREATE TRIGGER on_document_updated
    BEFORE UPDATE ON public.documents
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
