CREATE
OR REPLACE FUNCTION check_group_user_for_open_edit () RETURNS TRIGGER AS $$
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
$$ LANGUAGE PLPGSQL SECURITY DEFINER;