CREATE
OR REPLACE FUNCTION join_project_rpc (_project_id UUID) RETURNS BOOLEAN AS $body$
DECLARE
  _is_open_join BOOLEAN;
  _project_group_id uuid;
BEGIN


    SELECT (is_open_join) INTO _is_open_join FROM public.projects WHERE id = _project_id;

    -- They at least have to be authenticated
    IF NOT check_action_policy_organization(auth.uid(), 'documents', 'SELECT') OR _is_open_join IS FALSE THEN
        RETURN FALSE;
    END IF;    

    SELECT (id) INTO _project_group_id FROM public.project_groups WHERE project_id = _project_id AND is_default IS TRUE;

    INSERT INTO public.group_users
      (group_type, user_id, type_id)
      VALUES 
      ('project', auth.uid(), _project_group_id);

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;