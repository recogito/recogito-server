CREATE
    OR REPLACE FUNCTION create_tags_for_targets_rpc (
    _tag_definition_id uuid,
    _target_ids uuid[]
) RETURNS BOOLEAN AS $body$
DECLARE
    _scope tag_scope_types;
    _scope_id uuid;
BEGIN
    SELECT td.scope, td.scope_id INTO _scope, _scope_id
      FROM public.tag_definitions td
     WHERE td.id = _tag_definition_id;

    -- Check authorization
    IF NOT (public.check_action_policy_user_from_tag_definition(auth.uid(), _tag_definition_id))
    THEN
        RETURN FALSE;
    END IF;

    -- Delete any tags that are no longer in the list of tag_definition_ids
    UPDATE public.tags t
       SET is_archived = TRUE
     WHERE t.tag_definition_id = _tag_definition_id
       AND NOT ( t.target_id = ANY( _target_ids ));

    -- Create new tags
    INSERT INTO public.tags (tag_definition_id, target_id)
    SELECT _tag_definition_id, id
      FROM UNNEST( _target_ids ) AS id
     WHERE NOT EXISTS ( SELECT 1
                          FROM public.tags t
                         WHERE t.tag_definition_id = _tag_definition_id
                           AND t.target_id = id
                           AND t.is_archived = FALSE );

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;