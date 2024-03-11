DO $$
DECLARE
  t_row public.group_users % rowtype;
BEGIN
  FOR t_row IN SELECT * FROM public.group_users c WHERE c.group_type = 'organization' LOOP
    UPDATE public.group_users SET type_id = '350abe76-937b-4a9b-9600-9b1f856db250' WHERE id = t_row.id; 
  END LOOP;
END
$$