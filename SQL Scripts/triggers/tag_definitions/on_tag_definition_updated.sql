DROP TRIGGER IF EXISTS on_tag_definition_updated
    ON public.tag_definitions;
CREATE TRIGGER on_tag_definition_updated
    BEFORE UPDATE ON public.tag_definitions
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
