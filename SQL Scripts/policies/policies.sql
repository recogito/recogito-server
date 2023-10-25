DROP POLICY IF EXISTS "Users with correct policies can SELECT on policies" ON public.policies;

CREATE POLICY "Users with correct policies can SELECT on policies" ON public.policies FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_action_policy_organization(auth.uid(), 'policies', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on policies" ON public.policies;

CREATE POLICY "Users with correct policies can INSERT on policies" ON public.policies FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'policies', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on policies" ON public.policies;

CREATE POLICY "Users with correct policies can UPDATE on policies" ON public.policies FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'policies', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'policies', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on policies" ON public.policies;

CREATE POLICY "Users with correct policies can DELETE on policies" ON public.policies FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'policies', 'DELETE'));
