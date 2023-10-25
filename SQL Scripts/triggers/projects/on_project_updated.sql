DROP TRIGGER IF EXISTS on_project_updated
    ON public.projects;
CREATE TRIGGER on_project_updated
    BEFORE UPDATE ON public.projects
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
