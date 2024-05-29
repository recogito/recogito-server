DO $$
DECLARE
  _t_row_group public.group_users % rowtype;
  _t_row_layer public.layers % rowtype;
  _context_id uuid;
  _default_layer_role_id uuid;
  _layer_group_id uuid;
BEGIN
  -- This is the migration to support moving from layer_groups to context_users 
  FOR _t_row_layer IN SELECT * FROM public.layers l WHERE l.is_archived IS FALSE 
  LOOP
    RAISE LOG 'Processing Layer %',  _t_row_layer.id;
    -- Get the context id.  At this point there should only be one per layer
    SELECT lc.context_id INTO _context_id FROM public.layer_contexts lc WHERE lc.layer_id = _t_row_layer.id;

    -- Make this the active layer context
    UPDATE public.layer_contexts SET is_active_layer = TRUE WHERE context_id = _context_id;

    -- Create the context_documents entry
    INSERT INTO public.context_documents (context_id, document_id) VALUES (_context_id, _t_row_layer.document_id) ON CONFLICT DO NOTHING;

    -- Now create the context_user entry
    -- At this point there should only be the default layer groups with users
    SELECT dg.role_id INTO _default_layer_role_id 
      FROM public.default_groups dg 
      WHERE dg.group_type = 'layer' AND dg.is_default IS TRUE;

    -- Get the layer_group id
    SELECT lg.id INTO _layer_group_id 
      FROM public.layer_groups lg 
      WHERE lg.layer_id = _t_row_layer.id AND lg.role_id = _default_layer_role_id;

    -- For each member of the group add them to the context_users table if they do not already exist
    FOR _t_row_group  IN SELECT * 
      FROM public.group_users gu 
      WHERE gu.group_type = 'layer' AND gu.type_id = _layer_group_id 
      LOOP
        RAISE LOG 'Inserting context_user %',  _t_row_group.user_id;
        INSERT INTO public.context_users (context_id, user_id, role_id)
          VALUES (_context_id, _t_row_group.user_id, _default_layer_role_id) ON CONFLICT DO NOTHING;
      END LOOP;
  END LOOP;
END
$$