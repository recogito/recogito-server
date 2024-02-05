CREATE
OR REPLACE FUNCTION check_group_user_for_open_edit () RETURNS TRIGGER AS $$
DECLARE
  _project_id uuid;
  _is_default_group BOOLEAN;
  _context_id uuid;
  _is_open_edit BOOLEAN;
  _record RECORD;
  _layer_group_id uuid;
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

      -- Iterate all of the layers and add the users
      FOR _record IN SELECT * from public.layer_contexts l WHERE l.context_id = _context_id LOOP

        -- Get the layer group
        SELECT (id) INTO _layer_group_id FROM public.layer_groups g WHERE g.layer_id = _record.layer_id and g.is_default IS TRUE;

        INSERT INTO public.group_users (group_type, user_id, type_id)
        VALUES ('layer',NEW.user_id, _layer_group_id);
      END LOOP; 
    END IF;
  END IF;
  RETURN NEW;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER;