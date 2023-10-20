DROP POLICY IF EXISTS "Users with correct policies can SELECT on organization_groups" ON public.organization_groups;

CREATE POLICY "Users with correct policies can SELECT on organization_groups" ON public.organization_groups FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_action_policy_organization(auth.uid(), 'organization_groups', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on organization_groups" ON public.organization_groups;

CREATE POLICY "Users with correct policies can INSERT on organization_groups" ON public.organization_groups FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'organization_groups', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on organization_groups" ON public.organization_groups;

CREATE POLICY "Users with correct policies can UPDATE on organization_groups" ON public.organization_groups FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'organization_groups', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'organization_groups', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on organization_groups" ON public.organization_groups;

CREATE POLICY "Users with correct policies can DELETE on organization_groups" ON public.organization_groups FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'organization_groups', 'DELETE'));
