CREATE TABLE public.role_policies
(
    id          uuid NOT NULL            DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                     DEFAULT FALSE,
    role_id     uuid REFERENCES public.roles,
    policy_id   uuid REFERENCES public.policies
);

-- Changes 5/24/23 --
ALTER TABLE public.role_policies
    ADD CONSTRAINT role_policies_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- Changes 6/9/23 --
ALTER TABLE public.role_policies
    DROP CONSTRAINT role_policies_role_id_fkey,
    ADD CONSTRAINT role_policies_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles
        ON DELETE CASCADE;

-- Changes 7/26/23 --
ALTER TABLE public.role_policies
    ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 8/7/23
CREATE UNIQUE INDEX role_policies_index_role_id_policy_id ON public.role_policies (role_id, policy_id);
