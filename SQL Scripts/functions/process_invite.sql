-- CREATE TYPE invite_option AS ENUM ('accept', 'ignore', 'unignore');

CREATE OR REPLACE FUNCTION process_invite(_invite_id uuid, _option invite_option) RETURNS bool
AS
$$
BEGIN
    IF EXISTS(SELECT * FROM public.invites i WHERE i.email = auth.email() AND i.id = _invite_id AND i.accepted = FALSE) THEN
        IF _option = 'accept' THEN
            UPDATE public.invites SET accepted = TRUE WHERE id = _invite_id;
            RETURN TRUE;
        ELSIF _option = 'ignore' THEN
                UPDATE public.invites SET ignored = TRUE WHERE id = _invite_id;
                RETURN TRUE;
        ELSIF _option = 'unignore' THEN
                UPDATE public.invites SET ignored = FALSE WHERE id = _invite_id;
                RETURN TRUE;
        END IF;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
