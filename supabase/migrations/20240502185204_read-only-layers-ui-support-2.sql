drop function if exists "public"."get_availabale_layers_rpc"(_project_id uuid);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.remove_read_only_layers_rpc(_context_id uuid, _layer_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
    IF NOT check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id) THEN
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_availabale_layers_rpc(_project_id uuid)
 RETURNS TABLE(document_id uuid, layer_id uuid, context_id uuid, is_active boolean, context_name character varying)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
        RAISE LOG 'Context %', _contexts_row.id;
        FOR _layer_context_row IN SELECT * FROM public.layer_contexts lcx
          WHERE lcx.context_id = _contexts_row.id AND lcx.is_archived IS NOT TRUE
        LOOP
          RAISE LOG 'Layer Context %', _layer_context_row.id;
          FOR _layer_row IN SELECT * FROM public.layers l 
            WHERE l.id = _layer_context_row.layer_id AND l.document_id = _document_id AND l.is_archived IS NOT TRUE
          LOOP
            RAISE LOG 'Layer %', _layer_row.id;
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
$function$
;


