DROP POLICY IF EXISTS "Users with correct policies can SELECT on bodies" ON public.bodies;

CREATE POLICY "Users with correct policies can SELECT on bodies" ON public.bodies FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_for_private_annotation(auth.uid(), annotation_id) AND (
                public.check_action_policy_organization(auth.uid(), 'bodies', 'SELECT') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'SELECT', layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'bodies', 'SELECT', layer_id)
            ));

-- bodies can be inserted by annotation creator if it is the first body and by others if the have the policy
DROP POLICY IF EXISTS "Users with correct policies can INSERT on bodies" ON public.bodies;

CREATE POLICY "Users with correct policies can INSERT on bodies" ON public.bodies FOR INSERT TO authenticated
    WITH CHECK (public.check_for_private_annotation(auth.uid(), annotation_id) AND
                ((public.check_for_first_body(annotation_id) AND
                  public.check_for_creating_user(auth.uid(), annotation_id) AND
                  (public.check_action_policy_layer(auth.uid(), 'bodies', 'INSERT', layer_id) OR
                   public.check_action_policy_organization(auth.uid(), 'bodies', 'INSERT') OR
                   public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'INSERT', layer_id))
                     ) OR
                 (public.check_for_first_body(annotation_id) IS FALSE AND
                  (public.check_action_policy_organization(auth.uid(), 'bodies', 'INSERT') OR
                   public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'INSERT', layer_id) OR
                   public.check_action_policy_layer(auth.uid(), 'bodies', 'INSERT', layer_id))))
    );

-- bodies can be updated by the creating user or by having Project or Organization policies
DROP POLICY IF EXISTS "Users with correct policies can UPDATE on bodies" ON public.bodies;

CREATE POLICY "Users with correct policies can UPDATE on bodies" ON public.bodies FOR UPDATE TO authenticated
    USING (public.check_for_private_annotation(auth.uid(), annotation_id) AND
           (created_by = auth.uid() OR is_admin_layer(auth.uid(), layer_id)) AND (
    (public.check_for_creating_user(auth.uid(), annotation_id) AND
     public.check_action_policy_layer(auth.uid(), 'bodies', 'UPDATE', layer_id))) OR
           (public.check_action_policy_organization(auth.uid(), 'bodies', 'UPDATE') OR
            public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'UPDATE', layer_id))
    )
    WITH CHECK (public.check_for_private_annotation(auth.uid(), annotation_id) AND (
    (public.check_for_creating_user(auth.uid(), annotation_id) AND
     (created_by = auth.uid() OR is_admin_layer(auth.uid(), layer_id)) AND
     public.check_action_policy_layer(auth.uid(), 'bodies', 'UPDATE', layer_id))) OR
                (public.check_action_policy_organization(auth.uid(), 'bodies', 'UPDATE') OR
                 public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'UPDATE', layer_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on bodies" ON public.bodies;

CREATE POLICY "Users with correct policies can DELETE on bodies" ON public.bodies FOR DELETE TO authenticated
    USING (public.check_for_private_annotation(auth.uid(), annotation_id) AND (
        public.check_action_policy_organization(auth.uid(), 'bodies', 'DELETE') OR
        public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'DELETE', layer_id) OR
        public.check_action_policy_layer(auth.uid(), 'bodies', 'DELETE', layer_id)));
