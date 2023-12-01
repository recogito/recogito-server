DROP TRIGGER IF EXISTS on_invite_updated
    ON public.invites;
CREATE TRIGGER on_invite_updated
    BEFORE UPDATE ON public.invites
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
