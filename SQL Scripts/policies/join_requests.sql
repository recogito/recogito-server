DROP POLICY IF EXISTS "Users with correct policies can SELECT on join_requests" ON public.join_requests;

CREATE POLICY "Users with correct policies can SELECT on join_requests" ON public.join_requests FOR SELECT TO authenticated
    USING (
        (public.check_action_policy_organization(auth.uid(), 'join_requests', 'SELECT') OR
         public.check_action_policy_project(auth.uid(), 'join_requests', 'SELECT', project_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on join_requests" ON public.join_requests;

CREATE POLICY "Users with correct policies can INSERT on join_requests" ON public.join_requests FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'join_requests', 'INSERT') OR
                public.check_action_policy_project(auth.uid(), 'join_requests', 'INSERT', project_id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on join_requests" ON public.join_requests;

CREATE POLICY "Users with correct policies can UPDATE on join_requests" ON public.join_requests FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'join_requests', 'UPDATE') OR
        public.check_action_policy_project(auth.uid(), 'join_requests', 'UPDATE', project_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'join_requests', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'join_requests', 'UPDATE', project_id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on join_requests" ON public.join_requests;

CREATE POLICY "Users with correct policies can DELETE on join_requests" ON public.join_requests FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'join_requests', 'DELETE') OR
           public.check_action_policy_project(auth.uid(), 'join_requests', 'DELETE', project_id));
