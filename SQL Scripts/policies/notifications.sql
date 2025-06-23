DROP POLICY IF EXISTS "Users with correct policies can SELECT on notifications" ON public.notifications;

CREATE POLICY "Users with correct policies can SELECT on notifications" ON public.notifications FOR SELECT TO authenticated
    USING (
        target_user_id = auth.uid() AND
        public.check_action_policy_organization(auth.uid(), 'notifications', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on notifications" ON public.notifications;

CREATE POLICY "Users with correct policies can INSERT on notifications" ON public.notifications FOR INSERT TO authenticated
    WITH CHECK (target_user_id = auth.uid() OR public.check_action_policy_organization(auth.uid(), 'notifications', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on notifications" ON public.notifications;

CREATE POLICY "Users with correct policies can UPDATE on notifications" ON public.notifications FOR UPDATE TO authenticated
    USING (
        (select auth.uid() = target_user_id  OR
        public.check_action_policy_organization(auth.uid(), 'notifications', 'UPDATE'))
    )
    WITH CHECK ( 
        (select auth.uid() = target_user_id  OR
        public.check_action_policy_organization(auth.uid(), 'notifications', 'UPDATE'))
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on notifications" ON public.notifications;

CREATE POLICY "Users with correct policies can DELETE on notifications" ON public.notifications FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'notifications', 'DELETE'));
