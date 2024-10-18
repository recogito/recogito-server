DO $$
DECLARE
    _layer_group_id uuid;
    _role_id        uuid;
    _name           varchar;
    _description    varchar;
    _is_admin       bool;
    _is_default     bool;
    _is_read_only   bool;
    _layer_id       uuid;
BEGIN
  -- Get the read-only default group
  FOR _role_id, _name, _description, _is_admin, _is_default, _is_read_only
    IN SELECT dg.role_id, dg.name, dg.description, dg.is_admin, dg.is_default, dg.is_read_only
    FROM public.default_groups dg
    WHERE dg.group_type = 'layer' AND dg.is_read_only IS TRUE 
    LOOP
      -- Loop through all layers
      FOR _layer_id IN SELECT l.id FROM public.layers l
        LOOP
          IF NOT EXISTS(SELECT 1 FROM public.layer_groups lg WHERE lg.layer_id = _layer_id AND lg.is_read_only IS TRUE)
            THEN
              _layer_group_id = extensions.uuid_generate_v4();
              INSERT INTO public.layer_groups
                  (id, layer_id, role_id, name, description, is_admin, is_default, is_read_only)
              VALUES (_layer_group_id, _layer_id, _role_id, _name, _description, _is_admin, _is_default, _is_read_only);
            END IF;
        END LOOP;
    END LOOP;
END
$$