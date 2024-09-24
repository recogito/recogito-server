CREATE
OR REPLACE FUNCTION lock_project_rpc (
  _project_id uuid
) RETURNS BOOLEAN 
AS $body$
DECLARE
  _project_read_only_group_id uuid;
  _project_group_ids uuid[];
  _project_admin_ids uuid[];
  _project_group_id uuid;
  _row_group_users public.group_users % rowtype;
  _read_only_layer_role uuid;
  _context_ids uuid[];
  _context_id uuid;
  _user_id uuid;
BEGIN
  -- Must have Update privs on project 
  IF NOT (check_action_policy_organization(auth.uid(), 'projects', 'UPDATE') 
    OR check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _project_id)) 
  THEN
      RETURN FALSE;
  END IF;

  -- Select the read only project default group
  SELECT pg.id INTO _project_read_only_group_id 
    FROM public.project_groups pg
    WHERE pg.project_id = _project_id
    AND pg.is_read_only IS TRUE;

  -- Create an array of project_group ids
  _project_group_ids := ARRAY(
    SELECT pg.id
    FROM public.project_groups pg 
    WHERE pg.project_id = _project_id
    AND pg.is_read_only IS NOT TRUE
  );

  -- Create an array of user ids 
  _project_admin_ids := ARRAY(
    SELECT gu.user_id
    FROM public.group_users gu 
    WHERE gu.type_id = ANY(_project_group_ids)
  );

  -- For each project group user, set them to read-only
  FOREACH _project_group_id IN ARRAY _project_group_ids 
  LOOP
    UPDATE public.group_users 
    SET type_id = _project_read_only_group_id
    WHERE type_id = _project_group_id 
    AND group_type = 'project';
  END LOOP;

  -- If we do not have a read-only layer default group then fail
  IF NOT EXISTS(SELECT 1 FROM public.default_groups dgx WHERE dgx.group_type = 'layer' AND dgx.is_read_only IS TRUE)
  THEN
    ROLLBACK;
    RETURN FALSE;
  END IF;

  -- Get the read only role from default groups
  SELECT dgx.role_id INTO _read_only_layer_role FROM public.default_groups dgx WHERE dgx.group_type = 'layer' AND dgx.is_read_only IS TRUE;

  -- Get an array of context ids for this project
  _context_ids := ARRAY(
    SELECT c.id
    FROM public.contexts c 
    WHERE c.project_id = _project_id
  );

  -- Set all context users to read-only
  FOREACH _context_id IN ARRAY _context_ids 
  LOOP
    UPDATE public.context_users 
    SET role_id = _read_only_layer_role
    WHERE _context_id = _context_id;
  END LOOP;

  -- Add the admins to each context as read-only
  FOREACH _context_id IN ARRAY _context_ids 
  LOOP
    FOREACH _user_id IN ARRAY _project_admin_ids
    LOOP
      INSERT INTO public.context_users
      (role_id, user_id, context_id)
      VALUES (_read_only_layer_role, _user_id, _context_id)
      ON CONFLICT(user_id, context_id)
      DO NOTHING;
    END LOOP;
  END LOOP;

  -- Set the admins to the read only project group

  -- Update the project
  UPDATE public.projects 
  SET is_locked = TRUE
  WHERE id = _project_id;

  -- Success
  RETURN TRUE;

END
$body$ LANGUAGE plpgsql SECURITY DEFINER;