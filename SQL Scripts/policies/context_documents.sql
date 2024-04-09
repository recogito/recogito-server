DROP POLICY IF EXISTS "Users with correct policies can SELECT on context_documents" ON public.context_documents;

CREATE POLICY "Users with correct policies can SELECT on context_documents" ON public.context_documents FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        (public.check_action_policy_organization(auth.uid(), 'context_documents', 'SELECT') OR
         public.check_action_policy_project_from_context(auth.uid(), 'context_documents', 'SELECT', context_id) OR
         public.check_action_policy_layer_from_context_select(auth.uid(), 'context_documents', context_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on context_documents" ON public.context_documents;

CREATE POLICY "Users with correct policies can INSERT on context_documents" ON public.context_documents FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'context_documents', 'INSERT') OR
                public.check_action_policy_project_from_context(auth.uid(), 'context_documents', 'INSERT', context_id) OR 
                public.check_action_policy_layer_from_context(auth.uid(), 'context_documents', 'INSERT', context_id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on context_documents" ON public.context_documents;

CREATE POLICY "Users with correct policies can UPDATE on context_documents" ON public.context_documents FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'context_documents', 'UPDATE') OR
        public.check_action_policy_project_from_context(auth.uid(), 'context_documents', 'UPDATE', context_id) OR
        public.check_action_policy_layer_from_context(auth.uid(), 'context_documents', 'UPDATE', context_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'context_documents', 'UPDATE') OR
                public.check_action_policy_project_from_context(auth.uid(), 'context_documents', 'UPDATE', context_id) OR
                public.check_action_policy_layer_from_context(auth.uid(), 'context_documents', 'UPDATE', context_id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on context_documents" ON public.context_documents;

CREATE POLICY "Users with correct policies can DELETE on context_documents" ON public.context_documents FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'context_documents', 'DELETE') OR
           public.check_action_policy_project_from_context(auth.uid(), 'context_documents', 'DELETE', context_id) OR 
           public.check_action_policy_layer_from_context(auth.uid(), 'context_documents', 'DELETE', context_id));
