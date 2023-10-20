-- profiles --
CREATE TYPE profile_role_types AS ENUM ('admin','teacher','user');

CREATE TABLE public.profiles
(
    id          uuid PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by  uuid REFERENCES auth.users,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES auth.users,
    is_archived bool                     DEFAULT FALSE,
    first_name  varchar,
    last_name   varchar,
    email       varchar,
    nickname    varchar,
    avatar_url  varchar,
    gdpr_optin  boolean                  DEFAULT FALSE
);

-- Change 04/05/2023
CREATE TYPE profile_role_types AS ENUM ('admin','teacher','user');

ALTER TABLE public.profiles
    ADD COLUMN role profile_role_types NOT NULL DEFAULT 'user';

ALTER TYPE profile_role_types RENAME VALUE 'user' TO 'base_user';

-- Changes 4/20/23
ALTER TABLE public.profiles
    DROP CONSTRAINT profiles_id_fkey;

-- Changes 7/26/23 --
ALTER TABLE public.profiles
    ADD COLUMN is_archived bool DEFAULT FALSE;
