DO $$
DECLARE
  t_row public.group_users % rowtype;
BEGIN
  FOR t_row IN SELECT * FROM public.group_users c WHERE c.group_type = 'organization' LOOP
    UPDATE public.group_users SET type_id = 'f918b2f8-f587-4ee1-9f2d-35b3aed0b1e6' WHERE id = t_row.id; 
  END LOOP;
END
$$