DROP TRIGGER IF EXISTS on_project_created
    ON public.projects;
CREATE TRIGGER on_project_created
    BEFORE INSERT ON public.projects
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
