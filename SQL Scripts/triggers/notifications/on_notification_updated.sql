DROP TRIGGER IF EXISTS on_notification_updated
    ON public.notifications;
CREATE TRIGGER on_notification_updated
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();