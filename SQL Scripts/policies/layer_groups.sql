DROP POLICY IF EXISTS "Users with correct policies can SELECT on layer_groups" ON public.layer_groups;

CREATE POLICY "Users with correct policies can SELECT on layer_groups" ON public.layer_groups FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        (public.check_action_policy_organization(auth.uid(), 'layer_groups', 'SELECT') OR
         public.check_action_policy_project_from_layer(auth.uid(), 'layer_groups', 'SELECT', layer_id) OR
         public.check_action_policy_layer(auth.uid(), 'layer_groups', 'SELECT', id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on layer_groups" ON public.layer_groups;

CREATE POLICY "Users with correct policies can INSERT on layer_groups" ON public.layer_groups FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'layer_groups', 'INSERT') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'layer_groups', 'INSERT', layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'layer_groups', 'INSERT', id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on layer_groups" ON public.layer_groups;

CREATE POLICY "Users with correct policies can UPDATE on layer_groups" ON public.layer_groups FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'layer_groups', 'UPDATE') OR
        public.check_action_policy_project_from_layer(auth.uid(), 'layer_groups', 'UPDATE', layer_id) OR
        public.check_action_policy_layer(auth.uid(), 'layer_groups', 'UPDATE', id)
    )
    WITH CHECK (PUBLIC.check_action_policy_organization(auth.uid(), 'layer_groups', 'UPDATE') OR
                PUBLIC.check_action_policy_project_from_layer(auth.uid(), 'layer_groups', 'UPDATE', layer_id) OR
                PUBLIC.check_action_policy_layer(auth.uid(), 'layer_groups', 'UPDATE', id)
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on layer_groups" ON public.layer_groups;

CREATE POLICY "Users with correct policies can DELETE on layer_groups" ON public.layer_groups FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'layer_groups', 'DELETE') OR
           public.check_action_policy_project_from_layer(auth.uid(), 'layer_groups', 'DELETE', layer_id) OR
           public.check_action_policy_layer(auth.uid(), 'layer_groups', 'DELETE', id)
    );
