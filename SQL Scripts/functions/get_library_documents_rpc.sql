-- function to get library documents:
--   always 1 revision per document (latest)
--   sortable on name, author
--   searchable on name, author

CREATE OR REPLACE FUNCTION public.get_library_documents_rpc(_collection_id uuid, _user_id uuid, _is_mine boolean DEFAULT false, _search text DEFAULT ''::text, _limit integer DEFAULT 50, _offset integer DEFAULT 0, _sort_by text DEFAULT 'name'::text, _sort_dir text DEFAULT 'asc'::text)
 RETURNS TABLE(id uuid, name character varying, content_type text, created_at timestamp with time zone, created_by uuid, is_private boolean, collection_id uuid, collection_document_id text, revision_number integer, meta_data json, is_document_group boolean, document_group_id uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        d.id, d.name, d.content_type::text, d.created_at, d.created_by, d.is_private, 
        d.collection_id, d.collection_document_id, d.revision_number, d.meta_data,
        d.is_document_group, d.document_group_id
    FROM (
        -- only select one revision per document, per collection
        SELECT DISTINCT ON (doc.collection_id, doc.collection_document_id) doc.*
        FROM documents doc
        WHERE doc.is_archived = false
            AND (
            -- my documents
            (_is_mine AND doc.created_by = _user_id AND doc.collection_id IS NULL) OR
            -- collection documents
            (_collection_id IS NOT NULL AND doc.collection_id = _collection_id) OR
            -- all public documents
            (NOT _is_mine AND _collection_id IS NULL AND doc.is_private = false AND doc.collection_id IS NULL)
            )
        -- search (will use trigram)
        AND (
            _search = ''
            OR doc.name ILIKE '%' || _search || '%'
            OR doc.author ILIKE '%' || _search || '%'
        )
        -- choose the latest revision
        ORDER BY
            doc.collection_id,
            doc.collection_document_id,
            doc.revision_number DESC NULLS LAST,
            doc.created_at DESC,
            doc.id DESC
    ) d
    -- allow sorting by sort params
    ORDER BY
        CASE
            WHEN _sort_by = 'name' AND _sort_dir = 'asc' THEN d.name
            WHEN _sort_by = 'author' AND _sort_dir = 'asc' THEN d.author
        END ASC,
        CASE
            WHEN _sort_by = 'name' AND _sort_dir = 'desc' THEN d.name
            WHEN _sort_by = 'author' AND _sort_dir = 'desc' THEN d.author
        END DESC,
        d.id ASC
    LIMIT _limit OFFSET _offset;
    END;
$function$
;
