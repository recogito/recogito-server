-- tags table --

CREATE TABLE tags
(
    id                uuid NOT NULL            DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at        timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by        uuid REFERENCES public.profiles,
    updated_at        timestamptz,
    updated_by        uuid REFERENCES public.profiles,
    is_archived       bool                     DEFAULT FALSE,
    tag_definition_id uuid REFERENCES public.tag_definitions ON DELETE CASCADE,
    target_id         uuid NOT NULL
);

-- Changes 5/30/23 --
ALTER TABLE public.tags
    ADD COLUMN target_id uuid NOT NULL;

-- Changes 6/9/23 --
ALTER TABLE public.tags
    DROP CONSTRAINT tags_tag_definition_id_fkey,
    ADD CONSTRAINT tags_tag_definition_id_fkey FOREIGN KEY (tag_definition_id) REFERENCES public.tag_definitions
        ON DELETE CASCADE;

-- Changes 7/26/23 --
ALTER TABLE public.tags
    ADD COLUMN is_archived bool DEFAULT FALSE;
