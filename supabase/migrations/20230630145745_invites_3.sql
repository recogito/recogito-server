drop trigger if exists "on_invite_accepted" on "public"."invites";

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
        VALUES ('projects', auth.uid(), NEW.project_group_id);
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER on_invite_accepted BEFORE UPDATE ON public.invites FOR EACH ROW EXECUTE FUNCTION accept_project_invite();


