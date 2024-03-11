DROP TRIGGER IF EXISTS on_project_updated_check_open_edit
    ON public.projects;
CREATE TRIGGER on_project_updated_check_open_edit
    AFTER UPDATE ON public.projects
    FOR EACH ROW EXECUTE PROCEDURE check_for_project_open_edit_change();