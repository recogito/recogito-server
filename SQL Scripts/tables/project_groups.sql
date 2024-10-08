CREATE    TABLE PUBLIC.PROJECT_GROUPS (
          ID UUID NOT NULL DEFAULT UUID_GENERATE_V4 () PRIMARY KEY,
          CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          CREATED_BY UUID REFERENCES PUBLIC.PROFILES,
          UPDATED_AT TIMESTAMPTZ,
          UPDATED_BY UUID REFERENCES PUBLIC.PROFILES,
          IS_ARCHIVED BOOL DEFAULT FALSE,
          PROJECT_ID UUID REFERENCES PUBLIC.PROJECTS ON DELETE CASCADE NOT NULL,
          NAME VARCHAR NOT NULL,
          DESCRIPTION VARCHAR,
          ROLE_ID UUID REFERENCES PUBLIC.ROLES NOT NULL,
          IS_ADMIN BOOL DEFAULT FALSE,
          IS_DEFAULT BOOLEAN DEFAULT FALSE,
          IS_READ_ONLY BOOLEAN DEFAULT FALSE
          );

-- Changes 05/08/23
ALTER     TABLE PUBLIC.PROJECT_GROUPS
ADD       COLUMN NAME VARCHAR NOT NULL;

ALTER     TABLE PUBLIC.PROJECT_GROUPS
ADD       COLUMN DESCRIPTION VARCHAR;

-- Changes 5/24/23 --
ALTER     TABLE PUBLIC.PROJECT_GROUPS
ADD       CONSTRAINT PROJECT_GROUPS_CREATED_BY_FKEY FOREIGN KEY (CREATED_BY) REFERENCES PUBLIC.PROFILES (ID);

-- Changes 6/9/23 --
ALTER     TABLE PUBLIC.PROJECT_GROUPS
DROP      CONSTRAINT PROJECT_GROUPS_PROJECT_ID_FKEY,
ADD       CONSTRAINT PROJECT_GROUPS_PROJECT_ID_FKEY FOREIGN KEY (PROJECT_ID) REFERENCES PUBLIC.PROJECTS ON DELETE CASCADE;

ALTER     TABLE PUBLIC.PROJECT_GROUPS
DROP      CONSTRAINT PROJECT_GROUPS_GROUP_ID_FKEY,
ADD       CONSTRAINT PROJECT_GROUPS_GROUP_ID_FKEY FOREIGN KEY (GROUP_ID) REFERENCES PUBLIC.GROUPS ON DELETE CASCADE;

-- Changes 6/13/23 --
ALTER     TABLE PUBLIC.PROJECT_GROUPS
ADD       COLUMN ROLE_ID UUID REFERENCES PUBLIC.ROLES NOT NULL;

ALTER     TABLE PUBLIC.PROJECT_GROUPS
DROP      CONSTRAINT PROJECT_GROUPS_GROUP_ID_FKEY;

ALTER     TABLE PUBLIC.PROJECT_GROUPS
DROP      COLUMN GROUP_ID;

-- Changes 7/26/23 --
ALTER     TABLE PUBLIC.PROJECT_GROUPS
ADD       COLUMN IS_ARCHIVED BOOL DEFAULT FALSE;

-- Changes 10/2/23 --
ALTER     TABLE PUBLIC.PROJECT_GROUPS
ADD       COLUMN IS_ADMIN BOOL DEFAULT FALSE;

-- Changes 11/30/23 --
ALTER     TABLE PUBLIC.PROJECT_GROUPS
ADD       COLUMN IS_DEFAULT BOOLEAN DEFAULT FALSE;

-- Changed 9/20/24
ALTER TABLE public.project_groups
ADD COLUMN is_read_only BOOLEAN DEFAULT FALSE;