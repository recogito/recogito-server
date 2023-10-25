CREATE TABLE public.roles
(
    id          uuid    NOT NULL         DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                     DEFAULT FALSE,
    name        varchar NOT NULL         DEFAULT '!!!',
    description varchar
);

-- Changes 5/24/23 --
ALTER TABLE public.roles
    ADD CONSTRAINT roles_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 7/26/23 --
ALTER TABLE public.roles
    ADD COLUMN is_archived bool DEFAULT FALSE;
