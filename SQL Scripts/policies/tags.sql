DROP POLICY IF EXISTS "Users with correct policies can SELECT on tags" ON public.tags;

CREATE POLICY "Users with correct policies can SELECT on tags" ON public.tags FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_action_policy_organization(auth.uid(), 'tags', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on tags" ON public.tags;

CREATE POLICY "Users with correct policies can INSERT on tags" ON public.tags FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'tags', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on tags" ON public.tags;

CREATE POLICY "Users with correct policies can UPDATE on tags" ON public.tags FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'tags', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'tags', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on tags" ON public.tags;

CREATE POLICY "Users with correct policies can DELETE on tags" ON public.tags FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'tags', 'DELETE'));
