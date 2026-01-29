-- Unique index to ensure we don't insert duplicate documents
-- per collection based on the manifest URL
BEGIN;

-- clean up existing duplicates by meta_data.url
WITH duplicates AS (
    SELECT id
    FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY collection_id, (meta_data ->> 'url') 
                   ORDER BY created_at ASC, id ASC
               ) as row_num
        FROM documents
        WHERE collection_id IS NOT NULL 
          AND meta_data ->> 'url' IS NOT NULL
    ) t
    WHERE t.row_num > 1
)
DELETE FROM documents
WHERE id IN (SELECT id FROM duplicates);

-- create a partial UNIQUE INDEX to ignore rows where collection_id is NULL
CREATE UNIQUE INDEX IF NOT EXISTS documents_unique_collection_id_url ON documents (collection_id, ((meta_data ->> 'url'))) WHERE collection_id IS NOT NULL;

COMMIT;
