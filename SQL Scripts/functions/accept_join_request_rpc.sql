
CREATE
OR REPLACE FUNCTION accept_join_request_rpc (
    _project_id uuid,
    _request_id uuid 
) RETURNS BOOLEAN AS $body$
DECLARE
    _default_group_id uuid;
    _request public.join_requests % rowtype;
BEGIN
    -- Check project policy that contexts can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'projects', 'UPDATE') 
      OR check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _project_id)) 
    THEN
        RETURN FALSE;
    END IF;

    --  Get the request
    SELECT * INTO _request FROM public.join_requests jr WHERE jr.id = _request_id LIMIT 1;

    -- Get the group id
    SELECT g.id INTO _default_group_id FROM public.project_groups g WHERE g.project_id = _project_id AND g.is_default = TRUE;

    -- Add the user to the project
    INSERT INTO public.group_users
          (group_type, type_id, user_id) 
      VALUES('project', _default_group_id, _request.user_id);

    -- Delete the request
    DELETE FROM public.join_requests WHERE id = _request_id;

    -- Check for assign_all contexts
    PERFORM do_assign_all_check_for_user(_project_id, _request.user_id);

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;