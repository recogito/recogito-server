-- documents table --
CREATE TYPE content_types_type AS ENUM ('text/markdown', 'image/jpeg', 'image/tiff', 'image/png', 'image/gif', 'image/jp2', 'application/pdf', 'text/plain', 'application/tei+xml', 'application/xml', 'text/xml' );

CREATE TABLE public.documents
(
    id           uuid               NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at   timestamp WITH TIME ZONE    DEFAULT NOW(),
    created_by   uuid REFERENCES public.profiles,
    updated_at   timestamptz,
    updated_by   uuid REFERENCES public.profiles,
    is_archived  bool                        DEFAULT FALSE,
    name         varchar            NOT NULL,
    bucket_id    text,
    content_type content_types_type NOT NULL,
    meta_data    json DEFAULT {},
    is_private   BOOLEAN DEFAULT TRUE,
    collection_id uuid REFERENCES public.collections,
    collection_metadata json
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