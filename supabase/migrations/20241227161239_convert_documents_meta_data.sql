-- Convert "meta" JSON object to array of objects and update labels
WITH

documents_cte AS (
SELECT documents.id AS document_id,
       json_agg(json_build_object(
         'label',
         CASE
             WHEN x.key = 'author' THEN 'Author'
             WHEN x.key = 'publication_date' THEN 'Publication Date'
             WHEN x.key = 'license' THEN 'License'
             WHEN x.key = 'version' THEN 'Version'
             WHEN x.key = 'copyright' THEN 'Copyright'
             WHEN x.key = 'language' THEN 'Language'
             WHEN x.key = 'source' THEN 'Source'
             WHEN x.key = 'notes' THEN 'Notes'
             WHEN x.key = 'artist' THEN 'Artist'
             WHEN x.key = 'date' THEN 'Date'
             WHEN x.key = 'institution' THEN 'Institution'
             WHEN x.key = 'medium' THEN 'Medium'
             WHEN x.key = 'dimensions' THEN 'Dimensions'
             WHEN x.key = 'credit_line' THEN 'Credit Line'
             WHEN x.key = 'accession_number' THEN 'Accession Number'
             ELSE x.key
         END,
         'value',
         x.value
       )) AS meta
  FROM public.documents
 CROSS JOIN json_each_text(documents.meta_data->'meta') AS x
 WHERE x.value IS NOT NULL
   AND x.value != ''
 GROUP BY documents.id
),

update_documents AS (
UPDATE public.documents
  SET meta_data = jsonb_set(documents.meta_data::jsonb, '{meta}', documents_cte.meta::jsonb, true)
 FROM documents_cte
WHERE documents_cte.document_id = documents.id
RETURNING documents.id
)

UPDATE public.documents
   SET meta_data = documents.meta_data::jsonb - 'meta'
 WHERE documents.id NOT IN ( SELECT documents_cte.document_id
                               FROM documents_cte )
;