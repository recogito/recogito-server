CREATE
OR REPLACE FUNCTION leave_project_rpc (_project_id UUID) RETURNS BOOLEAN AS $body$
DECLARE
  _project_group_id uuid;
  _group_user_id uuid;
BEGIN


    -- They at least have to be authenticated
    IF NOT check_action_policy_organization(auth.uid(), 'documents', 'SELECT') THEN
        RETURN FALSE;
    END IF;    

    SELECT (id) INTO _project_group_id FROM public.project_groups WHERE project_id = _project_id AND is_default IS TRUE;

    SELECT gu.id INTO _group_user_id FROM public.group_users gu 
      INNER JOIN public.project_groups pg ON pg.project_id = _project_id 
      WHERE gu.type_id = pg.id AND gu.user_id = auth.uid();

    IF _group_user_id IS NOT NULL THEN
      DELETE FROM public.group_users WHERE id = _group_user_id;
    ELSE 
      RETURN FALSE;
    END IF;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;