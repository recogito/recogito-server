CREATE
OR REPLACE FUNCTION archive_project_documents_rpc (
    _project_id uuid,
    _document_ids uuid[] 
) RETURNS BOOLEAN AS $body$
DECLARE
    _document_id uuid;
BEGIN
    -- Check project policy that project documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'project_documents', 'UPDATE') 
        OR check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', _project_id)) 
    THEN
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids and archive them in project_documents and all context_documents
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Archive the project_documents record
        UPDATE public.project_documents pd 
          SET is_archived = TRUE 
          WHERE pd.document_id = _document_id AND pd.project_id = _project_id;
        
        -- Archive the document in the contexts of THIS project that contain it.
        -- Without the context filter this archived the document in every other
        -- project's contexts as well.
        UPDATE public.context_documents cd
          SET is_archived = TRUE 
          WHERE cd.document_id = _document_id
            AND cd.context_id IN (SELECT c.id FROM public.contexts c WHERE c.project_id = _project_id);
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;
