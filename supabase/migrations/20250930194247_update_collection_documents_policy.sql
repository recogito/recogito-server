DROP POLICY "Users with correct policies can UPDATE on documents" ON public.documents;

CREATE POLICY "Users with correct policies can UPDATE on documents" ON public.documents FOR
UPDATE TO authenticated USING (
    (
        (
            is_private = FALSE
            OR created_by = auth.uid ()
            OR is_admin_organization (auth.uid ())
        )
        AND (
            collection_id ISNULL
            OR is_admin_organization (auth.uid ())
        )
        AND public.check_action_policy_organization (auth.uid (), 'documents', 'UPDATE')
    )
    OR (
        (
            is_private = FALSE
            OR created_by = auth.uid ()
        )
        AND (
            collection_id ISNULL
            OR is_admin_organization (auth.uid ())
        )
        AND public.check_action_policy_project_from_document (auth.uid (), 'documents', 'UPDATE', id)
    )
)
WITH
    CHECK (
        (
            (
                is_private = FALSE
                OR created_by = auth.uid ()
                OR is_admin_organization (auth.uid ())
            )
            AND (
                collection_id ISNULL
                OR is_admin_organization (auth.uid ())
            )
            AND public.check_action_policy_organization (auth.uid (), 'documents', 'UPDATE')
        )
        OR (
            (
                is_private = FALSE
                OR created_by = auth.uid ()
            )
            AND (
                collection_id ISNULL
                OR is_admin_organization (auth.uid ())
            )
            AND public.check_action_policy_project_from_document (auth.uid (), 'documents', 'UPDATE', id)
        )
    );
