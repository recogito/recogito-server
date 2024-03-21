DROP POLICY IF EXISTS "Users with correct policies can SELECT on annotations" ON public.annotations;

CREATE POLICY "Users with correct policies can SELECT on annotations" ON public.annotations FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_for_private_annotation(auth.uid(), id) AND (
                public.check_action_policy_organization(auth.uid(), 'annotations', 'SELECT') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'SELECT', layer_id) OR
                public.check_action_policy_layer_select(auth.uid(), 'annotations', layer_id)
            ));

DROP POLICY IF EXISTS "Users with correct policies can INSERT on annotations" ON public.annotations;

CREATE POLICY "Users with correct policies can INSERT on annotations" ON public.annotations FOR INSERT TO authenticated
    WITH CHECK (
        public.check_action_policy_organization(auth.uid(), 'annotations', 'INSERT') OR
        public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'INSERT', layer_id) OR
        public.check_action_policy_layer(auth.uid(), 'annotations', 'INSERT', layer_id)
    );

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on annotations" ON public.annotations;

CREATE POLICY "Users with correct policies can UPDATE on annotations" ON public.annotations FOR UPDATE TO authenticated
    USING (
        public.check_for_private_annotation(auth.uid(), id) AND
        (created_by = auth.uid() OR is_admin_layer(auth.uid(), layer_id)) AND (
                public.check_action_policy_organization(auth.uid(), 'annotations', 'UPDATE') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'UPDATE', layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'annotations', 'UPDATE', layer_id)
            ))
    WITH CHECK (public.check_for_private_annotation(auth.uid(), id) AND
                (created_by = auth.uid() OR is_admin_layer(auth.uid(), layer_id)) AND (
                        public.check_action_policy_organization(auth.uid(), 'annotations', 'UPDATE') OR
                        public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'UPDATE', layer_id) OR
                        public.check_action_policy_layer(auth.uid(), 'annotations', 'UPDATE', layer_id)
                    ));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on annotations" ON public.annotations;

CREATE POLICY "Users with correct policies can DELETE on annotations" ON public.annotations FOR DELETE TO authenticated
    USING (public.check_for_private_annotation(auth.uid(), id) AND
           (created_by = auth.uid() OR is_admin_layer(auth.uid(), layer_id)) AND (
                   public.check_action_policy_organization(auth.uid(), 'annotations', 'DELETE') OR
                   public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'DELETE', layer_id) OR
                   public.check_action_policy_layer(auth.uid(), 'annotations', 'DELETE', layer_id)
               ));
