DROP POLICY IF EXISTS "Users with correct policies can SELECT on roles" ON public.roles;

CREATE POLICY "Users with correct policies can SELECT on roles" ON public.roles FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_action_policy_organization(auth.uid(), 'roles', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on roles" ON public.roles;

CREATE POLICY "Users with correct policies can INSERT on roles" ON public.roles FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'roles', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on roles" ON public.roles;

CREATE POLICY "Users with correct policies can UPDATE on roles" ON public.roles FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'roles', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'roles', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on roles" ON public.roles;

CREATE POLICY "Users with correct policies can DELETE on roles" ON public.roles FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'roles', 'DELETE'));
