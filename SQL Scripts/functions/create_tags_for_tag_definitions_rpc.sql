CREATE
    OR REPLACE FUNCTION create_tags_for_tag_definitions_rpc(
    _tag_definition_ids uuid[],
    _scope tag_scope_types,
    _scope_id uuid,
    _target_type tag_target_types,
    _target_id uuid
) RETURNS BOOLEAN AS $body$
DECLARE
    _new_tag_definition_ids uuid[];
    _tag_definition_id uuid;
BEGIN
    -- Check authorization
    IF NOT (_scope = 'user' AND _scope_id = auth.uid())
    THEN
        RETURN FALSE;
    END IF;

    -- Delete any tags that are no longer in the list of tag_definition_ids
    UPDATE public.tags t
       SET is_archived = TRUE
      FROM public.tag_definitions td
     WHERE td.id = t.tag_definition_id
       AND td.scope = _scope
       AND td.scope_id = _scope_id
       AND td.target_type = _target_type
       AND t.target_id = _target_id
       AND NOT ( t.tag_definition_id = ANY( _tag_definition_ids ));

    -- Create new tags
    _new_tag_definition_ids := ARRAY(
        SELECT id
          FROM public.tag_definitions td
         WHERE td.is_archived = FALSE
           AND td.scope = _scope
           AND td.scope_id = _scope_id
           AND td.target_type = _target_type
           AND td.id = ANY( _tag_definition_ids )
           AND NOT EXISTS (SELECT 1
                             FROM public.tags t
                            WHERE t.tag_definition_id = td.id
                              AND t.target_id = _target_id
                              AND t.is_archived = FALSE)
   );

    FOREACH _tag_definition_id IN ARRAY _new_tag_definition_ids
    LOOP
        INSERT INTO public.tags (tag_definition_id, target_id) VALUES (_tag_definition_id, _target_id);
    END LOOP;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;