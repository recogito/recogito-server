-- trigger function to set the author on a generated document column from iiif metadata

CREATE TRIGGER on_document_updated_set_author BEFORE INSERT OR UPDATE OF meta_data ON public.documents FOR EACH ROW EXECUTE FUNCTION public.set_document_author();
