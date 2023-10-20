DROP TRIGGER IF EXISTS on_project_group_updated
    ON public.project_groups;
CREATE TRIGGER on_project_group_updated
    BEFORE UPDATE ON public.project_groups
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
