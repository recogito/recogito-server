-- documents table --
CREATE TYPE content_types_type AS ENUM ('text/markdown', 'image/jpeg', 'image/tiff', 'image/png', 'image/gif', 'image/jp2', 'application/pdf', 'text/plain', 'application/tei+xml', 'application/xml', 'text/xml' );

CREATE TABLE public.documents
(
    id                      uuid                        DEFAULT extensions.uuid_generate_v4()   NOT NULL,
    created_at              timestamp with time zone    DEFAULT now(),
    created_by              uuid,
    updated_at              timestamp with time zone,
    updated_by              uuid,
    is_archived             boolean                     DEFAULT false,
    name                    character varying           NOT NULL,
    bucket_id               text,
    content_type            public.content_types_type,
    meta_data               json                        DEFAULT '{}'::json                      NOT NULL,
    is_private              boolean                     DEFAULT true,
    collection_id           uuid,
    collection_metadata     json,
    is_document_group       boolean                     DEFAULT false,
    document_group_id       uuid,
    collection_document_id  text                        GENERATED ALWAYS AS (COALESCE((collection_metadata ->> 'document_id'::text), (id)::text)) STORED,
    revision_number         integer                     GENERATED ALWAYS AS ((NULLIF((collection_metadata ->> 'revision_number'::text), ''::text))::integer) STORED,
    author                  text
);

-- Changes 5/24/23 --
ALTER TABLE public.documents
    ADD CONSTRAINT documents_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 6.5.23 --
ALTER TABLE public.documents
    ADD COLUMN content_type content_types_type NOT NULL;

-- Changes 6/22/23 --
ALTER TABLE public.documents
    DROP CONSTRAINT documents_bucket_id_fkey;

-- Changes 7/26/23 --
ALTER TABLE public.documents
    ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 8/21/23 --
ALTER TABLE public.documents ALTER COLUMN content_type TYPE content_types_type USING content_type::content_types_type;

-- Changes 12/11/23 --
ALTER TABLE public.documents ADD COLUMN is_private BOOLEAN DEFAULT true;

-- Changes 12/20/23 --
ALTER TABLE public.documents ADD COLUMN collection_id uuid REFERENCES public.collections;

ALTER TABLE public.documents ADD COLUMN collection_metadata json;

-- Changes 05/29/25 --
ALTER TABLE public.documents ADD COLUMN is_document_group BOOLEAN DEFAULT FALSE;

ALTER TABLE public.documents ADD COLUMN document_group_id uuid; 

-- Changes 01/14/26 --
-- Unique index to ensure we don't insert duplicate documents per collection based on the manifest URL
CREATE UNIQUE INDEX IF NOT EXISTS documents_unique_collection_id_url ON documents (collection_id, ((meta_data ->> 'url'))) WHERE collection_id IS NOT NULL;

-- add generated columns from collection metadata (doc id, revision number, authorship metadata)
alter table "public"."documents" add column if not exists "collection_document_id" text generated always as (COALESCE((collection_metadata ->> 'document_id'::text), (id)::text)) stored;

alter table "public"."documents" add column if not exists "revision_number" integer generated always as ((NULLIF((collection_metadata ->> 'revision_number'::text), ''::text))::integer) stored;

-- index collection documents for fast retrieval
CREATE INDEX IF NOT EXISTS collection_documents_idx ON public.documents USING btree (collection_id, collection_document_id, revision_number DESC, created_at DESC, id DESC) WHERE (is_archived = false);

-- store and index authorship info (always pulled from iiif, not editable in UI)
alter table "public"."documents" add column IF NOT EXISTS "author" text;
CREATE INDEX IF NOT EXISTS document_library_name_sort_idx ON public.documents (name) WHERE (is_archived = false);
CREATE INDEX IF NOT EXISTS document_library_author_sort_idx ON public.documents (author) WHERE (is_archived = false);
