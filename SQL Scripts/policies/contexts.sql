DROP POLICY IF EXISTS "Users with correct policies can SELECT on contexts" ON public.contexts;

CREATE POLICY "Users with correct policies can SELECT on contexts" ON public.contexts FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        (public.check_action_policy_organization(auth.uid(), 'contexts', 'SELECT') OR
         public.check_action_policy_project(auth.uid(), 'contexts', 'SELECT', project_id) OR
         public.check_action_policy_layer_from_context(auth.uid(), 'contexts', 'SELECT', id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on contexts" ON public.contexts;

CREATE POLICY "Users with correct policies can INSERT on contexts" ON public.contexts FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'contexts', 'INSERT') OR
                public.check_action_policy_project(auth.uid(), 'contexts', 'INSERT', project_id) OR
                public.check_action_policy_layer_from_context(auth.uid(), 'contexts', 'INSERT', id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on contexts" ON public.contexts;

CREATE POLICY "Users with correct policies can UPDATE on contexts" ON public.contexts FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') OR
        public.check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', project_id) OR
        public.check_action_policy_layer_from_context(auth.uid(), 'contexts', 'UPDATE', id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', project_id) OR
                public.check_action_policy_layer_from_context(auth.uid(), 'contexts', 'UPDATE', id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on contexts" ON public.contexts;

CREATE POLICY "Users with correct policies can DELETE on contexts" ON public.contexts FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'contexts', 'DELETE') OR
           public.check_action_policy_project(auth.uid(), 'contexts', 'DELETE', project_id) OR
           public.check_action_policy_layer_from_context(auth.uid(), 'contexts', 'DELETE', id));
