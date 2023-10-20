CREATE TABLE public.organization_groups
(
    id          uuid                                NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE                     DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                                         DEFAULT FALSE,
    name        varchar                             NOT NULL,
    description varchar,
    role_id     uuid REFERENCES public.roles UNIQUE NOT NULL,
    is_admin    bool DEFAULT FALSE
);

-- Changes 05/08/23
ALTER TABLE public.organization_groups
    ADD COLUMN name varchar NOT NULL;
ALTER TABLE public.organization_groups
    ADD COLUMN description varchar;

-- Changes 5/24/23 --
ALTER TABLE public.organization_groups
    ADD CONSTRAINT organization_groups_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 6/9/23 --
ALTER TABLE public.organization_groups
    DROP CONSTRAINT organization_groups_group_id_fkey,
    ADD CONSTRAINT organization_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups
        ON DELETE CASCADE;

-- Changes 6/13/23 --
ALTER TABLE public.organization_groups
    ADD COLUMN role_id uuid REFERENCES public.roles NOT NULL;

ALTER TABLE public.organization_groups
    DROP CONSTRAINT organization_groups_group_id_fkey;

ALTER TABLE public.organization_groups
    DROP COLUMN group_id;

-- Changes 7/26/23 --
ALTER TABLE public.organization_groups
    ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 8/4/23 --
ALTER TABLE public.organization_groups
    ADD CONSTRAINT role_id_unique UNIQUE (role_id);

-- Changes 10/2/23 --
ALTER TABLE public.organization_groups ADD COLUMN is_admin bool DEFAULT FALSE;
