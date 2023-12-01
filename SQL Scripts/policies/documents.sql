DROP POLICY IF EXISTS "Users with correct policies can SELECT on documents" ON public.documents;

CREATE POLICY "Users with correct policies can SELECT on documents" ON public.documents FOR SELECT TO authenticated
    USING (
            is_archived IS FALSE AND
            (public.check_action_policy_organization(auth.uid(), 'documents', 'SELECT') OR
            public.check_action_policy_project_from_document(auth.uid(), 'documents', 'SELECT', id) OR
            public.check_action_policy_layer_from_document(auth.uid(), 'documents', 'SELECT', id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on documents" ON public.documents;

CREATE POLICY "Users with correct policies can INSERT on documents" ON public.documents FOR INSERT TO authenticated
    WITH CHECK (
        public.check_action_policy_organization(auth.uid(), 'documents', 'INSERT') OR
        public.check_action_policy_project_from_document(auth.uid(), 'documents', 'INSERT', id) OR
        public.check_action_policy_layer_from_document(auth.uid(), 'documents', 'INSERT', id)
    );

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on documents" ON public.documents;

CREATE POLICY "Users with correct policies can UPDATE on documents" ON public.documents FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'documents', 'UPDATE') OR
        public.check_action_policy_project_from_document(auth.uid(), 'documents', 'UPDATE', id) OR
        public.check_action_policy_layer_from_document(auth.uid(), 'documents', 'UPDATE', id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'documents', 'UPDATE') OR
                public.check_action_policy_project_from_document(auth.uid(), 'documents', 'UPDATE', id) OR
                public.check_action_policy_layer_from_document(auth.uid(), 'documents', 'UPDATE', id)
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on documents" ON public.documents;

CREATE POLICY "Users with correct policies can DELETE on documents" ON public.documents FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'documents', 'DELETE') OR
           public.check_action_policy_project_from_document(auth.uid(), 'documents', 'DELETE', id) OR
           public.check_action_policy_layer_from_document(auth.uid(), 'documents', 'DELETE', id)
    );
