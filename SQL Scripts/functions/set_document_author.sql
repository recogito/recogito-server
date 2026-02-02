-- function to set the author on a generated document column from iiif metadata
CREATE OR REPLACE FUNCTION public.set_document_author()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- clear old value if present
    NEW.author := NULL;
    -- handle meta_data not being an actual json array; unlikely but could happen
    IF json_typeof(NEW.meta_data->'meta') = 'array' THEN
       -- find the author/artist value from iiif
        NEW.author := (
            SELECT elem->>'value'
            FROM json_array_elements(NEW.meta_data->'meta') AS elem
            WHERE lower(elem->>'label') IN ('author', 'artist')
            LIMIT 1
        );
    END IF;
    RETURN NEW;
END;
$function$
;
