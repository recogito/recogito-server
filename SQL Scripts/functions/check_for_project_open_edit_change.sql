
CREATE
OR REPLACE FUNCTION check_for_project_open_edit_change () RETURNS TRIGGER AS $$
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
$$ LANGUAGE PLPGSQL SECURITY DEFINER;