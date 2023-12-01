create type "public"."invite_option" as enum ('accept', 'ignore');

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.process_invite(_invite_id uuid, _option invite_option)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF EXISTS(SELECT * FROM public.invites i WHERE i.email = auth.email() AND i.id = _invite_id) THEN
        IF _option = 'accept' THEN
            UPDATE public.invites SET accepted = TRUE WHERE id = _invite_id;
            RETURN TRUE;
        ELSE
            IF _option = 'ignore' THEN
                UPDATE public.invites SET ignored = TRUE WHERE id = _invite_id;
                RETURN TRUE;
            END IF;
        END IF;
    END IF;
    RETURN FALSE;
END;
$function$
;


