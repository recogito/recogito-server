CREATE
OR REPLACE FUNCTION public.handle_new_user () RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    _id UUID;
    t_row public.attribute_mapping%rowtype;
    _first_name VARCHAR;
    _last_name VARCHAR;
    _nickname VARCHAR;
    _org_group_id uuid;
BEGIN
    FOR t_row IN SELECT * FROM public.attribute_mapping LOOP
        IF t_row.target_type = 'profiles_table' THEN
            EXECUTE '_' || t_row.target_attribute|| ' := ' || NEW.raw_user_meta_data || '::json ->> ' ||  '''' || t_row.custom_claim || '''';
        ELSIF t_row.target_type = 'org_group_override' THEN
            EXECUTE '_org_group_id := ' || NEW.raw_user_meta_data || '::json ->> ' || '''' ||  t_row.custom_claim || '''';
        END IF;
    END LOOP;
    IF _org_group_id IS NULL THEN
        IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE) THEN
            SELECT id INTO _org_group_id FROM public.organization_groups WHERE  is_default = TRUE;
        END IF;
    END IF;

    INSERT INTO public.profiles (id, email, first_name, last_name, nickname)
    VALUES (NEW.id, NEW.email, _first_name, _last_name, _nickname);

    IF _org_group_id IS NOT NULL THEN
        INSERT INTO public.group_users (user_id, group_type, type_id) VALUES (NEW.id, 'organization', _org_group_id);
    END IF;
   
    RETURN NEW;
END;
$$;