CREATE OR REPLACE FUNCTION delete_user(_user_id uuid) RETURNS BOOLEAN AS $$
BEGIN
  IF is_admin_organization(auth.uid()) THEN
    DELETE FROM auth.users WHERE auth.users.id = _user_id;
    UPDATE public.profiles 
        SET first_name = '', last_name = '', nickname = '', email = '', avatar_url = '' 
        WHERE id = _user_id; 
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END $$ LANGUAGE 'plpgsql' SECURITY DEFINER;
