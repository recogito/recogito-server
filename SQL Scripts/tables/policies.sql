CREATE TYPE operation_types AS ENUM ('SELECT', 'INSERT', 'UPDATE', 'DELETE');

CREATE TABLE public.policies
(
    id          uuid            NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                     DEFAULT FALSE,
    table_name  varchar         NOT NULL,
    operation   operation_types NOT NULL
);

-- Changes 5/24/23 --
ALTER TABLE public.policies
    ADD CONSTRAINT policies_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 7/26/23 --
ALTER TABLE public.policies
    ADD COLUMN is_archived bool DEFAULT FALSE;
