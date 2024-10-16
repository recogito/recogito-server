CREATE
OR REPLACE FUNCTION fix_corrupted_baselayers () 
RETURNS void
AS $body$
DECLARE
  _default_ctx_id uuid;
  _proj_doc_array uuid[];
  _proj_row public.projects % rowtype;
  _ctx_doc_row public.context_documents;
  _layer_context_row public.layer_contexts % rowtype;
BEGIN
  -- This script fixes corrupted baselayers using the following steps
  -- 1. Iterate through all projects
  FOR _proj_row IN SELECT * FROM public.projects p 
    LOOP      
      -- 2. For each project get the default context
      SELECT c.id INTO _default_ctx_id FROM public.contexts c 
        WHERE c.project_id = _proj_row.id 
        AND c.is_project_default IS TRUE 
        AND c.is_archived IS NOT TRUE;
      
      -- 3. Create an array of project_document ids
      _proj_doc_array := ARRAY(SELECT pd.document_id FROM public.project_documents pd WHERE pd.project_id = _proj_row.id AND pd.is_archived IS NOT TRUE);
      RAISE LOG 'Doc Array for project %: %', _proj_row.id, _proj_doc_array;

      -- 4. Archive any context documents that reference documents not in the project_documents array

      IF EXISTS(
        SELECT 1 a
        FROM public.context_documents cd 
        WHERE cd.context_id = _default_ctx_id 
        AND cd.is_archived IS NOT TRUE 
        AND NOT (cd.document_id = ANY(_proj_doc_array)))
        THEN
          FOR _ctx_doc_row IN SELECT * 
            FROM public.context_documents cd 
            WHERE cd.context_id = _default_ctx_id 
            AND cd.is_archived IS NOT TRUE 
            AND NOT (cd.document_id = ANY(_proj_doc_array))
            LOOP
              UPDATE public.context_documents cd
              SET is_archived = TRUE 
              WHERE cd.id = _ctx_doc_row.id;

              -- 5. Archive any layer contexts and layers associated with these documents
              FOR _layer_context_row IN SELECT * 
              FROM public.layer_contexts lc
              INNER JOIN public.layers l ON l.project_id = _proj_row.id 
              AND (l.document_id = _ctx_doc_row.document_id OR NOT (l.document_id = ANY(_proj_doc_array))) 
              AND l.is_archived IS NOT TRUE 
              WHERE lc.layer_id = l.id AND lc.context_id = _default_ctx_id
              LOOP
                UPDATE public.layer_contexts lc 
                SET is_archived = TRUE 
                WHERE lc.id = _layer_context_row.id;

                UPDATE public.layers l 
                SET is_archived = TRUE 
                WHERE l.id = _layer_context_row.layer_id;                
              END LOOP;
            END LOOP;
      END IF;
    END LOOP;  
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER;
