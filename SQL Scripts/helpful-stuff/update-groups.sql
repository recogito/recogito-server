DO $$
DECLARE
  t_row_project public.PROJECT_GROUPS % rowtype;
  t_row_layer public.LAYER_GROUPS % rowtype;
BEGIN

  FOR t_row_project IN SELECT * FROM public.PROJECT_GROUPS LOOP
    IF t_row_project.name = 'Project Admins' THEN
      UPDATE public.PROJECT_GROUPS SET is_admin = TRUE WHERE id = t_row_project.id;
    ELSIF t_row_project.name = 'Project Students' THEN
        UPDATE public.PROJECT_GROUPS SET is_default = TRUE WHERE id = t_row_project.id;      
    END IF;
  END LOOP;
  FOR t_row_layer IN SELECT * FROM public.LAYER_GROUPS LOOP
    IF t_row_layer.name = 'Layer Admin' THEN
      UPDATE public.LAYER_GROUPS SET is_admin = TRUE WHERE id = t_row+LABEL.id;
    ELSIF t_row_layer.name = 'Layer Student' THEN
      UPDATE public.LAYER_GROUPS SET is_default = TRUE WHERE id = t_row_layer.id;
    END IF;
  END LOOP;
END
$$