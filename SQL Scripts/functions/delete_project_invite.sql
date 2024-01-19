CREATE OR REPLACE FUNCTION delete_invite(_invite_id uuid) RETURNS bool AS $$
DECLARE _project_id UUID;
BEGIN
    SELECT INTO _project_id i.project_id FROM public.invites i WHERE id = _invite_id;
    IF is_admin_project(auth.uid(), _project_id) OR is_admin_organization(auth.uid()) THEN
      DELETE FROM public.invites WHERE id = _invite_id;
      RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

