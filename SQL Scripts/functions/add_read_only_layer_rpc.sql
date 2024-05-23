CREATE
OR REPLACE FUNCTION add_read_only_layers_rpc (
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
        -- Should only add layers which belong to the current project
        SELECT l.project_id INTO _layer_project_id FROM public.layers l 
          WHERE l.id = _layer_id AND l.project_id = _project_id;

        -- Didn't find this layer in this project
        IF NOT FOUND THEN
            RAISE EXCEPTION 'layer % not found for project % ', _layer_id, _project_id;
        END IF;          

        -- Add a layer context and add them as the non-active layer
        INSERT INTO public.layer_contexts
                (created_by, created_at, layer_id, context_id, is_active_layer)
            VALUES (auth.uid(), NOW(), _layer_id, _context_id, FALSE);
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;