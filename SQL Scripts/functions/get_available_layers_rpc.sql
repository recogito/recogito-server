CREATE
OR REPLACE FUNCTION get_availabale_layers_rpc (
    _project_id       uuid
) RETURNS TABLE (
  document_id   uuid,
  layer_id      uuid,
  context_id    uuid,
  is_active     BOOLEAN,
  context_name  VARCHAR
) 
AS $body$
DECLARE
    _context_name     VARCHAR;
    _document_id      uuid;
    _layer_contexts_row      public.layer_contexts % rowtype;      
BEGIN

    -- Check project policy that contexts can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
        RETURN NEXT;
    END IF;  

    -- Find all documents in the current context
    FOR _document_id IN SELECT pd.document_id 
      FROM public.project_documents pd WHERE pd.project_id = _project_id
    LOOP
      FOR _layer_contexts_row IN SELECT * FROM public.layer_contexts lc
        INNER JOIN public.layers l ON l.document_id = _document_id
        WHERE lc.layer_id = l.id AND lc.is_archived IS NOT TRUE
      LOOP
        RAISE LOG 'Layer Context %', _layer_contexts_row.id;
        SELECT c.name INTO _context_name FROM public.contexts c WHERE _layer_contexts_row.context_id = c.id; 
        document_id := _document_id;
        context_id := _layer_contexts_row.context_id;
        is_active := _layer_contexts_row.is_active_layer;
        layer_id := _layer_contexts_row.layer_id;
        context_name := _context_name;
        RETURN NEXT; 
      END LOOP;
    END LOOP; 
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;