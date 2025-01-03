CREATE
OR REPLACE FUNCTION set_context_to_all_members (
    _context_id uuid,
    _is_all_members BOOLEAN
) RETURNS BOOLEAN AS $body$
DECLARE
    _project_id uuid;
    _project_group_id uuid;
    _role_id uuid;
    _record RECORD;
BEGIN

    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check user has the right policy
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') 
        OR check_action_policy_project(auth.uid(), 'contexts', 'INSERT', _project_id)) 
    THEN
        RETURN FALSE;
    END IF;    

    -- Update the context
    UPDATE public.contexts c 
    SET assign_all_members = _is_all_members
    WHERE c.id = _context_id;

    -- If we are setting assign_all_members to TRUE
    IF _is_all_members
      THEN

      -- Get the default group
      SELECT g.role_id INTO _role_id 
      FROM public.default_groups g 
      WHERE g.group_type = 'layer' AND g.is_default = TRUE;

      -- Get the project group
      SELECT pg.id INTO _project_group_id 
      FROM public.project_groups pg 
      WHERE pg.project_id = _project_id AND pg.is_default = TRUE;

      -- Iterate all team members and add to context   
      FOR _record IN SELECT * 
      FROM public.group_users 
      WHERE group_type = 'project' AND type_id = _project_group_id
        LOOP
          IF NOT EXISTS(SELECT 1 FROM public.context_users cu WHERE cu.context_id = _context_id AND cu.user_id = _record.user_id)
            THEN
              INSERT INTO public.context_users
              (context_id, user_id, role_id) 
              VALUES(_context_id, _record.user_id, _role_id);
          END IF;
        END LOOP;
    END IF;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;