DROP POLICY IF EXISTS "Users with correct policies can SELECT on invites" ON public.invites;

CREATE POLICY "Users with correct policies can SELECT on invites" ON public.invites FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        (public.check_action_policy_organization(auth.uid(), 'invites', 'SELECT') OR
         public.check_action_policy_project(auth.uid(), 'invites', 'SELECT', project_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on invites" ON public.invites;

CREATE POLICY "Users with correct policies can INSERT on invites" ON public.invites FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'invites', 'INSERT') OR
                public.check_action_policy_project(auth.uid(), 'invites', 'INSERT', project_id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on invites" ON public.invites;

CREATE POLICY "Users with correct policies can UPDATE on invites" ON public.invites FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'invites', 'UPDATE') OR
        public.check_action_policy_project(auth.uid(), 'invites', 'UPDATE', project_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'invites', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'invites', 'UPDATE', project_id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on invites" ON public.invites;

CREATE POLICY "Users with correct policies can DELETE on invites" ON public.invites FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'invites', 'DELETE') OR
           public.check_action_policy_project(auth.uid(), 'invites', 'DELETE', project_id));
