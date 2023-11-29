CREATE
OR REPLACE FUNCTION add_user_to_org_default (user_id UUID) RETURNS void AS $body$
DECLARE _id UUID;
BEGIN
  IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE) 
  THEN 
    SELECT id INTO _id FROM public.organization_groups WHERE is_default = TRUE;
    INSERT INTO public.group_users (user_id, group_type, type_id) VALUES ($1, 'organization', _id);
  END IF;

  RETURN;
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER;