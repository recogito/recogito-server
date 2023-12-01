-- layers table --
CREATE TABLE public.layers
(
    id          uuid                            NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE                 DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                                     DEFAULT FALSE,
    document_id uuid REFERENCES public.documents ON DELETE CASCADE,
    project_id  uuid REFERENCES public.projects NOT NULL,
    name        varchar,
    description varchar
);

-- Changes 05/23/23 --
ALTER TABLE public.layers
    ADD COLUMN document_id uuid REFERENCES public.documents;

-- Changes 5/24/23 --
ALTER TABLE public.layers
    ADD CONSTRAINT layers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 6/6/23 --
ALTER TABLE public.layers
    DROP CONSTRAINT layers_context_id_fkey;

ALTER TABLE public.layers
    DROP COLUMN context_id;

-- Changes 6/9/23 --
ALTER TABLE public.layers
    DROP CONSTRAINT layers_document_id_fkey,
    ADD CONSTRAINT layers_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents
        ON DELETE CASCADE;

-- Changes 6/15/23 --
ALTER TABLE public.layers
    ADD COLUMN project_id uuid REFERENCES public.projects NOT NULL;

-- Changes 7/26/23 --
ALTER TABLE public.layers
    ADD COLUMN is_archived bool DEFAULT FALSE;
