CREATE
OR REPLACE FUNCTION check_layer_context_for_open_edit () RETURNS TRIGGER AS $$
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
$$ LANGUAGE PLPGSQL SECURITY DEFINER;