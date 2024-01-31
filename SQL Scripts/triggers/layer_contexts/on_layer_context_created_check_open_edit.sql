DROP TRIGGER IF EXISTS on_layer_context_created_check_open_edit ON public.layer_contexts;

CREATE TRIGGER on_layer_context_created_check_open_edit
AFTER INSERT ON public.layer_contexts FOR EACH ROW
EXECUTE PROCEDURE check_layer_context_for_open_edit ();