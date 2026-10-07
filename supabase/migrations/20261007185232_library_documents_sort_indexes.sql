-- document library paging: read one page in sort order instead of sorting the whole collection
CREATE INDEX IF NOT EXISTS document_library_collection_name_idx ON public.documents USING btree (collection_id, name, id) WHERE (is_archived = false);
CREATE INDEX IF NOT EXISTS document_library_collection_author_idx ON public.documents USING btree (collection_id, author, id) WHERE (is_archived = false);

-- function to get library documents:
--   always 1 revision per document (latest)
--   sortable on name, author
--   searchable on name, author
--
-- dynamic SQL so every call is optimized for its scope/sort. the latest-revision filter
-- uses NOT EXISTS to skip rows that have a newer revision.
--
-- when browsing, documents with a sort value are read in index order
-- (document_library_collection_*_idx), so a page only touches offset + limit rows instead
-- of the whole collection. documents with an empty or null sort value come last.

CREATE OR REPLACE FUNCTION public.get_library_documents_rpc(_collection_id uuid, _user_id uuid, _is_mine boolean DEFAULT false, _search text DEFAULT ''::text, _limit integer DEFAULT 50, _offset integer DEFAULT 0, _sort_by text DEFAULT 'name'::text, _sort_dir text DEFAULT 'asc'::text)
 RETURNS TABLE(id uuid, name character varying, content_type text, created_at timestamp with time zone, created_by uuid, is_private boolean, collection_id uuid, collection_document_id text, revision_number integer, meta_data json, is_document_group boolean, document_group_id uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _scope text;
    _filters text;
    _latest text;
    _segment text;
    _groups text := '';
    _page text;
    _sort_col text := CASE WHEN _sort_by = 'author' THEN 'author' ELSE 'name' END;
    _sort_order text := CASE WHEN _sort_dir = 'desc' THEN 'DESC' ELSE 'ASC' END;
    _blank_first text := CASE WHEN _sort_dir = 'desc' THEN 'IS NULL' ELSE '= ''''' END;
    _blank_second text := CASE WHEN _sort_dir = 'desc' THEN '= ''''' ELSE 'IS NULL' END;
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

    _filters := 'doc.is_archived = false AND ' || format(_scope, 'doc');

    -- choose the latest revision (revision_number DESC NULLS LAST, created_at DESC, id DESC)
    _latest := format($f$
        NOT EXISTS (
            SELECT 1
            FROM documents newer
            WHERE newer.is_archived = false
                AND %s
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
    $f$, format(_scope, 'newer'));

    IF _search <> '' THEN
        -- search (will use trigram): sort the matches, sorting nulls and empty strings last
        _page := format($p$
            SELECT doc.id, doc.%1$I::text AS sort_key, (doc.%1$I IS NULL OR doc.%1$I = '')::int AS grp
            FROM documents doc
            WHERE %2$s
                AND (doc.name ILIKE '%%' || $3 || '%%' OR doc.author ILIKE '%%' || $3 || '%%')
                AND %3$s
            ORDER BY grp, doc.%1$I %4$s, doc.id ASC
            LIMIT $4 OFFSET $5
        $p$, _sort_col, _filters, _latest, _sort_order);
    ELSE
        -- one query per group (named, blank_first, blank_second), as a format() template:
        -- %1$s = condition on the sort column, %2$s = order, %3$s = limit
        _segment := format($s$
            SELECT doc.id, doc.%1$I::text AS sort_key
            FROM documents doc
            WHERE %2$s AND %3$s AND %%1$s
            ORDER BY %%2$s
            LIMIT %%3$s
        $s$, _sort_col, replace(_filters, '%', '%%'), replace(_latest, '%', '%%'));

        _groups := format($g$
            named AS MATERIALIZED (%1$s),
            -- empty/null sort values: each group is only read if the page reaches it
            blank_first AS MATERIALIZED (%2$s),
            blank_second AS (%3$s),
        $g$,
            -- `> ''` (rather than `<> ''`) lets the index skip empty and null values
            format(_segment, format('doc.%I > %L', _sort_col, ''), format('doc.%I %s, doc.id ASC', _sort_col, _sort_order), '$4 + $5'),
            format(_segment, format('doc.%I %s', _sort_col, _blank_first), 'doc.id ASC',
                'greatest($4 + $5 - (SELECT count(*) FROM named), 0)'),
            format(_segment, format('doc.%I %s', _sort_col, _blank_second), 'doc.id ASC',
                'greatest($4 + $5 - (SELECT count(*) FROM named) - (SELECT count(*) FROM blank_first), 0)'));

        _page := format($p$
            SELECT p.id, p.sort_key, p.grp
            FROM (
                SELECT named.id, named.sort_key, 0 AS grp FROM named
                UNION ALL
                SELECT blank_first.id, blank_first.sort_key, 1 AS grp FROM blank_first
                UNION ALL
                SELECT blank_second.id, blank_second.sort_key, 2 AS grp FROM blank_second
            ) p
            ORDER BY p.grp, p.sort_key %s, p.id ASC
            LIMIT $4 OFFSET $5
        $p$, _sort_order);
    END IF;

    -- fetch the full rows for the page only
    RETURN QUERY EXECUTE format($q$
        WITH %1$s
        page AS (%2$s)
        SELECT
            d.id, d.name, d.content_type::text, d.created_at, d.created_by, d.is_private,
            d.collection_id, d.collection_document_id, d.revision_number, d.meta_data,
            d.is_document_group, d.document_group_id
        FROM page
        JOIN documents d ON d.id = page.id
        ORDER BY page.grp, page.sort_key %3$s, page.id ASC
    $q$, _groups, _page, _sort_order)
    USING _collection_id, _user_id, _search, _limit, _offset;
END;
$function$
;
