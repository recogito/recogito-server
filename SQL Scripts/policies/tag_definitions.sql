DROP POLICY IF EXISTS "Users with correct policies can SELECT on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can SELECT on tag_definitions" ON public.tag_definitions FOR SELECT TO authenticated
    USING (
        is_archived IS FALSE AND
        public.check_action_policy_organization(auth.uid(), 'tag_definitions', 'SELECT')
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can INSERT on tag_definitions" ON public.tag_definitions FOR INSERT TO authenticated
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'tag_definitions', 'INSERT'));

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can UPDATE on tag_definitions" ON public.tag_definitions FOR UPDATE TO authenticated
    USING (
    public.check_action_policy_organization(auth.uid(), 'tag_definitions', 'UPDATE')
    )
    WITH CHECK (public.check_action_policy_organization(auth.uid(), 'tag_definitions', 'UPDATE'));

DROP POLICY IF EXISTS "Users with correct policies can DELETE on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can DELETE on tag_definitions" ON public.tag_definitions FOR DELETE TO authenticated
    USING (public.check_action_policy_organization(auth.uid(), 'tag_definitions', 'DELETE'));
