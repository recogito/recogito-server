drop function if exists "public"."get_availabale_layers_rpc"(_project_id uuid);

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
        -- Add a context_document record
        INSERT INTO public.context_documents
            (created_by, created_at, context_id, document_id)
            VALUES (auth.uid(), NOW(), _context_id, _document_id);

        -- Add a layer for this document
        _layer_id = extensions.uuid_generate_v4();
        INSERT INTO public.layers
                (id, created_by, created_at, document_id, project_id)
            VALUES (_layer_id, auth.uid(), NOW(), _document_id, _project_id);

        -- Add a layer context
        INSERT INTO public.layer_contexts
                (created_by, created_at, layer_id, context_id, is_active_layer)
            VALUES (auth.uid(), NOW(), _layer_id, _context_id, TRUE);
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

CREATE OR REPLACE FUNCTION public.add_read_only_layers_rpc(_context_id uuid, _layer_ids uuid[])
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
$function$
;

CREATE OR REPLACE FUNCTION public.add_users_to_context_rpc(_context_id uuid, _users add_user_type[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _user add_user_type;
    _admin_role_id uuid;
    _default_role_id uuid;
    _role_id uuid;
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

    -- Get the role ids
    SELECT g.role_id INTO _admin_role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_admin = TRUE;
    SELECT g.role_id INTO _default_role_id FROM public.default_groups g WHERE g.group_type = 'layer' AND g.is_default = TRUE;

    -- Add the users to the context_users table
    FOREACH _user IN ARRAY _users 
    LOOP
      _role_id = NULL;
      IF _user.role = 'admin' THEN
        _role_id = _admin_role_id;
        ELSE IF _user.role = 'default' THEN
          _role_id = _default_role_id;
        END IF;
      END IF;

      IF _role_id IS NOT NULL THEN
        INSERT INTO public.context_users
              (context_id, user_id, role_id) 
          VALUES(_context_id, _user.user_id, _role_id);
      END IF;
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.archive_context_documents_rpc(_context_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check project policy that context documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'context_documents', 'UPDATE') 
      OR check_action_policy_project(auth.uid(), 'context_documents', 'UPDATE', _project_id)) 
    THEN
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids and archive them in project_documents and all context_documents
    FOREACH _document_id IN ARRAY _document_ids 
    LOOP
        -- Archive the context_documents record
        UPDATE public.context_document cd 
          SET is_archived = TRUE 
          WHERE cd.document_id = _document_id AND cd.context_id = _context_id;
        
        -- Archive any related layers
        FOR _row IN SELECT * FROM public.layers l 
          INNER JOIN public.layer_contexts lc ON lc.context_id = _context_id
          WHERE l.document_id = _document_id
        LOOP 
          UPDATE public.layers 
            SET is_archived = TRUE 
            WHERE id = _row.id;

          UPDATE public.layer_contexts lc
            SET is_archived = TRUE
            WHERE lc.context_id = _context_id AND lc.layer_id = _row.id;
        END LOOP;
          
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.archive_context_rpc(_context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
    _row_2 RECORD;
BEGIN
    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check project policy that context documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') 
      OR check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id)) 
    THEN
        RAISE LOG 'Check action policy failed for project %', _project_id;
        RETURN FALSE;
    END IF; 

    -- Iterate through the document ids in this context and archive them in all context_documents
    FOR _row IN SELECT * FROM public.context_documents cd WHERE cd.context_id = _context_id 
    LOOP
        -- Archive the context_documents record
        UPDATE public.context_documents cd 
          SET is_archived = TRUE 
          WHERE cd.id = _row.id;
        
        -- Archive any related layers
        FOR _row_2 IN SELECT * FROM public.layers l 
          INNER JOIN public.layer_contexts lc ON lc.context_id = _context_id
          WHERE l.document_id = _row.document_id
        LOOP 
          UPDATE public.layers 
            SET is_archived = TRUE 
            WHERE id = _row_2.id;

          UPDATE public.layer_contexts lc
            SET is_archived = TRUE
            WHERE lc.context_id = _context_id AND lc.layer_id = _row_2.id;
        END LOOP;
          
    END LOOP;

    UPDATE public.contexts 
      SET is_archived = TRUE 
      WHERE id = _context_id;
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
    _context_id uuid;
    _layer_id uuid;
    _document_id uuid;
    _row RECORD;
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
        
        -- Archive the document in all contexts that contain it
        FOR _row IN SELECT * FROM public.contexts c WHERE c.project_id = _project_id
        LOOP 
          UPDATE public.context_documents 
            SET is_archived = TRUE 
            WHERE document_id = _document_id;
        END LOOP;
          
    END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.create_context_rpc(_project_id uuid, _name character varying, _description character varying)
 RETURNS SETOF contexts
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _context_id uuid;
BEGIN
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'INSERT') 
        OR check_action_policy_project(auth.uid(), 'contexts', 'INSERT', _project_id)) 
    THEN
        RETURN;
    END IF;    

    _context_id = extensions.uuid_generate_v4();

    INSERT INTO public.contexts 
        (id, created_by, created_at, name, description, project_id) 
        VALUES (_context_id, auth.uid(), NOW(), _name, _description, _project_id);
    
    RETURN QUERY SELECT * FROM public.contexts WHERE id = _context_id;
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
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') 
      OR check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id)) 
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
$function$
;

CREATE OR REPLACE FUNCTION public.remove_users_from_context_rpc(_context_id uuid, _user_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _user uuid;
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

    -- Remove the users from the context_users table
    FOREACH _user IN ARRAY _user_ids 
    LOOP
      DELETE FROM public.context_users WHERE context_id = _context_id AND user_id = _user;
    END LOOP;

    RETURN TRUE;
END
$function$
;


