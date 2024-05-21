
CREATE
OR REPLACE FUNCTION remove_user_from_project_rpc (
    _project_id uuid,
    _user_id uuid 
) RETURNS BOOLEAN AS $body$
DECLARE
    _project_group_id uuid;
    _context_id uuid;
    _context_row public.contexts % rowtype;
    _query TEXT;
BEGIN

    -- Check project policy that projects can be updated by this user
    IF NOT (
        check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _project_id) OR 
        check_action_policy_organization(auth.uid(), 'projects', 'UPDATE')
    ) THEN
        RETURN FALSE;
    END IF;  

    FOR _project_group_id IN SELECT pg.id 
      FROM public.project_groups pg WHERE pg.project_id = _project_id
    LOOP 
        DELETE FROM public.group_users gu WHERE gu.group_type = 'project' AND gu.type_id = _project_group_id;
    END LOOP;

    -- Remove the users from the context_users table
    FOR _context_row IN SELECT * 
      FROM public.contexts c WHERE c.project_id = _project_id
    LOOP
      DELETE FROM public.context_users WHERE context_id = _context_row.id AND user_id = _user_id;
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;