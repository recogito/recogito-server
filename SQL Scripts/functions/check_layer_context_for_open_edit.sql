CREATE
OR REPLACE FUNCTION check_layer_context_for_open_edit () RETURNS TRIGGER AS $$
DECLARE
  _project_id uuid;
  _context_name VARCHAR;
  _is_project_default BOOLEAN;  
  _is_open_edit BOOLEAN;
  _record RECORD;
  _project_group_id uuid;
  _layer_group_id uuid;
  _id uuid;
BEGIN
  -- See if the layer is in the default context on an open edit project
  SELECT c.project_id, c.name, c.is_project_default INTO _project_id, _context_name, _is_project_default FROM public.contexts c WHERE c.id = NEW.context_id;
  SELECT is_open_edit INTO _is_open_edit FROM public.projects p WHERE p.id = _project_id;

  IF _is_open_edit AND _context_name IS NULL THEN
    -- Get the project group
    SELECT (id) INTO _project_group_id FROM public.project_groups WHERE project_id = _project_id and is_default = TRUE;

    -- Get the layer group
    SELECT (id) INTO _layer_group_id FROM public.layer_groups WHERE layer_id = NEW.layer_id and is_default IS TRUE;

    RAISE LOG '_layer_group_id %',_layer_group_id;
    -- Add all project members to default layer group
    FOR _record IN SELECT * FROM public.group_users WHERE group_type = 'project' AND type_id = _project_group_id
    LOOP
        INSERT INTO public.group_users (group_type, user_id, type_id)
        VALUES ('layer',_record.user_id, _layer_group_id);
    END LOOP; 
  END IF;

  RETURN NEW;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER;