-- function to get library documents:
--   always 1 revision per document (latest)
--   sortable on name, author
--   searchable on name, author
--
-- dynamic SQL so every call is optimized for its scope/sort. the latest-revision filter
-- uses NOT EXISTS to skip rows that have a newer revision.

CREATE OR REPLACE FUNCTION public.get_library_documents_rpc(_collection_id uuid, _user_id uuid, _is_mine boolean DEFAULT false, _search text DEFAULT ''::text, _limit integer DEFAULT 50, _offset integer DEFAULT 0, _sort_by text DEFAULT 'name'::text, _sort_dir text DEFAULT 'asc'::text)
 RETURNS TABLE(id uuid, name character varying, content_type text, created_at timestamp with time zone, created_by uuid, is_private boolean, collection_id uuid, collection_document_id text, revision_number integer, meta_data json, is_document_group boolean, document_group_id uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _scope text;
    _search_filter text := '';
    _sort_col text := CASE WHEN _sort_by = 'author' THEN 'author' ELSE 'name' END;
    _sort_order text := CASE WHEN _sort_dir = 'desc' THEN 'DESC' ELSE 'ASC' END;
BEGIN
    IF _collection_id IS NOT NULL THEN
        -- collection documents
        _scope := '%1$I.collection_id = $1';
    ELSIF _is_mine THEN
        -- my documents
        _scope := '%1$I.collection_id IS NULL AND %1$I.created_by = $2';
    ELSE
        -- all public documents
        _scope := '%1$I.collection_id IS NULL AND %1$I.is_private = false';
    END IF;

    -- search (will use trigram)
    IF _search <> '' THEN
        _search_filter := $s$AND (doc.name ILIKE '%' || $3 || '%' OR doc.author ILIKE '%' || $3 || '%')$s$;
    END IF;

    -- sort and paginate only (id, sort key), then fetch the full rows for that page
    RETURN QUERY EXECUTE format($q$
        WITH page AS (
            SELECT doc.id, doc.%4$I AS sort_key
            FROM documents doc
            WHERE doc.is_archived = false
                AND %1$s
                %3$s
                -- choose the latest revision (revision_number DESC NULLS LAST, created_at DESC, id DESC)
                AND NOT EXISTS (
                    SELECT 1
                    FROM documents newer
                    WHERE newer.is_archived = false
                        AND %2$s
                        AND newer.collection_document_id = doc.collection_document_id
                        AND newer.id <> doc.id
                        AND (
                            (newer.revision_number IS NOT NULL AND doc.revision_number IS NULL)
                            OR newer.revision_number > doc.revision_number
                            OR (
                                newer.revision_number IS NOT DISTINCT FROM doc.revision_number
                                AND (newer.created_at, newer.id) > (doc.created_at, doc.id)
                            )
                        )
                )
            -- sort nulls and empty strings last
            ORDER BY
                (doc.%4$I IS NULL OR doc.%4$I = '') ASC,
                doc.%4$I %5$s,
                doc.id ASC
            LIMIT $4 OFFSET $5
        )
        SELECT
            d.id, d.name, d.content_type::text, d.created_at, d.created_by, d.is_private,
            d.collection_id, d.collection_document_id, d.revision_number, d.meta_data,
            d.is_document_group, d.document_group_id
        FROM page
        JOIN documents d ON d.id = page.id
        ORDER BY
            (page.sort_key IS NULL OR page.sort_key = '') ASC,
            page.sort_key %5$s,
            page.id ASC
    $q$, format(_scope, 'doc'), format(_scope, 'newer'), _search_filter, _sort_col, _sort_order)
    USING _collection_id, _user_id, _search, _limit, _offset;
END;
$function$
;
