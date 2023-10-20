DROP TRIGGER IF EXISTS on_organization_group_created
    ON public.organization_groups;
CREATE TRIGGER on_organization_group_created
    BEFORE INSERT ON public.organization_groups
    FOR EACH ROW EXECUTE PROCEDURE create_dates_and_user();
