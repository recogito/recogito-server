set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_layer_context_for_open_edit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _project_id uuid;
  _context_name VARCHAR;
  _is_project_default BOOLEAN;  
  _is_open_edit BOOLEAN;
  _record RECORD;
  _project_group_id uuid;
  _role_id uuid;
  _id uuid;
BEGIN
  -- See if the layer is in the default context on an open edit project
  SELECT c.project_id, c.name, c.is_project_default INTO _project_id, _context_name, _is_project_default FROM public.contexts c WHERE c.id = NEW.context_id;
  SELECT is_open_edit INTO _is_open_edit FROM public.projects p WHERE p.id = _project_id;

  RAISE LOG 'check_layer_context_for_open_edit';

  IF _is_open_edit AND _is_project_default IS TRUE THEN
    -- Get the project group
    SELECT (id) INTO _project_group_id FROM public.project_groups WHERE project_id = _project_id and is_default = TRUE;

    -- Get the role_id
    SELECT g.role_id INTO _role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_default = TRUE;

    -- Add all project members to default context
    FOR _record IN SELECT * FROM public.group_users WHERE group_type = 'project' AND type_id = _project_group_id
    LOOP
        IF NOT EXISTS
          (SELECT 1 FROM public.context_users cu 
          WHERE cu.context_id = NEW.context_id 
          AND cu.user_id = _record.user_id 
          AND cu.role_id = _role_id) 
        THEN
          INSERT INTO public.context_users (context_id, user_id, role_id)
          VALUES (NEW.context_id,_record.user_id, _role_id);
        END IF;
    END LOOP; 
  END IF;

  RETURN NEW;
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

    -- Check project policy that contexts can be selected by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'SELECT') 
      OR check_action_policy_project(auth.uid(), 'contexts', 'SELECT', _project_id)) 
    THEN
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
$function$
;

CREATE TRIGGER on_layer_context_created_check_open_edit AFTER INSERT ON public.layer_contexts FOR EACH ROW EXECUTE FUNCTION check_layer_context_for_open_edit();


