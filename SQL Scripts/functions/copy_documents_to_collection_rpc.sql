CREATE OR REPLACE FUNCTION copy_documents_to_collection_rpc(
    _collection_id uuid,
    _document_ids uuid[]
)
RETURNS TABLE (
    original_document_id uuid,
    id uuid,
    collection_id uuid,
    name varchar,
    bucket_id text,
    content_type content_types_type,
    collection_metadata json
)
AS $body$
BEGIN
    RETURN QUERY
    WITH original_documents AS (
        SELECT
            documents.id AS original_document_id,
            -- generate new document id per document
            gen_random_uuid() AS new_id,
            documents.name,
            documents.bucket_id,
            documents.content_type,
            documents.meta_data,
            -- generate new collection-document-id per document (should not use new_id)
            json_build_object(
                'revision_number', 1,
                'document_id', _collection_id::text || '_' || gen_random_uuid()::text
            ) as new_collection_metadata
        FROM documents
        WHERE documents.id = ANY(_document_ids)
    ),
    new_documents AS (
        INSERT INTO documents (
            id,
            name,
            bucket_id,
            content_type,
            meta_data,
            collection_id,
            is_private,
            collection_metadata
        )
        SELECT
            od.new_id,
            od.name,
            od.bucket_id,
            od.content_type,
            od.meta_data,
            _collection_id,
            FALSE,
            od.new_collection_metadata
        FROM original_documents od
    )
    SELECT
        od.original_document_id,
        od.new_id,
        _collection_id,
        od.name,
        od.bucket_id,
        od.content_type,
        od.new_collection_metadata
    FROM original_documents od;
END 
$body$ LANGUAGE plpgsql SECURITY DEFINER;
