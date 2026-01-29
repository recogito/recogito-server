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