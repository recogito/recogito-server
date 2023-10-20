DROP TRIGGER IF EXISTS on_invite_created
    ON public.invites;
CREATE TRIGGER on_invite_created
    BEFORE INSERT ON public.invites
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
