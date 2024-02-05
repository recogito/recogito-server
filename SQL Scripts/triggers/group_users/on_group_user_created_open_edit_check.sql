DROP TRIGGER IF EXISTS on_group_user_created_open_edit_check ON public.group_users;

CREATE TRIGGER on_group_user_created_open_edit_check
AFTER INSERT ON public.group_users FOR EACH ROW
EXECUTE PROCEDURE check_group_user_for_open_edit ();