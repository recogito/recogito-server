set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.anonymize_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    UPDATE public.profiles
    SET first_name = '', last_name = '', nickname = '', email = '', avatar_url = '' 
    WHERE id = OLD.id;
    RETURN new;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.change_org_group_membership(_user_id uuid, _new_group_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
  BEGIN

  IF public.is_admin_organization(auth.uid()) THEN
    UPDATE public.group_users SET type_id = _new_group_id WHERE user_id = _user_id AND group_type = 'organization';
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_user(_user_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF is_admin_organization(auth.uid()) THEN
    DELETE FROM auth.users WHERE auth.users.id = _user_id;
    UPDATE public.profiles 
        SET first_name = '', last_name = '', nickname = '', email = '', avatar_url = '' 
        WHERE id = _user_id; 
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END $function$
;

CREATE OR REPLACE FUNCTION public.get_profiles_extended()
 RETURNS TABLE(id uuid, nickname character varying, first_name character varying, last_name character varying, avatar_url character varying, email_address character varying, last_sign_in_at timestamp with time zone, org_group_id uuid, org_group_name character varying)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;


CREATE TRIGGER on_auth_user_deleted AFTER DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION anonymize_profile();


