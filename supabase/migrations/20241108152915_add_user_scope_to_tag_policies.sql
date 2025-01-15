DROP POLICY IF EXISTS "Users with correct policies can SELECT on tag_definitions" ON public.tag_definitions;
DROP POLICY IF EXISTS "Users with correct policies can INSERT on tag_definitions" ON public.tag_definitions;
DROP POLICY IF EXISTS "Users with correct policies can UPDATE on tag_definitions" ON public.tag_definitions;
DROP POLICY IF EXISTS "Users with correct policies can DELETE on tag_definitions" ON public.tag_definitions;

ALTER TYPE tag_scope_types ADD VALUE IF NOT EXISTS 'user' AFTER 'project';

COMMIT;

ALTER TABLE public.tag_definitions
    ALTER COLUMN scope TYPE tag_scope_types USING (scope::tag_scope_types);

CREATE OR REPLACE FUNCTION check_action_policy_user_from_tag_definition(user_id uuid, tag_definition_id uuid) RETURNS bool AS $body$
DECLARE
    _scope      VARCHAR;
    _scope_id   UUID;
BEGIN
    SELECT scope, scope_id INTO _scope, _scope_id FROM public.tag_definitions WHERE id = tag_definition_id;

    RETURN _scope = 'user' AND _scope_id = user_id;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;

DROP POLICY IF EXISTS "Users with correct policies can SELECT on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can SELECT on tag_definitions" ON public.tag_definitions FOR
SELECT
    TO authenticated USING (
        is_archived IS FALSE
        AND (
            (
                SCOPE = 'organization'
                AND public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'SELECT')
            )
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
            OR (
                SCOPE = 'system'
                AND public.check_action_policy_organization (auth.uid (), 'tag_definitions', 'SELECT')
            )
            OR (
                SCOPE = 'user'
                AND created_by = auth.uid()
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
            OR (
                SCOPE = 'user'
                AND created_by = auth.uid()
            )
        )
    );

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on tag_definitions" ON public.tag_definitions;

CREATE POLICY "Users with correct policies can UPDATE on tag_definitions" ON public.tag_definitions FOR
UPDATE TO authenticated USING (
    SCOPE != 'system'
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
        OR (
            SCOPE = 'user'
            AND created_by = auth.uid()
        )
    )
)
WITH
    CHECK (
        SCOPE != 'system'
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
            OR (
                SCOPE = 'user'
                AND created_by = auth.uid()
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
        OR (
            SCOPE = 'user'
            AND created_by = auth.uid()
        )
    )
);

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
    public.check_action_policy_organization (auth.uid (), 'tags', 'UPDATE')
    OR public.check_action_policy_project_from_tag_definition (auth.uid (), 'tags', 'UPDATE', tag_definition_id)
    OR public.check_action_policy_user_from_tag_definition(auth.uid(), tag_definition_id)
)
WITH
    CHECK (
        public.check_action_policy_organization (auth.uid (), 'tags', 'UPDATE')
        OR public.check_action_policy_project_from_tag_definition (auth.uid (), 'tags', 'UPDATE', tag_definition_id)
        OR public.check_action_policy_user_from_tag_definition(auth.uid(), tag_definition_id)
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