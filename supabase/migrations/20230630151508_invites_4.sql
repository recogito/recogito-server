set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.accept_project_invite()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.accepted IS TRUE THEN
        INSERT INTO public.group_users
            (group_type, user_id, type_id)
        VALUES ('project', auth.uid(), NEW.project_group_id);
    END IF;
    RETURN NEW;
END;
$function$
;


