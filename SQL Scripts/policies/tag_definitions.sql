DROP POLICY IF EXISTS "Users with correct policies can SELECT on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can SELECT on tag_definitions" ON public.tag_definitions FOR
SELECT
    TO authenticated USING (
        is_archived IS FALSE
        AND (
            SCOPE = 'organization'
            AND public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'SELECT')
            OR (
                SCOPE = 'project'
                AND (
                    public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'SELECT')
                    OR public.check_action_policy_project (
                        auth.uid (),
                        'tag_definitions',
                        'SELECT',
                        scope_id
                    )
                )
            )
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can INSERT on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can INSERT on tag_definitions" ON public.tag_definitions FOR INSERT TO authenticated
WITH
    CHECK (
        SCOPE != 'system'
        AND is_archived IS FALSE
        AND (
            SCOPE = 'organization'
            AND public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'INSERT')
            OR (
                SCOPE = 'project'
                AND (
                    public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'INSERT')
                    OR public.check_action_policy_project (
                        auth.uid (),
                        'tag_definitions',
                        'INSERT',
                        scope_id
                    )
                )
            )
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can UPDATE on tag_definitions" ON public.tag_definitions FOR
UPDATE TO authenticated USING (
    SCOPE != 'system'
    AND is_archived IS FALSE
    AND (
        SCOPE = 'organization'
        AND public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'UPDATE')
        OR (
            SCOPE = 'project'
            AND (
                public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'UPDATE')
                OR public.check_action_policy_project (
                    auth.uid (),
                    'tag_definitions',
                    'UPDATE',
                    scope_id
                )
            )
        )
    )
)
WITH
    CHECK (
        SCOPE != 'system'
        AND is_archived IS FALSE
        AND (
            SCOPE = 'organization'
            AND public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'UPDATE')
            OR (
                SCOPE = 'project'
                AND (
                    public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'UPDATE')
                    OR public.check_action_policy_project (
                        auth.uid (),
                        'tag_definitions',
                        'UPDATE',
                        scope_id
                    )
                )
            )
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can DELETE on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can DELETE on tag_definitions" ON public.tag_definitions FOR DELETE TO authenticated USING (
    SCOPE != 'system'
    AND is_archived IS FALSE
    AND (
        SCOPE = 'organization'
        AND public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'DELETE')
        OR (
            SCOPE = 'project'
            AND (
                public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'DELETE')
                OR public.check_action_policy_project (
                    auth.uid (),
                    'tag_definitions',
                    'DELETE',
                    scope_id
                )
            )
        )
    )
);