DROP TRIGGER IF EXISTS on_invite_accepted
    ON public.invites;
CREATE TRIGGER on_invite_accepted
    BEFORE UPDATE ON public.invites
    FOR EACH ROW EXECUTE PROCEDURE accept_project_invite();
