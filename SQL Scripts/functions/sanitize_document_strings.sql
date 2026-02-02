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