-- function to update collection document count when documents are added/removed from collection

CREATE OR REPLACE FUNCTION public.sync_collection_document_count()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    has_revision boolean;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        -- handle deletion (archiving; decrement)
        IF (OLD.is_archived = false AND NEW.is_archived = true AND NEW.collection_id IS NOT NULL) THEN
            SELECT EXISTS (
                SELECT 1 FROM public.documents 
                WHERE collection_document_id = NEW.collection_document_id 
                AND collection_id = NEW.collection_id
                AND id != NEW.id 
                AND is_archived = false
            ) INTO has_revision;

            IF NOT has_revision THEN
                UPDATE public.collections SET document_count = document_count - 1 WHERE id = NEW.collection_id;
            END IF;
        
        -- handle un-archiving (increment)
        ELSIF (OLD.is_archived = true AND NEW.is_archived = false AND NEW.collection_id IS NOT NULL) THEN
             SELECT EXISTS (
                SELECT 1 FROM public.documents 
                WHERE collection_document_id = NEW.collection_document_id 
                AND collection_id = NEW.collection_id
                AND id != NEW.id 
                AND is_archived = false
            ) INTO has_revision;

            IF NOT has_revision THEN
                UPDATE public.collections SET document_count = document_count + 1 WHERE id = NEW.collection_id;
            END IF;

        -- handle potential move between collections (possible in sql but not UI)
        ELSIF (OLD.collection_id IS DISTINCT FROM NEW.collection_id AND NEW.is_archived = false) THEN
            IF (OLD.collection_id IS NOT NULL) THEN
                UPDATE public.collections SET document_count = document_count - 1 WHERE id = OLD.collection_id;
            END IF;
            IF (NEW.collection_id IS NOT NULL) THEN
                UPDATE public.collections SET document_count = document_count + 1 WHERE id = NEW.collection_id;
            END IF;
        END IF;

    -- increment on create
    ELSIF (TG_OP = 'INSERT' AND NEW.collection_id IS NOT NULL AND NEW.is_archived = false) THEN
        -- check for other revisions first
        SELECT EXISTS (
            SELECT 1 FROM public.documents 
            WHERE collection_document_id = NEW.collection_document_id 
            AND collection_id = NEW.collection_id
            AND id != NEW.id 
            AND is_archived = false
        ) INTO has_revision;

        -- only increment if no other revisions, since a revision doesn't count as a new doc
        IF NOT has_revision THEN
            UPDATE public.collections SET document_count = document_count + 1 WHERE id = NEW.collection_id;
        END IF;

    -- decrement on actual sql DELETE (possible in sql but not UI)
    ELSIF (TG_OP = 'DELETE' AND OLD.collection_id IS NOT NULL AND OLD.is_archived = false) THEN
        SELECT EXISTS (
            SELECT 1 FROM public.documents 
            WHERE collection_document_id = OLD.collection_document_id 
            AND collection_id = NEW.collection_id
            AND id != OLD.id 
            AND is_archived = false
        ) INTO has_revision;

        IF NOT has_revision THEN
            UPDATE public.collections SET document_count = document_count - 1 WHERE id = OLD.collection_id;
        END IF;
    END IF;

    RETURN NULL;
END;
$function$
;
