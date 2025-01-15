CREATE
    OR REPLACE FUNCTION archive_tag_definition_rpc(_tag_definition_id uuid)
    RETURNS BOOLEAN AS $body$
BEGIN
    -- Check project policy that tag definition can be updated by this user
    IF NOT (check_action_policy_user_from_tag_definition(auth.uid(), _tag_definition_id))
    THEN
        RETURN FALSE;
    END IF;

    -- Archive the tag definition
    UPDATE public.tag_definitions td
       SET is_archived = TRUE
     WHERE td.id = _tag_definition_id;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;