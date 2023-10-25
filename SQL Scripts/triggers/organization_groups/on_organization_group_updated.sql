DROP TRIGGER IF EXISTS on_organization_group_updated
    ON public.organization_groups;
CREATE TRIGGER on_organization_group_updated
    BEFORE UPDATE ON public.organization_groups
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();
