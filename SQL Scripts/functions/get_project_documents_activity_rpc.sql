-- Returns, for each document in a project, the most recent annotation activity:
-- the latest time an annotation, body or target on that document was created
-- or updated (including archiving, i.e. deletion). Documents without any
-- annotations are not returned. Other users' private annotations are ignored.
CREATE OR REPLACE FUNCTION get_project_documents_activity_rpc(_project_id uuid)
    RETURNS TABLE (
        document_id   uuid,
        last_activity timestamptz
    )
AS
$body$
BEGIN
    IF NOT (check_action_policy_organization(auth.uid(), 'project_documents', 'SELECT')
        OR check_action_policy_project(auth.uid(), 'project_documents', 'SELECT', _project_id))
    THEN
        RETURN;
    END IF;

    RETURN QUERY
        SELECT l.document_id,
               MAX(GREATEST(x.created_at, x.updated_at)) AS last_activity
          FROM public.layers l
          JOIN public.annotations a ON a.layer_id = l.id
          JOIN LATERAL (
                  SELECT a.created_at, a.updated_at
                   UNION ALL
                  SELECT b.created_at, b.updated_at
                    FROM public.bodies b
                   WHERE b.annotation_id = a.id
                   UNION ALL
                  SELECT t.created_at, t.updated_at
                    FROM public.targets t
                   WHERE t.annotation_id = a.id
               ) x ON TRUE
         WHERE l.project_id = _project_id
           AND l.document_id IS NOT NULL
           AND (a.is_private IS NOT TRUE OR a.created_by = auth.uid())
         GROUP BY l.document_id;
END;
$body$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
