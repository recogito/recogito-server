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
    IF NOT check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', _project_id) THEN
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
            _layer_id = uuid_generate_v4();

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

CREATE OR REPLACE FUNCTION public.check_for_project_open_edit_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _is_project_default BOOLEAN;  
  _is_open_edit BOOLEAN;
  _record RECORD;
  _layer_record RECORD;
  _context_id uuid;
  _role_id uuid;
  _project_group_id uuid;
  _id uuid;
BEGIN
  -- See project has changed to open edit
  IF OLD.is_open_edit IS FALSE AND NEW.is_open_edit IS TRUE THEN
    -- Get the default context
    SELECT c.id INTO _context_id FROM public.contexts c WHERE c.project_id = NEW.id AND c.is_project_default IS TRUE;

    -- RAISE LOG 'Found default context: %', _context_id; 

    -- Get the layer group
    SELECT g.role_id INTO _role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_default = TRUE;
    -- RAISE LOG 'Found layer_group: %', _layer_group_id; 

    -- Get the project group
    SELECT pg.id INTO _project_group_id FROM public.project_groups pg WHERE pg.project_id = NEW.id AND is_default IS TRUE;
    -- RAISE LOG 'Found project_group: %', _project_group_id; 

    -- Add all project members to the default context
    FOR _record IN SELECT * FROM public.group_users WHERE group_type = 'project' AND type_id = _project_group_id
    LOOP
        -- RAISE LOG 'Adding % to layer group', _record.user_id; 
        INSERT INTO public.context_users (context_id, user_id, role_id)
        VALUES (_context_id,_record.user_id, _role_id);
    END LOOP; 
  END IF;

  RETURN NEW;
END
$function$
;

CREATE OR REPLACE FUNCTION public.check_group_user_for_open_edit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _project_id uuid;
  _is_default_group BOOLEAN;
  _context_id uuid;
  _is_open_edit BOOLEAN;
  _role_id uuid;
BEGIN
  -- Is this a project group?
  IF NEW.group_type = 'project' THEN
    -- Get the project group
    SELECT g.is_default, g.project_id INTO _is_default_group, _project_id FROM public.project_groups g WHERE g.id = NEW.type_id;

    -- Get the project
    SELECT is_open_edit INTO _is_open_edit FROM public.projects p WHERE p.id = _project_id;

    -- Is this a new member of the default group of an open edit project
    IF _is_open_edit AND _is_default_group THEN

      -- Get the default context
      SELECT c.id INTO _context_id FROM public.contexts c WHERE c.project_id = _project_id AND c.is_project_default IS TRUE;

      -- Get the role id
       SELECT g.role_id INTO _role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_default = TRUE;

      -- Add the user to the context
      INSERT INTO public.context_users (context_id, user_id, role_id)
      VALUES (_context_id,NEW.user_id, _role_id); 
    END IF;
  END IF;
  RETURN NEW;
END
$function$
;

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
        INSERT INTO public.context_users (context_id, user_id, role_id)
        VALUES (_context_id,_record.user_id, _role_id);
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_availabale_layers_rpc(_project_id uuid, _context_id uuid)
 RETURNS TABLE(document_id uuid, layer_id uuid, context_id uuid, context_name character varying)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
        WHERE lc.layer_id = l.id AND (lc.is_active_layer IS TRUE OR lc.context_id = _context_id)
      LOOP
        SELECT c.name INTO _context_name FROM public.contexts c WHERE _layer_contexts_row.context_id = c.id; 
        document_id := _document_id;
        context_id := _layer_contexts_row.context_id;
        layer_id := _layer_contexts_row.layer_id;
        context_name := _context_name;
        RETURN NEXT; 
      END LOOP;
    END LOOP; 
END
$function$
;


