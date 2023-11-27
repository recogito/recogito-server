create table "public"."_id" (
    "id" uuid
);


alter table "public"."organization_groups" add column "is_default" boolean default false;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_user_to_org_default(user_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE _id uuid;
BEGIN
  IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE) 
  THEN 
    INSERT INTO public.group_users (user_id, group_type, type_id) SELECT $1, 'organization', id 
    FROM public.organization_groups WHERE is_default = TRUE;
  END IF;

  RETURN;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _id UUID;
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email);
      IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE)
        THEN
            SELECT id INTO _id FROM public.organization_groups WHERE is_default = TRUE;
            INSERT INTO public.group_users (user_id, group_type, type_id) VALUES (NEW.id, 'organization', _id);
        END IF;
    RETURN new;
END;
$function$
;


