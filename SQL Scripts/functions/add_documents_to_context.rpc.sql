CREATE
OR REPLACE FUNCTION add_documents_to_context_rpc (
    _context_id uuid,
    _document_ids uuid[] 
) RETURNS BOOLEAN AS $body$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Didn't find the project for this context
    IF NOT FOUND THEN
        RAISE EXCEPTION 'project not found for context % ', _context_id;
    END IF;

    -- Check project policy that contexts can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
        RETURN FALSE;
    END IF;  

    -- Iterate through the document ids
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Add a context_document record
        INSERT INTO public.context_documents
            (created_by, created_at, context_id, document_id)
            VALUES (auth.uid(), NOW(), _context_id, _document_id);

        -- Add a layer for this document
        _layer_id = extensions.uuid_generate_v4();
        INSERT INTO public.layers
                (id, created_by, created_at, document_id, project_id)
            VALUES (_layer_id, auth.uid(), NOW(), _document_id, _project_id);

        -- Add a layer context
        INSERT INTO public.layer_contexts
                (created_by, created_at, layer_id, context_id, is_active_layer)
            VALUES (auth.uid(), NOW(), _layer_id, _context_id, TRUE);
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;