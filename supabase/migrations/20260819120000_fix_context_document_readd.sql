-- Removing a document from a context/project is a soft delete, but the "add"
-- RPCs were written as blind inserts. Re-adding a document that had been removed
-- collided with the UNIQUE (context_id, document_id) constraint on
-- context_documents, the whole RPC rolled back, and the row stayed archived --
-- so the document silently disappeared again on the next page load (the SELECT
-- policy on context_documents filters is_archived IS FALSE).
--
-- This migration makes add_documents_to_context_rpc un-archive instead of
-- failing, and fixes a missing context filter in the project-level RPCs that
-- let a document's archive state leak across every project that contained it.

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_documents_to_context_rpc(_context_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _restored_count int;
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
$function$
;

CREATE OR REPLACE FUNCTION public.add_documents_to_project_rpc(_project_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _context_id uuid;
    _layer_id uuid;
    _document_id uuid;
BEGIN
    -- Check project policy that project documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'project_documents', 'UPDATE') 
        OR check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', _project_id)) 
    THEN
        RETURN FALSE;
    END IF; 

    -- Find the default context for this project  
    SELECT c.id INTO _context_id FROM public.contexts c 
      WHERE c.project_id = _project_id AND c.is_project_default IS TRUE;

    -- Didn't find the default context for this project
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Default context not found for project % ', _project_id;
    END IF; 

    -- Iterate through the document ids and add to project_documents and context_documents for the default context
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        IF EXISTS(SELECT * FROM public.project_documents pd WHERE pd.document_id = _document_id AND pd.project_id = _project_id AND pd.is_archived IS TRUE)
            THEN
            -- For now we will unarchive the project_document and the context_documents 
            -- associated with the document. This will restore and make visible any project annotations, etc
            
            -- Unarchive the project_documents record
            UPDATE public.project_documents pd 
            SET is_archived = FALSE 
            WHERE pd.document_id = _document_id AND pd.project_id = _project_id;
            
            -- Unarchive the document in the contexts of THIS project that contain it.
            -- Without the context filter this reached into every other project's
            -- contexts as well.
            UPDATE public.context_documents cd
              SET is_archived = FALSE 
              WHERE cd.document_id = _document_id
                AND cd.context_id IN (SELECT c.id FROM public.contexts c WHERE c.project_id = _project_id);
        ELSE
            -- Add the document to project_documents
            INSERT INTO public.project_documents 
                (created_by, created_at, project_id, document_id)
                VALUES (auth.uid(), NOW(), _project_id, _document_id);
            
            -- Add a context_document record to the default context
            INSERT INTO public.context_documents
                (created_by, created_at, context_id, document_id)
                VALUES (auth.uid(), NOW(), _context_id, _document_id)
            ON CONFLICT (context_id, document_id) DO UPDATE
                SET is_archived = FALSE,
                    updated_at  = NOW(),
                    updated_by  = auth.uid();

            -- Add the default layer
            _layer_id = extensions.uuid_generate_v4();

            INSERT INTO public.layers 
                (id, document_id, project_id)
                VALUES (_layer_id, _document_id, _project_id);

            -- Add the layer_context
            INSERT INTO public.layer_contexts
                (layer_id, context_id, is_active_layer)
                VALUES (_layer_id, _context_id, TRUE);
        END IF;
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.archive_project_documents_rpc(_project_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;
