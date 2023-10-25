DROP TRIGGER IF EXISTS on_body_updated
    ON public.bodies;
CREATE TRIGGER on_body_updated
    BEFORE UPDATE ON public.bodies
    FOR EACH ROW EXECUTE PROCEDURE update_annotation_target_body();
