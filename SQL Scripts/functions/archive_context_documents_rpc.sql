CREATE
OR REPLACE FUNCTION archive_context_documents_rpc (
    _context_id uuid,
    _document_ids uuid[] 
) RETURNS BOOLEAN AS $body$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check project policy that context documents can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'context_documents', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids and archive them in project_documents and all context_documents
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Archive the context_documents record
        UPDATE public.context_document cd 
          SET is_archived = TRUE 
          WHERE cd.document_id = _document_id AND cd.context_id = _context_id;
        
        -- Archive any related layers
        FOR _row IN SELECT * FROM public.layers l 
          INNER JOIN public.layer_contexts lc ON lc.context_id = _context_id
          WHERE l.document_id = _document_id
        LOOP 
          UPDATE public.layers 
            SET is_archived = TRUE 
            WHERE id = _row.id;

          UPDATE public.layer_contexts lc
            SET is_archived = TRUE
            WHERE lc.context_id = _context_id AND lc.layer_id = _row.id;
        END LOOP;
          
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;