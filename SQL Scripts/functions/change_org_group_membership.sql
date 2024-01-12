CREATE OR REPLACE FUNCTION change_org_group_membership(_user_id uuid, _new_group_id uuid) RETURNS BOOLEAN
AS $body$
  BEGIN

  IF public.is_admin_organization(auth.uid()) THEN
    UPDATE public.group_users SET type_id = _new_group_id WHERE user_id = _user_id AND group_type = 'organization';
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER;