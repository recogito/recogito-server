-- tag_definitions table --
CREATE TYPE tag_scope_types AS ENUM ('system', 'organization', 'project');

CREATE TYPE tag_target_types AS ENUM ('project', 'group', 'document', 'context', 'layer', 'profile');

CREATE TABLE tag_definitions
(
    id          uuid            NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                     DEFAULT FALSE,
    name        varchar         NOT NULL,
    target_type tag_target_types NOT NULL,
    scope       tag_scope_types NOT NULL,
    scope_id    uuid,
    metadata    json            NOT NULL    DEFAULT {}
);

-- Changes 05/26/23 --
ALTER TYPE tag_scope_types ADD VALUE IF NOT EXISTS 'system' BEFORE 'organization';

ALTER TABLE public.tag_definitions
    ALTER COLUMN target_type TYPE tag_target_types USING (target_type::tag_scope_types);

-- Changes 7/26/23 --
ALTER TABLE public.tag_definitions
    ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 10/24/24
ALTER TABLE public.tag_definitions
    ADD COLUMN metadata json NOT NULL DEFAULT '{}';
