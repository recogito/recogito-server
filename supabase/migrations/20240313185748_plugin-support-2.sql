CREATE TRIGGER on_installed_plugin_updated BEFORE UPDATE ON public.installed_plugins FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();


