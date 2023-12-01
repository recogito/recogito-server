DROP POLICY IF EXISTS "Users with correct policies can SELECT on layers" ON public.layers;

CREATE POLICY "Users with correct policies can SELECT on layers" ON public.layers FOR SELECT TO authenticated
    USING (
            is_archived IS FALSE AND
            (public.check_action_policy_organization(auth.uid(), 'layers', 'SELECT') OR
            public.check_action_policy_project(auth.uid(), 'layers', 'SELECT', project_id) OR
            public.check_action_policy_layer(auth.uid(), 'layers', 'SELECT', id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on layers" ON public.layers;

CREATE POLICY "Users with correct policies can INSERT on layers" ON public.layers FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'layers', 'INSERT') OR
                public.check_action_policy_project(auth.uid(), 'layers', 'INSERT', project_id) OR
                public.check_action_policy_layer(auth.uid(), 'layers', 'INSERT', id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on layers" ON public.layers;

CREATE POLICY "Users with correct policies can UPDATE on layers" ON public.layers FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'layers', 'UPDATE') OR
        public.check_action_policy_project(auth.uid(), 'layers', 'UPDATE', project_id) OR
        public.check_action_policy_layer(auth.uid(), 'layers', 'UPDATE', id)
    )
    WITH CHECK (PUBLIC.check_action_policy_organization(auth.uid(), 'layers', 'UPDATE') OR
                PUBLIC.check_action_policy_project(auth.uid(), 'layers', 'UPDATE', project_id) OR
                PUBLIC.check_action_policy_layer(auth.uid(), 'layers', 'UPDATE', id)
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on layers" ON public.layers;

CREATE POLICY "Users with correct policies can DELETE on layers" ON public.layers FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'layers', 'DELETE') OR
           public.check_action_policy_project(auth.uid(), 'layers', 'DELETE', project_id) OR
           public.check_action_policy_layer(auth.uid(), 'layers', 'DELETE', id)
    );
