CREATE TYPE default_group_types AS ENUM ('project', 'layer');

CREATE TABLE public.default_groups
(
    id          uuid                         NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE              DEFAULT NOW(),
    created_by  uuid,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                                  DEFAULT FALSE,
    group_type  default_group_types          NOT NULL,
    name        varchar                      NOT NULL,
    description varchar                      NOT NULL,
    role_id     uuid REFERENCES public.roles NOT NULL,
    is_admin    bool                                  DEFAULT FALSE,
    is_default  bool                                  DEFAULT FALSE
);

-- Changes 6/6/23 --
ALTER TABLE public.default_groups
    ADD COLUMN is_admin bool DEFAULT FALSE;
ALTER TABLE public.default_groups
    ADD COLUMN is_default bool DEFAULT FALSE;

-- Changes 7/26/23 --
ALTER TABLE public.default_groups
    ADD COLUMN is_archived bool DEFAULT FALSE;
