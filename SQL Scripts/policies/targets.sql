DROP POLICY IF EXISTS "Users with correct policies can SELECT on targets" ON public.targets;

CREATE POLICY "Users with correct policies can SELECT on targets" ON public.targets FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        (public.check_for_private_annotation(auth.uid(), annotation_id) AND (
                public.check_action_policy_organization(auth.uid(), 'targets', 'SELECT') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'targets', 'SELECT', layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'targets', 'SELECT', layer_id)))
    );

-- targets can only be placed by the creator of the annotation
DROP POLICY IF EXISTS "Users with correct policies can INSERT on targets" ON public.targets;

CREATE POLICY "Users with correct policies can INSERT on targets" ON public.targets FOR INSERT TO authenticated
    WITH CHECK (public.check_for_creating_user(auth.uid(), annotation_id) AND
                (public.check_action_policy_organization(auth.uid(), 'targets', 'INSERT') OR
                 public.check_action_policy_project_from_layer(auth.uid(), 'targets', 'INSERT', layer_id) OR
                 public.check_action_policy_layer(auth.uid(), 'targets', 'INSERT', layer_id))
    );

-- targets can be updated if you are the creator or have organization or project level policies
DROP POLICY IF EXISTS "Users with correct policies can UPDATE on targets" ON public.targets;

CREATE POLICY "Users with correct policies can UPDATE on targets" ON public.targets FOR UPDATE TO authenticated
    USING (public.check_for_private_annotation(auth.uid(), annotation_id) AND
           (created_by = auth.uid() OR is_admin_layer(auth.uid(), layer_id)) AND
           (
                   (public.check_action_policy_organization(auth.uid(), 'targets', 'UPDATE') OR
                    public.check_action_policy_project_from_layer(auth.uid(), 'targets', 'UPDATE', layer_id))
                   OR
                   (public.check_action_policy_layer(auth.uid(), 'targets', 'UPDATE', layer_id) AND
                    public.check_for_creating_user(auth.uid(), annotation_id))
               )
    )
    WITH CHECK (public.check_for_private_annotation(auth.uid(), annotation_id) AND
                (created_by = auth.uid() OR is_admin_layer(auth.uid(), layer_id)) AND
                (
                        (public.check_action_policy_organization(auth.uid(), 'targets', 'UPDATE') OR
                         public.check_action_policy_project_from_layer(auth.uid(), 'targets', 'UPDATE', layer_id))
                        OR
                        (public.check_action_policy_layer(auth.uid(), 'targets', 'UPDATE', layer_id)) AND
                        public.check_for_creating_user(auth.uid(), annotation_id))
    );

-- targets can be deleted if you are the creator or have organization or project level policies
DROP POLICY IF EXISTS "Users with correct policies can DELETE on targets" ON public.targets;

CREATE POLICY "Users with correct policies can DELETE on targets" ON public.targets FOR DELETE TO authenticated
    USING (public.check_for_private_annotation(auth.uid(), annotation_id) AND (
        (
                public.check_action_policy_organization(auth.uid(), 'targets', 'DELETE') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'targets', 'DELETE', layer_id))
        OR
        (public.check_action_policy_layer(auth.uid(), 'targets', 'DELETE', layer_id)) AND
        public.check_for_creating_user(auth.uid(), annotation_id))
    );
