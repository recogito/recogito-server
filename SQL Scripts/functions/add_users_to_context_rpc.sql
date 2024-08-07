CREATE TYPE context_role_type AS ENUM ('admin', 'default');
CREATE TYPE add_user_type AS (user_id uuid, role context_role_type);

CREATE
OR REPLACE FUNCTION add_users_to_context_rpc (
    _context_id uuid,
    _users add_user_type[] 
) RETURNS BOOLEAN AS $body$
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
$body$ LANGUAGE plpgsql SECURITY DEFINER;