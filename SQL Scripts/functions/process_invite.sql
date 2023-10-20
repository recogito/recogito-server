CREATE TYPE invite_option AS ENUM ('accept', 'ignore');

CREATE OR REPLACE FUNCTION process_invite(_invite_id uuid, _option invite_option) RETURNS bool
AS
$$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
