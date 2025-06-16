DROP TRIGGER IF EXISTS on_notification_created
    ON public.notifications;
CREATE TRIGGER on_notification_created
    BEFORE INSERT ON public.notifications
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();