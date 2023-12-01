DROP TRIGGER IF EXISTS on_project_group_created
    ON public.project_groups;
CREATE TRIGGER on_project_group_created
    BEFORE INSERT ON public.project_groups
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
