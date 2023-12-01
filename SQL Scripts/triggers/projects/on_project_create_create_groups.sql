DROP TRIGGER IF EXISTS on_project_created_create_groups
    ON public.projects;
CREATE TRIGGER on_project_created_create_groups
    AFTER INSERT ON public.projects
    FOR EACH ROW EXECUTE PROCEDURE create_default_project_groups();
