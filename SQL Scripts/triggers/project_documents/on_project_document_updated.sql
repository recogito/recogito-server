DROP TRIGGER IF EXISTS on_project_document_updated
    ON public.project_documents;
CREATE TRIGGER on_project_document_updated
    BEFORE INSERT ON public.project_documents
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();