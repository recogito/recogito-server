CREATE
OR REPLACE FUNCTION archive_document_rpc (
    _document_id uuid 
) RETURNS BOOLEAN AS $body$
DECLARE
    _row public.documents % rowtype;
BEGIN
    -- Check project policy that project documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'documents', 'UPDATE')) 
    THEN
        RETURN FALSE;
    END IF; 

    -- Get the document
    SELECT * INTO _row FROM public.documents d WHERE d.id = _document_id;

    -- If the user is the creator or an Org Admin, archive the document
    IF _row.created_by = auth.uid() OR is_admin_organization(auth.uid())
    THEN
      IF NOT EXISTS(SELECT 1 FROM public.project_documents pd WHERE pd.id = _document_id AND pd.is_archived IS FALSE )
        THEN
          UPDATE public.documents d 
          SET is_archived = TRUE 
          WHERE d.id = _document_id;

          RETURN TRUE;
      END IF;
    END IF;

    RETURN FALSE;    
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;