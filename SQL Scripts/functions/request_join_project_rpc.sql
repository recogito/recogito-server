CREATE
OR REPLACE FUNCTION request_join_project_rpc (_project_id UUID) RETURNS BOOLEAN AS $body$
BEGIN

    -- They at least have to be authenticated
    IF NOT check_action_policy_organization(auth.uid(), 'documents', 'SELECT') 
      THEN
        RETURN FALSE;
    END IF;    

    IF EXISTS(SELECT * FROM public.projects p WHERE p.id = _project_id)
      THEN

      -- Cannot have multiple requests for some project from same person
      IF NOT EXISTS(SELECT * FROM public.join_requests jr WHERE jr.user_id = auth.uid() AND jr.project_id = _project_id)
        THEN
          INSERT INTO public.join_requests
            (user_id, project_id)
            VALUES (auth.uid(), _project_id);

          RETURN TRUE;
      END IF;  
    END IF;

    RETURN FALSE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;