-- assignments table --
CREATE TABLE
    public.contexts (
        id UUID NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        created_by UUID,
        updated_at timestamptz,
        updated_by UUID REFERENCES public.profiles,
        is_archived bool DEFAULT FALSE,
        NAME VARCHAR,
        description VARCHAR,
        project_id UUID REFERENCES public.projects,
        is_project_default BOOLEAN DEFAULT FALSE,
        assign_all_members BOOLEAN DEFAULT FALSE
    );

-- Changes 04/18/23 --
ALTER TABLE public.assignments
ADD COLUMN project_id UUID REFERENCES public.projects;

-- Changes 05/01/23
ALTER TABLE public.assignments
RENAME TO contexts;

-- Changes 5/24/23 --
ALTER TABLE public.contexts
ADD CONSTRAINT contexts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 6/9/23 --
ALTER TABLE public.contexts
DROP CONSTRAINT contexts_project_id_fkey,
ADD CONSTRAINT contexts_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects ON DELETE CASCADE;

-- Changes 7/26/23 --
ALTER TABLE public.contexts
ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 9/28/23 ---
ALTER TABLE public.contexts
ADD COLUMN description VARCHAR;

-- Changes 1/25/24 --
ALTER TABLE public.contexts
ADD COLUMN is_project_default BOOLEAN DEFAULT FALSE;

-- Changes 11/26/24
ALTER TABLE public.contexts
ADD COLUMN assign_all_members BOOLEAN DEFAULT FALSE;

-- Changes 2/17/25
ALTER TABLE public.contexts 
ADD COLUMN sort INTEGER DEFAULT 0;