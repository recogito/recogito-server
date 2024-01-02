DROP POLICY IF EXISTS "Users with correct policies can SELECT on collections" ON public.collections;

CREATE POLICY "Users with correct policies can SELECT on collections" ON public.collections FOR SELECT TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'collections', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on collections" ON public.collections;

CREATE POLICY "Users with correct policies can INSERT on collections" ON public.collections FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'collections', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on collections" ON public.collections;

CREATE POLICY "Users with correct policies can UPDATE on collections" ON public.collections FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'collections', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'collections', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on collections" ON public.collections;

CREATE POLICY "Users with correct policies can DELETE on collections" ON public.collections FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'collections', 'DELETE'));
