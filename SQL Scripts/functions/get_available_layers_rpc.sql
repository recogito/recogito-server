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
    _contexts_row      public.contexts % rowtype;
    _layer_context_row  public.layer_contexts % rowtype;
    _layer_row        public.layers % rowtype;      
BEGIN

    -- Check project policy that contexts can be updated by this user
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
        RETURN NEXT;
    END IF;  

    -- Find all documents in the current context
    FOR _document_id IN SELECT pd.document_id 
      FROM public.project_documents pd WHERE pd.project_id = _project_id AND pd.is_archived IS NOT TRUE
    LOOP
      FOR _contexts_row IN SELECT * FROM public.contexts c
        WHERE c.project_id = _project_id
      LOOP
        FOR _layer_context_row IN SELECT * FROM public.layer_contexts lcx
          WHERE lcx.context_id = _contexts_row.id AND lcx.is_archived IS NOT TRUE
        LOOP
          FOR _layer_row IN SELECT * FROM public.layers l 
            WHERE l.id = _layer_context_row.layer_id AND l.document_id = _document_id AND l.is_archived IS NOT TRUE
          LOOP
            document_id := _document_id;
            context_id := _contexts_row.id;
            is_active := _layer_context_row.is_active_layer;
            layer_id := _layer_row.id;
            context_name := _contexts_row.name;
            RETURN NEXT;
          END LOOP;
        END LOOP; 
      END LOOP;
    END LOOP; 
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;