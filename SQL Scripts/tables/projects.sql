CREATE TABLE public.projects
(
    id                uuid NOT NULL            DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at        timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by        uuid REFERENCES public.profiles,
    updated_at        timestamptz,
    updated_by        uuid REFERENCES public.profiles,
    is_archived       bool                     DEFAULT FALSE,
    name              varchar,
    description       varchar,
    is_system_project bool                     DEFAULT FALSE
);

-- Changes 04/21/23 --
ALTER TABLE public.projects
    ADD COLUMN is_system_project bool DEFAULT FALSE;

-- Changes 05/01/23 --
ALTER TABLE public.projects
    DROP COLUMN is_system_project;

-- Changes 5/24/23 --
ALTER TABLE public.projects
    ADD CONSTRAINT projects_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 7/26/23 --
ALTER TABLE public.projects
    ADD COLUMN is_archived bool DEFAULT FALSE;

