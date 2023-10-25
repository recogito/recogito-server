DROP TRIGGER IF EXISTS on_body_created
    ON public.bodies;
CREATE TRIGGER on_body_created
    BEFORE INSERT ON public.bodies
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
