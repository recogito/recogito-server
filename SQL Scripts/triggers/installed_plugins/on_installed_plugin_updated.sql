DROP TRIGGER IF EXISTS on_installed_plugin_updated
    ON public.installed_plugins;
CREATE TRIGGER on_installed_plugin_updated
    BEFORE UPDATE ON public.installed_plugins
    FOR EACH ROW EXECUTE PROCEDURE update_dates_and_user();