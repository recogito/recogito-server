-- Unique index to ensure we don't insert duplicate documents
-- per collection based on the manifest URL
CREATE UNIQUE INDEX IF NOT EXISTS documents_unique_collection_id_url ON documents (collection_id, ((meta_data ->> 'url')));
