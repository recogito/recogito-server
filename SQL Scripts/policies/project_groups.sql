DROP POLICY IF EXISTS "Users with correct policies can SELECT on project_groups" ON public.project_groups;

CREATE POLICY "Users with correct policies can SELECT on project_groups" ON public.project_groups FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        (public.check_action_policy_organization(auth.uid(), 'project_groups', 'SELECT') OR
         public.check_action_policy_project(auth.uid(), 'project_groups', 'SELECT', project_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on project_groups" ON public.project_groups;

CREATE POLICY "Users with correct policies can INSERT on project_groups" ON public.project_groups FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'project_groups', 'INSERT') OR
                public.check_action_policy_project(auth.uid(), 'project_groups', 'INSERT', project_id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on project_groups" ON public.project_groups;

CREATE POLICY "Users with correct policies can UPDATE on project_groups" ON public.project_groups FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'project_groups', 'UPDATE') OR
        public.check_action_policy_project(auth.uid(), 'project_groups', 'UPDATE', project_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'project_groups', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'project_groups', 'UPDATE', project_id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on project_groups" ON public.project_groups;

CREATE POLICY "Users with correct policies can DELETE on project_groups" ON public.project_groups FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'project_groups', 'DELETE') OR
           public.check_action_policy_project(auth.uid(), 'project_groups', 'DELETE', project_id));
