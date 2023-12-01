DROP POLICY IF EXISTS "Users with correct policies can SELECT on group_users" ON public.group_users;

CREATE POLICY "Users with correct policies can SELECT on group_users" ON public.group_users FOR SELECT TO authenticated
    USING (
            is_archived IS FALSE AND
            (public.check_action_policy_organization(auth.uid(), 'group_users', 'SELECT') OR
            public.check_action_policy_project_from_group_user(auth.uid(), 'group_users', 'SELECT', group_type, type_id) OR
             public.check_action_policy_layer_from_group_user(auth.uid(), 'group_users', 'SELECT', group_type, type_id))
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on group_users" ON public.group_users;

CREATE POLICY "Users with correct policies can INSERT on group_users" ON public.group_users FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'group_users', 'INSERT') OR
                public.check_action_policy_project_from_group_user(auth.uid(), 'group_users', 'INSERT', group_type, type_id) OR
                public.check_action_policy_layer_from_group_user(auth.uid(), 'group_users', 'INSERT', group_type, type_id));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on group_users" ON public.group_users;

CREATE POLICY "Users with correct policies can UPDATE on group_users" ON public.group_users FOR UPDATE TO authenticated
    USING (
        public.check_action_policy_organization(auth.uid(), 'group_users', 'UPDATE') OR
        public.check_action_policy_project_from_group_user(auth.uid(), 'group_users', 'UPDATE', group_type, type_id) OR
        public.check_action_policy_layer_from_group_user(auth.uid(), 'group_users', 'UPDATE', group_type, type_id)
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'group_users', 'UPDATE') OR
                public.check_action_policy_project_from_group_user(auth.uid(), 'group_users', 'UPDATE', group_type, type_id) OR
                public.check_action_policy_layer_from_group_user(auth.uid(), 'group_users', 'UPDATE', group_type, type_id));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on group_users" ON public.group_users;

CREATE POLICY "Users with correct policies can DELETE on group_users" ON public.group_users FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'group_users', 'DELETE') OR
           public.check_action_policy_project_from_group_user(auth.uid(), 'group_users', 'DELETE', group_type, type_id) OR
           public.check_action_policy_layer_from_group_user(auth.uid(), 'group_users', 'DELETE', group_type, type_id));
