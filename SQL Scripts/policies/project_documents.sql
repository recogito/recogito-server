DROP POLICY IF EXISTS "Users with correct policies can SELECT on project_documents" ON public.project_documents;

CREATE POLICY "Users with correct policies can SELECT on project_documents" ON public.project_documents FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        (public.check_action_policy_organization(auth.uid(), 'project_documents', 'SELECT') OR
         public.check_action_policy_project(auth.uid(), 'project_documents', 'SELECT', project_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on project_documents" ON public.project_documents;

CREATE POLICY "Users with correct policies can INSERT on project_documents" ON public.project_documents FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'project_documents', 'INSERT') OR
                public.check_action_policy_project(auth.uid(), 'project_documents', 'INSERT', project_id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on project_documents" ON public.project_documents;

CREATE POLICY "Users with correct policies can UPDATE on project_documents" ON public.project_documents FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'project_documents', 'UPDATE') OR
        public.check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', project_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'project_documents', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', project_id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on project_documents" ON public.project_documents;

CREATE POLICY "Users with correct policies can DELETE on project_documents" ON public.project_documents FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'project_documents', 'DELETE') OR
           public.check_action_policy_project(auth.uid(), 'project_documents', 'DELETE', project_id));
