-- trigger function to set the author on a generated document column* from iiif metadata
-- (*technically not a generated column, but this is the closest we can get w/ json).
-- needed so we can sort/search on author.
alter table "public"."documents" add column IF NOT EXISTS "author" text;
CREATE INDEX IF NOT EXISTS document_library_name_sort_idx ON public.documents (name) WHERE (is_archived = false);
CREATE INDEX IF NOT EXISTS document_library_author_sort_idx ON public.documents (author) WHERE (is_archived = false);

DROP TRIGGER IF EXISTS on_document_updated_set_author ON public.documents;
DROP FUNCTION IF EXISTS public.set_document_author;

set check_function_bodies = off;

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

CREATE TRIGGER on_document_updated_set_author BEFORE INSERT OR UPDATE OF meta_data ON public.documents FOR EACH ROW EXECUTE FUNCTION public.set_document_author();

-- data migration to populate author/artist for existing docs
UPDATE public.documents 
SET author = (
    SELECT elem->>'value'
    FROM json_array_elements(meta_data->'meta') AS elem
    WHERE lower(elem->>'label') IN ('author', 'artist')
    LIMIT 1
)
WHERE is_archived = false 
  AND json_typeof(meta_data->'meta') = 'array';

-- enable trigram search
create extension if not exists "pg_trgm" with schema "public";

CREATE INDEX IF NOT EXISTS idx_documents_search_trgm ON public.documents USING gin (name public.gin_trgm_ops, author public.gin_trgm_ops) WHERE (is_archived = false);

-- function to get library documents:
--   always 1 revision per document (latest)
--   sortable on name, author
--   searchable on name, author
DROP FUNCTION IF EXISTS public.get_library_documents_rpc(_collection_id uuid, _user_id uuid, _is_mine boolean, _search text, _limit integer, _offset integer, _sort_by text, _sort_dir text);

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
