CREATE TABLE public.invites
(
    id               uuid    NOT NULL         DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at       timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by       uuid,
    updated_at       timestamptz,
    updated_by       uuid REFERENCES public.profiles,
    is_archived      bool                     DEFAULT FALSE,
    email            varchar NOT NULL,
    project_id       uuid REFERENCES public.projects,
    project_group_id uuid REFERENCES public.project_groups,
    accepted         bool                     DEFAULT FALSE,
    ignored          bool                     DEFAULT FALSE,
    invited_by_name  varchar NOT NULL,
    project_name     varchar NOT NULL
);

-- Changes 7/26/23 --
ALTER TABLE public.invites
    ADD COLUMN is_archived bool DEFAULT FALSE;
