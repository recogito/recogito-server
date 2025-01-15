CREATE
    OR REPLACE FUNCTION update_project_documents_sort_rpc (
    _project_id uuid,
    _document_ids uuid[]
) RETURNS BOOLEAN AS $body$
DECLARE
    current_index INT = 0;
    _document_id uuid;
BEGIN
    -- Check project policy that project documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'project_documents', 'UPDATE')
        OR check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', _project_id))
    THEN
        RETURN FALSE;
    END IF;

    FOREACH _document_id IN ARRAY _document_ids
    LOOP

        UPDATE public.project_documents pd
           SET sort = current_index
         WHERE pd.document_id = _document_id
           AND pd.project_id = _project_id;

        current_index :=  current_index + 1;

    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;