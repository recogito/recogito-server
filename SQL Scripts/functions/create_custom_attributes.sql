CREATE
OR REPLACE FUNCTION public.create_custom_attributes () RETURNS TRIGGER AS $$
DECLARE
  t_row public.attribute_mapping%rowtype;
BEGIN 
  FOR t_row IN SELECT * FROM public.attribute_mapping LOOP
    IF t_row.target_type = 'table' THEN
      EXECUTE format('UPDATE %I t
      SET %I = NEW.raw_user_meta_data->>%I
      WHERE t.%I = NEW.id', t_row.target_table, t_row.target_attribute,t_row.custom_claim, t.target_table_user_id);
    ELSIF t_row.target_type = 'org_group_override' THEN
      IF EXECUTE 't_row.attribute_value_mapping ->> ' || NEW.raw_user_meta_data->> t_row.custom_claim  || 'IS NOT NULL'  THEN
        EXECUTE format('UPDATE public.group_users g
        SET type_id = t_row.attribute_value_mapping ->> %I
        WHERE g.user_id = NEW.id', NEW.raw_user_meta_data->>t_row.custom_claim);
      END IF;
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;