DROP POLICY IF EXISTS "Users with correct policies can SELECT on installed_plugins" ON public.installed_plugins;

CREATE POLICY "Users with correct policies can SELECT on installed_plugins" ON public.installed_plugins FOR SELECT TO authenticated
    USING (
        (public.check_action_policy_organization(auth.uid(), 'installed_plugins', 'SELECT') OR
         public.check_action_policy_project(auth.uid(), 'installed_plugins', 'SELECT', project_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on installed_plugins" ON public.installed_plugins;

CREATE POLICY "Users with correct policies can INSERT on installed_plugins" ON public.installed_plugins FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'installed_plugins', 'INSERT') OR
                public.check_action_policy_project(auth.uid(), 'installed_plugins', 'INSERT', project_id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on installed_plugins" ON public.installed_plugins;

CREATE POLICY "Users with correct policies can UPDATE on installed_plugins" ON public.installed_plugins FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'installed_plugins', 'UPDATE') OR
        public.check_action_policy_project(auth.uid(), 'installed_plugins', 'UPDATE', project_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'installed_plugins', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'installed_plugins', 'UPDATE', project_id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on installed_plugins" ON public.installed_plugins;

CREATE POLICY "Users with correct policies can DELETE on installed_plugins" ON public.installed_plugins FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'installed_plugins', 'DELETE') OR
           public.check_action_policy_project(auth.uid(), 'installed_plugins', 'DELETE', project_id));
