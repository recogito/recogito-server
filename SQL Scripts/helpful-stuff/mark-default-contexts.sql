DO $$
DECLARE
  t_row public.contexts % rowtype;
BEGIN
  FOR t_row IN SELECT * FROM public.contexts c WHERE c.name IS NULL  LOOP
    UPDATE public.contexts SET is_project_default = TRUE WHERE id = t_row.id; 
  END LOOP;
END
$$