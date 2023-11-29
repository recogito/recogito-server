DROP TRIGGER IF EXISTS on_project_document_created
    ON public.project_documents;
CREATE TRIGGER on_project_document_created
    BEFORE INSERT ON public.project_documents
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();