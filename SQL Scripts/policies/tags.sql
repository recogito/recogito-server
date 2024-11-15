DROP POLICY IF EXISTS "Users with correct policies can SELECT on tags" ON public.tags;

CREATE POLICY "Users with correct policies can SELECT on tags" ON public.tags FOR
SELECT
    TO authenticated USING (
        is_archived IS FALSE
        AND (
            public.check_action_policy_organization (auth.uid (), 'tags', 'SELECT')
            OR public.check_action_policy_project_from_tag_definition (auth.uid (), 'tags', 'SELECT', tag_definition_id)
            OR public.check_action_policy_user_from_tag_definition(auth.uid(), tag_definition_id)
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on tags" ON public.tags;

CREATE POLICY "Users with correct policies can INSERT on tags" ON public.tags FOR INSERT TO authenticated
WITH
    CHECK (
        is_archived IS FALSE
        AND (
            public.check_action_policy_organization (auth.uid (), 'tags', 'INSERT')
            OR public.check_action_policy_project_from_tag_definition (auth.uid (), 'tags', 'INSERT', tag_definition_id)
            OR public.check_action_policy_user_from_tag_definition(auth.uid(), tag_definition_id)
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on tags" ON public.tags;

CREATE POLICY "Users with correct policies can UPDATE on tags" ON public.tags FOR
UPDATE TO authenticated USING (
    is_archived IS FALSE
    AND (
        public.check_action_policy_organization (auth.uid (), 'tags', 'UPDATE')
        OR public.check_action_policy_project_from_tag_definition (auth.uid (), 'tags', 'UPDATE', tag_definition_id)
        OR public.check_action_policy_user_from_tag_definition(auth.uid(), tag_definition_id)
    )
)
WITH
    CHECK (
        is_archived IS FALSE
        AND (
            public.check_action_policy_organization (auth.uid (), 'tags', 'UPDATE')
            OR public.check_action_policy_project_from_tag_definition (auth.uid (), 'tags', 'UPDATE', tag_definition_id)
            OR public.check_action_policy_user_from_tag_definition(auth.uid(), tag_definition_id)
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on tags" ON public.tags;

CREATE POLICY "Users with correct policies can DELETE on tags" ON public.tags FOR DELETE TO authenticated USING (
    is_archived IS FALSE
    AND (
        public.check_action_policy_organization (auth.uid (), 'tags', 'DELETE')
        OR public.check_action_policy_project_from_tag_definition (auth.uid (), 'tags', 'DELETE', tag_definition_id)
        OR public.check_action_policy_user_from_tag_definition(auth.uid(), tag_definition_id)
    )
);