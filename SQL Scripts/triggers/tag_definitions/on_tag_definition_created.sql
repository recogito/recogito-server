DROP TRIGGER IF EXISTS on_tag_definition_created
    ON public.tag_definitions;
CREATE TRIGGER on_tag_definition_created
    BEFORE INSERT ON public.tag_definitions
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
