-- add an RPC for getting collection documents for the collection management UI.
-- similar to the library one, but simpler (searching but no sorting) and
-- includes revision counts and total result counts.

set check_function_bodies = off;

DROP FUNCTION IF EXISTS public.get_collection_management_documents_rpc(_collection_id uuid, _search text, _limit integer, _offset integer);

CREATE OR REPLACE FUNCTION public.get_collection_management_documents_rpc(_collection_id uuid, _search text DEFAULT ''::text, _limit integer DEFAULT 50, _offset integer DEFAULT 0)
 RETURNS TABLE(id uuid, name character varying, content_type text, revision_count bigint, latest_revision_number integer, collection_metadata json, total_count bigint)
 LANGUAGE plpgsql
AS $function$
 BEGIN
    RETURN QUERY
    WITH grouped_docs AS (
        SELECT 
            d.id,
            d.name,
            d.content_type,
            d.collection_metadata,
            -- calculate total revisions for this document by collection_document_id
            COUNT(*) OVER(PARTITION BY d.collection_document_id) as revision_count,
            -- rank them to find the latest
            ROW_NUMBER() OVER(
                PARTITION BY d.collection_document_id 
                ORDER BY d.revision_number DESC, d.created_at DESC
            ) as rank
        FROM documents d
        WHERE d.is_archived = false
          AND d.collection_id = _collection_id
          AND (
            _search = '' OR 
            d.name ILIKE '%' || _search || '%'
          )
    )
    SELECT 
        gd.id, 
        gd.name, 
        gd.content_type::text, 
        gd.revision_count, 
        (gd.collection_metadata->>'revision_number')::int,
        gd.collection_metadata,
        COUNT(*) OVER() as total_count
    FROM grouped_docs gd
    WHERE gd.rank = 1
    ORDER BY gd.name ASC
    LIMIT _limit OFFSET _offset;
 END;
 $function$
;

-- this one actually didn't change but supabase db diff is saying it doesn't match,
-- so just including it here for my local's sake. (will have no effect elsewhere)

DROP TRIGGER IF EXISTS on_document_updated_update_collection_count ON public.documents;

DROP FUNCTION IF EXISTS public.sync_collection_document_count();

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

CREATE TRIGGER on_document_updated_update_collection_count AFTER INSERT OR DELETE OR UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION public.sync_collection_document_count();
