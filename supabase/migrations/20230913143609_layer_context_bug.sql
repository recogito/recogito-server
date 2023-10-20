drop trigger if exists "on_group_user_updated" on "public"."group_users";

CREATE TRIGGER on_group_user_updated BEFORE UPDATE ON public.group_users FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();


