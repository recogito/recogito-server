DROP TRIGGER IF EXISTS on_project_updated_check_archive
    ON public.projects;
CREATE TRIGGER on_project_updated_check_archive
    BEFORE UPDATE ON public.projects
    FOR EACH ROW EXECUTE PROCEDURE check_archive_project();
