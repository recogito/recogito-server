DROP POLICY IF EXISTS "Users with correct policies can SELECT on layer_contexts" ON public.layer_contexts;

CREATE POLICY "Users with correct policies can SELECT on layer_contexts" ON public.layer_contexts FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND (
            public.check_action_policy_organization(auth.uid(), 'layer_contexts', 'SELECT') OR
            public.check_action_policy_project_from_context(auth.uid(), 'layer_contexts', 'SELECT', context_id) OR
            public.check_action_policy_layer(auth.uid(), 'layer_contexts', 'SELECT', layer_id)
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on layer_contexts" ON public.layer_contexts;

CREATE POLICY "Users with correct policies can INSERT on layer_contexts" ON public.layer_contexts FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'layer_contexts', 'INSERT') OR
                public.check_action_policy_project_from_context(auth.uid(), 'layer_contexts', 'INSERT', context_id) OR
                public.check_action_policy_layer(auth.uid(), 'layer_contexts', 'INSERT', layer_id)
    );

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on layer_contexts" ON public.layer_contexts;

CREATE POLICY "Users with correct policies can UPDATE on layer_contexts" ON public.layer_contexts FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'layer_contexts', 'UPDATE') OR
        public.check_action_policy_project_from_context(auth.uid(), 'layer_contexts', 'UPDATE', context_id) OR
        public.check_action_policy_layer(auth.uid(), 'layer_contexts', 'UPDATE', layer_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'layer_contexts', 'UPDATE') OR
                public.check_action_policy_project_from_context(auth.uid(), 'layer_contexts', 'UPDATE', context_id) OR
                public.check_action_policy_layer(auth.uid(), 'layer_contexts', 'UPDATE', layer_id)
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on layer_contexts" ON public.layer_contexts;

CREATE POLICY "Users with correct policies can DELETE on layer_contexts" ON public.layer_contexts FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'layer_contexts', 'DELETE') OR
           public.check_action_policy_project_from_context(auth.uid(), 'layer_contexts', 'DELETE', context_id) OR
           public.check_action_policy_layer(auth.uid(), 'layer_contexts', 'DELETE', layer_id)
    );
