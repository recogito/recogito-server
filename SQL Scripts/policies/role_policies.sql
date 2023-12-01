DROP POLICY IF EXISTS "Users with correct policies can SELECT on role_policies" ON public.role_policies;

CREATE POLICY "Users with correct policies can SELECT on role_policies" ON public.role_policies FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_action_policy_organization(auth.uid(), 'role_policies', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on role_policies" ON public.role_policies;

CREATE POLICY "Users with correct policies can INSERT on role_policies" ON public.role_policies FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'role_policies', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on role_policies" ON public.role_policies;

CREATE POLICY "Users with correct policies can UPDATE on role_policies" ON public.role_policies FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'role_policies', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'role_policies', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on role_policies" ON public.role_policies;

CREATE POLICY "Users with correct policies can DELETE on role_policies" ON public.role_policies FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'role_policies', 'DELETE'));
