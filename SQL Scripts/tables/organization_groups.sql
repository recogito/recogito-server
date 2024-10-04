CREATE TABLE public .organization_groups (
  id UUID NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES public .profiles,
  updated_at timestamptz,
  updated_by UUID REFERENCES public .profiles,
  is_archived bool DEFAULT FALSE,
  NAME VARCHAR NOT NULL,
  description VARCHAR,
  role_id UUID REFERENCES public .roles UNIQUE NOT NULL,
  is_admin BOOLEAN DEFAULT FALSE,
  is_default BOOLEAN DEFAULT FALSE,
  is_read_only BOOLEAN DEFAULT FALSE
);
-- Changes 05/08/23
ALTER TABLE public .organization_groups
ADD COLUMN NAME VARCHAR NOT NULL;
ALTER TABLE public .organization_groups
ADD COLUMN description VARCHAR;
-- Changes 5/24/23 --
ALTER TABLE public .organization_groups
ADD CONSTRAINT organization_groups_created_by_fkey FOREIGN KEY (created_by) REFERENCES public .profiles (id);
-- Changes 6/9/23 --
ALTER TABLE public .organization_groups DROP CONSTRAINT organization_groups_group_id_fkey,
  ADD CONSTRAINT organization_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public .groups ON
DELETE CASCADE;
-- Changes 6/13/23 --
ALTER TABLE public .organization_groups
ADD COLUMN role_id UUID REFERENCES public .roles NOT NULL;
ALTER TABLE public .organization_groups DROP CONSTRAINT organization_groups_group_id_fkey;
ALTER TABLE public .organization_groups DROP COLUMN group_id;
-- Changes 7/26/23 --
ALTER TABLE public .organization_groups
ADD COLUMN is_archived bool DEFAULT FALSE;
-- Changes 8/4/23 --
ALTER TABLE public .organization_groups
ADD CONSTRAINT role_id_unique UNIQUE (role_id);
-- Changes 10/2/23 --
ALTER TABLE public .organization_groups
ADD COLUMN is_admin bool DEFAULT FALSE;
-- Changes 11/27/23 --
ALTER TABLE public .organization_groups
ADD COLUMN is_default bool DEFAULT FALSE;

-- Changes 9/23/24 --
ALTER TABLE public.organization_groups
ADD COLUMN is_read_only bool DEFAULT FALSE;