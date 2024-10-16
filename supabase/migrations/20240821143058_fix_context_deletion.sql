set check_function_bodies = off;

CREATE
OR REPLACE FUNCTION archive_context_rpc (
    _context_id uuid
) RETURNS BOOLEAN AS $body$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
    _row_2 RECORD;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check project policy that context documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') 
      OR check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id)) 
    THEN
        RAISE LOG 'Check action policy failed for project %', _project_id;
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids in this context and archive them in all context_documents
    FOR _row IN SELECT * FROM public.context_documents cd WHERE cd.context_id = _context_id 
    LOOP
        -- Archive the context_documents record
        UPDATE public.context_documents cd 
          SET is_archived = TRUE 
          WHERE cd.id = _row.id;
        
        -- Archive any related layers
        FOR _row_2 IN SELECT * FROM public.layer_contexts lc 
          WHERE lc.context_id = _context_id
        LOOP 
          IF _row_2.is_active_layer IS TRUE 
          THEN
            UPDATE public.layers l
              SET is_archived = TRUE 
              WHERE l.id = _row_2.layer_id;
          END IF;

          UPDATE public.layer_contexts lc
            SET is_archived = TRUE
            WHERE lc.id = _row_2.id;
        END LOOP;
          
    END LOOP;

    UPDATE public.contexts 
      SET is_archived = TRUE 
      WHERE id = _context_id;
    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;