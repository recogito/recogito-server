CREATE TABLE public.collections (
    id uuid             DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at          timestamp with time zone DEFAULT now(),
    created_by          uuid,
    updated_at          timestamp with time zone,
    updated_by          uuid,
    name                character varying NOT NULL,
    extension_id        uuid,
    extension_metadata  json,
    custom_css          text,
    is_archived         boolean DEFAULT false,
    document_count      bigint DEFAULT 0
);

-- Changes 01.05.24 --
alter table "public"."collections" add column "custom_css" text;

-- Changes 02.15.24 --
ALTER TABLE public.collections ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;

-- Changes 01.14.26 --
alter table "public"."collections" add column "document_count" bigint default 0;

CREATE INDEX IF NOT EXISTS collection_documents_count_idx ON public.documents USING btree (collection_document_id) WHERE (is_archived = false);
