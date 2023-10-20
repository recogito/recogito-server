DROP TRIGGER IF EXISTS on_document_created
    ON public.documents;
CREATE TRIGGER on_document_created
    BEFORE INSERT ON public.documents
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
