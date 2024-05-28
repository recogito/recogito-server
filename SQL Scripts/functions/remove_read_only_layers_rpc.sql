CREATE
OR REPLACE FUNCTION remove_read_only_layers_rpc (
    _context_id uuid,
    _layer_ids uuid[] 
) RETURNS BOOLEAN AS $body$
DECLARE
    _project_id       uuid;
    _layer_id         uuid;
    _layer_project_id public.layers %rowtype;
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

    -- Iterate through the layer ids
    FOREACH _layer_id IN ARRAY _layer_ids 
    LOOP         
        -- Remove the layer context
        DELETE FROM public.layer_contexts
          WHERE layer_id = _layer_id AND context_id = _context_id AND is_active_layer IS FALSE;
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;