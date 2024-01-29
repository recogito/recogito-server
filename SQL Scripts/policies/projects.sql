DROP POLICY IF EXISTS "Users with correct policies can SELECT on projects" ON public.projects;

CREATE POLICY "Users with correct policies can SELECT on projects" ON public.projects FOR
SELECT
    TO authenticated USING (
        (
            is_archived IS FALSE
            AND is_open_join IS TRUE
        )
        OR (
            is_archived IS FALSE
            AND (
                public.check_action_policy_organization (auth.uid (), 'projects', 'SELECT')
                OR public.check_action_policy_project (auth.uid (), 'projects', 'SELECT', id)
            )
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on projects" ON public.projects;

CREATE POLICY "Users with correct policies can INSERT on projects" ON public.projects FOR INSERT TO authenticated
WITH
    CHECK (
        public.check_action_policy_organization (auth.uid (), 'projects', 'INSERT')
    );

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on projects" ON public.projects;

CREATE POLICY "Users with correct policies can UPDATE on projects" ON public.projects FOR
UPDATE TO authenticated USING (
    public.check_action_policy_organization (auth.uid (), 'projects', 'UPDATE')
    OR public.check_action_policy_project (auth.uid (), 'projects', 'UPDATE', id)
)
WITH
    CHECK (
        public.check_action_policy_organization (auth.uid (), 'projects', 'UPDATE')
        OR public.check_action_policy_project (auth.uid (), 'projects', 'UPDATE', id)
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on projects" ON public.projects;

CREATE POLICY "Users with correct policies can DELETE on projects" ON public.projects FOR DELETE TO authenticated USING (
    public.check_action_policy_organization (auth.uid (), 'projects', 'DELETE')
);