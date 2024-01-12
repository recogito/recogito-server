CREATE OR REPLACE FUNCTION get_profiles_extended() RETURNS TABLE ( id uuid,
                                                                   nickname VARCHAR, 
                                                                   first_name VARCHAR, 
                                                                   last_name VARCHAR, 
                                                                   avatar_url VARCHAR,
                                                                   email_address VARCHAR, 
                                                                   last_sign_in_at timestamptz,
                                                                   org_group_id uuid,
                                                                   org_group_name VARCHAR ) 
AS $body$
  BEGIN

  IF public.is_admin_organization(auth.uid()) THEN
    RETURN QUERY
      SELECT p.id,
        p.nickname,
        p.first_name,
        p.last_name,
        p.avatar_url,
        u.email,
        u.last_sign_in_at,
        og.id,
        og.name
    FROM public.profiles p
      INNER JOIN public.group_users gu ON p.id = gu.user_id
      AND gu.group_type = 'organization'
      INNER JOIN public.organization_groups og ON og.id = gu.type_id
      INNER JOIN auth.users u ON u.id = p.id;
  END IF;
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER;