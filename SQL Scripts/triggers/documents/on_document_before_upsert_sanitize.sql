-- remove leading and trailing whitespace from records

CREATE TRIGGER on_document_before_upsert_sanitize BEFORE INSERT OR UPDATE OF name, author ON public.documents FOR EACH ROW EXECUTE FUNCTION public.sanitize_document_strings();
