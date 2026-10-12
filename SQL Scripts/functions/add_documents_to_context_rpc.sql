CREATE
OR REPLACE FUNCTION add_documents_to_context_rpc (
    _context_id uuid,
    _document_ids uuid[] 
) RETURNS BOOLEAN AS $body$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _restored_count int;
    _archived_ids text;
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
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') 
        OR check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id)) 
    THEN
        RETURN FALSE;
    END IF;  

    -- Refuse to link an archived document, for the same reason as
    -- add_documents_to_project_rpc: the SELECT policy on context_documents only
    -- checks the link row, so the client would see a link to a hidden document.
    SELECT string_agg(d.id::text, ', ') INTO _archived_ids
      FROM public.documents d
      WHERE d.id = ANY(_document_ids) AND d.is_archived IS TRUE;

    IF _archived_ids IS NOT NULL THEN
        RAISE EXCEPTION 'cannot add archived document(s) to context %: %', _context_id, _archived_ids;
    END IF;

    -- Iterate through the document ids
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Add a context_document record. archive_context_documents_rpc only soft
        -- deletes, and (context_id, document_id) is unique, so a document that was
        -- removed and is now being added back still has a row here. Un-archive it
        -- rather than failing on the constraint.
        INSERT INTO public.context_documents
            (created_by, created_at, context_id, document_id)
            VALUES (auth.uid(), NOW(), _context_id, _document_id)
        ON CONFLICT (context_id, document_id) DO UPDATE
            SET is_archived = FALSE,
                updated_at  = NOW(),
                updated_by  = auth.uid();

        -- Restore the layers that were archived along with the document, so the
        -- annotations made before it was removed come back with it. Only layers on
        -- an active layer_context were archived; read-only layers borrowed from
        -- another context must be left alone.
        UPDATE public.layers l
          SET is_archived = FALSE
          WHERE l.document_id = _document_id
            AND EXISTS (SELECT 1 FROM public.layer_contexts lc
                          WHERE lc.layer_id = l.id
                            AND lc.context_id = _context_id
                            AND lc.is_active_layer IS TRUE);

        UPDATE public.layer_contexts lc
          SET is_archived = FALSE
          FROM public.layers l
          WHERE l.id = lc.layer_id
            AND lc.context_id = _context_id
            AND l.document_id = _document_id;

        GET DIAGNOSTICS _restored_count = ROW_COUNT;

        -- Nothing to restore, so this document is new to the context
        IF _restored_count = 0 
        THEN
            -- Add a layer for this document
            _layer_id = extensions.uuid_generate_v4();
            INSERT INTO public.layers
                    (id, created_by, created_at, document_id, project_id)
                VALUES (_layer_id, auth.uid(), NOW(), _document_id, _project_id);

            -- Add a layer context
            INSERT INTO public.layer_contexts
                    (created_by, created_at, layer_id, context_id, is_active_layer)
                VALUES (auth.uid(), NOW(), _layer_id, _context_id, TRUE);
        END IF;
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;
