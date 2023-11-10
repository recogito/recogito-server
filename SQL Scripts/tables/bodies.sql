-- bodies table --
CREATE TYPE body_types AS ENUM ('TextualBody');

CREATE TYPE body_formats AS ENUM ('TextPlain', 'TextHtml', 'Quill');

CREATE TABLE bodies
(
    id            uuid                          NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at    timestamp WITH TIME ZONE               DEFAULT NOW(),
    created_by    uuid REFERENCES public.profiles,
    updated_at    timestamptz,
    updated_by    uuid REFERENCES public.profiles,
    is_archived   bool                                   DEFAULT FALSE,
    version       int4 GENERATED ALWAYS AS IDENTITY (START WITH 1),
    annotation_id uuid REFERENCES public.annotations ON DELETE CASCADE,
    type          body_types,
    language      varchar,
    format        body_formats,
    purpose       varchar,
    value         text,
    layer_id      uuid REFERENCES public.layers NOT NULL
);

-- Changes 4/12/23 --
ALTER TABLE public.bodies
    DROP CONSTRAINT bodies_annotation_id_fkey,
    ADD CONSTRAINT bodies_annotation_id_fkey
        FOREIGN KEY (annotation_id)
            REFERENCES public.annotations
            ON DELETE CASCADE;

-- Changes 5/24/23 --
ALTER TABLE public.bodies
    DROP CONSTRAINT bodies_created_by_fkey;
ALTER TABLE public.bodies
    ADD CONSTRAINT bodies_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles (id);
ALTER TABLE public.bodies
    ADD CONSTRAINT bodies_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 5/24/23 --
ALTER TABLE public.bodies
    ADD COLUMN layer_id uuid REFERENCES public.layers;

-- Changes 7/26/23 --
ALTER TABLE public.bodies
    ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 11/10/23 ---
ALTER TYPE body_formats ADD VALUE 'Quill';
