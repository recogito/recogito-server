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
