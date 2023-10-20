alter table "public"."invites" add column "invited_by_name" character varying not null;

alter table "public"."invites" add column "project_name" character varying not null;

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
        VALUES ('projects', auth.uid(), NEW.project_id);
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER on_invite_accepted BEFORE INSERT ON public.invites FOR EACH ROW EXECUTE FUNCTION accept_project_invite();


