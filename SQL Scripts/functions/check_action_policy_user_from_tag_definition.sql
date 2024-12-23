CREATE OR REPLACE FUNCTION check_action_policy_user_from_tag_definition(user_id uuid, tag_definition_id uuid)
    RETURNS bool
    AS $body$
DECLARE
    _scope      VARCHAR;
    _scope_id   UUID;
BEGIN
    SELECT scope, scope_id INTO _scope, _scope_id FROM public.tag_definitions WHERE id = tag_definition_id;

    RETURN _scope = 'user' AND _scope_id = user_id;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;