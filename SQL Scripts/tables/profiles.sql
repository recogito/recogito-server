-- profiles --
CREATE TYPE profile_role_types AS ENUM('admin', 'teacher', 'user');

CREATE TABLE
    public.profiles (
        id UUID PRIMARY KEY,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        created_by UUID REFERENCES auth.users,
        updated_at timestamptz,
        updated_by UUID REFERENCES auth.users,
        is_archived bool DEFAULT FALSE,
        first_name VARCHAR,
        last_name VARCHAR,
        email VARCHAR,
        nickname VARCHAR,
        avatar_url VARCHAR,
        gdpr_optin BOOLEAN DEFAULT FALSE,
        user_meta_data json
    );

-- Change 04/05/2023
CREATE TYPE profile_role_types AS ENUM('admin', 'teacher', 'user');

ALTER TABLE public.profiles
ADD COLUMN ROLE profile_role_types NOT NULL DEFAULT 'user';

ALTER TYPE profile_role_types
RENAME VALUE 'user' TO 'base_user';

-- Changes 4/20/23
ALTER TABLE public.profiles
DROP CONSTRAINT profiles_id_fkey;

-- Changes 7/26/23 --
ALTER TABLE public.profiles
ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 1/23/24 --
ALTER TABLE public.profiles
ADD COLUMN user_meta_data json;