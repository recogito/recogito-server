CREATE TYPE group_types AS ENUM ('organization', 'project', 'layer');

CREATE TABLE public.group_users
(
    id          uuid                            NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE                 DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                                     DEFAULT FALSE,
    group_type  group_types                     NOT NULL,
    type_id     uuid                            NOT NULL,
    user_id     uuid REFERENCES public.profiles NOT NULL
);

CREATE UNIQUE INDEX group_users_group_id_user_id_idx ON public.group_users (group_id, user_id);

-- Changes 05/08/23 --
CREATE TYPE group_types AS ENUM ('organization', 'project', 'layer');

ALTER TABLE public.group_users
    ADD COLUMN group_type group_types NOT NULL;
ALTER TABLE public.group_users
    DROP COLUMN group_id;
ALTER TABLE public.group_users
    ADD COLUMN group_id uuid NOT NULL;

-- Changes 5/24/23 --
ALTER TABLE public.group_users
    ADD CONSTRAINT group_users_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 6/6/23 --
ALTER TABLE public.group_users
    ADD CONSTRAINT group_users_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups;

-- Changes 6/9/23 --
ALTER TABLE public.group_users
    DROP CONSTRAINT group_users_group_id_fkey,
    ADD CONSTRAINT group_users_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups
        ON DELETE CASCADE;

-- Changes 6/13/23 --
ALTER TABLE public.group_users
    ADD COLUMN type_id uuid NOT NULL;

ALTER TABLE public.group_users
    DROP CONSTRAINT group_users_group_id_fkey;

ALTER TABLE public.group_users
    DROP COLUMN group_id;

-- Changes 7/26/23 --
ALTER TABLE public.group_users
    ADD COLUMN is_archived bool DEFAULT FALSE;
