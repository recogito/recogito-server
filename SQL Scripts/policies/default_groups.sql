DROP POLICY IF EXISTS "Users with correct policies can SELECT on default_groups" ON public.default_groups;

CREATE POLICY "Users with correct policies can SELECT on default_groups" ON public.default_groups FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_action_policy_organization(auth.uid(), 'default_groups', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on default_groups" ON public.default_groups;

CREATE POLICY "Users with correct policies can INSERT on default_groups" ON public.default_groups FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'default_groups', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on default_groups" ON public.default_groups;

CREATE POLICY "Users with correct policies can UPDATE on default_groups" ON public.default_groups FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'default_groups', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'default_groups', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on default_groups" ON public.default_groups;

CREATE POLICY "Users with correct policies can DELETE on default_groups" ON public.default_groups FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'default_groups', 'DELETE'));
