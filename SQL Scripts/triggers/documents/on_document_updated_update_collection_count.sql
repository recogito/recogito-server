-- trigger to sync collection counter cache when documents change

CREATE TRIGGER on_document_updated_update_collection_count AFTER INSERT OR DELETE OR UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION public.sync_collection_document_count();
