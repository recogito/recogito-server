DO $$
DECLARE
  t_row public .profiles % rowtype;
  _group_id UUID;
BEGIN
SELECT id INTO _group_id
FROM public .organization_groups
WHERE name = 'Org Readers';
FOR t_row IN SELECT * FROM public .profiles LOOP
  IF NOT EXISTS(
    SELECT 1
    FROM public.group_users
    WHERE user_id = t_row.id
    AND group_type = 'organization'
  ) THEN
    INSERT INTO public.group_users (group_type, user_id, type_id)
      VALUES (
        'organization',
        t_row.id,
        _group_id
      );
    END IF;
  END LOOP;
END;
$$