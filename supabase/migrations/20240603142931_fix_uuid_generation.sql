set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_documents_to_project_rpc(_project_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _context_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row public.contexts % rowtype;
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
            
            -- Unarchive the document in all contexts that contain it
            FOR _row IN SELECT * FROM public.contexts c WHERE c.project_id = _project_id
            LOOP 
            UPDATE public.context_documents 
                SET is_archived = FALSE 
                WHERE document_id = _document_id;
            END LOOP;            
        ELSE
            -- Add the document to project_documents
            INSERT INTO public.project_documents 
                (created_by, created_at, project_id, document_id)
                VALUES (auth.uid(), NOW(), _project_id, _document_id);
            
            -- Add a context_document record to the default context
            INSERT INTO public.context_documents
                (created_by, created_at, context_id, document_id)
                VALUES (auth.uid(), NOW(), _context_id, _document_id);

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


