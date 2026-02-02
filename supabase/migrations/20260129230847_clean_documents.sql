-- remove leading and trailing whitespace from existing records
UPDATE documents
SET 
    name = regexp_replace(name, '^\s+|\s+$', '', 'g'),
    author = regexp_replace(author, '^\s+|\s+$', '', 'g')
WHERE name ~ '^\s|\s$' OR author ~ '^\s|\s$';


-- add trigger to do this on new records
set check_function_bodies = off;

DROP TRIGGER IF EXISTS on_document_before_upsert_sanitize ON public.documents;

DROP FUNCTION IF EXISTS public.sanitize_document_strings();

CREATE OR REPLACE FUNCTION public.sanitize_document_strings()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.name IS NOT NULL THEN
        NEW.name := regexp_replace(NEW.name, '^\s+|\s+$', '', 'g');
    END IF;
    
    IF NEW.author IS NOT NULL THEN
        NEW.author := regexp_replace(NEW.author, '^\s+|\s+$', '', 'g');
    END IF;
    
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER on_document_before_upsert_sanitize BEFORE INSERT OR UPDATE OF name, author ON public.documents FOR EACH ROW EXECUTE FUNCTION public.sanitize_document_strings();
