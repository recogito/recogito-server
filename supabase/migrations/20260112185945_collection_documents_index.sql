-- add generated columns from collection metadata (doc id, revision number, authorship metadata)
alter table "public"."documents" add column if not exists "collection_document_id" text generated always as (COALESCE((collection_metadata ->> 'document_id'::text), (id)::text)) stored;

alter table "public"."documents" add column if not exists "revision_number" integer generated always as ((NULLIF((collection_metadata ->> 'revision_number'::text), ''::text))::integer) stored;

-- index collection documents for fast retrieval
CREATE INDEX IF NOT EXISTS collection_documents_idx ON public.documents USING btree (collection_id, collection_document_id, revision_number DESC, created_at DESC, id DESC) WHERE (is_archived = false);