CREATE
OR REPLACE FUNCTION do_assign_all_check_for_user (_project_id UUID, _user_id UUID) RETURNS VOID AS $body$
DECLARE
  _context public.contexts % rowtype;
  _role_id uuid;
BEGIN
  -- Get the default group 
  SELECT g.role_id INTO _role_id 
  FROM public.default_groups g 
  WHERE g.group_type = 'layer' AND g.is_default = TRUE;

  -- Iterate all context in the project and check for the assign_all_members flag
  FOR _context IN SELECT * FROM public.contexts c WHERE c.project_id = _project_id
    LOOP
      IF _context.assign_all_members IS TRUE
        THEN
          IF NOT EXISTS(SELECT 1 FROM public.context_users cu WHERE cu.context_id = _context.id AND cu.user_id = _user_id)
            THEN 
              INSERT INTO public.context_users
                (context_id, user_id, role_id)
                VALUES 
                (_context.id, _user_id, _role_id);
          END IF;
      END IF;
    END LOOP;

  RETURN;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;