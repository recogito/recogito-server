DROP TRIGGER IF EXISTS on_target_updated
    ON public.targets;
CREATE TRIGGER on_target_updated
    BEFORE UPDATE ON public.targets
    FOR EACH ROW EXECUTE PROCEDURE update_annotation_target_body();
