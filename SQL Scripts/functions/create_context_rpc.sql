CREATE
OR REPLACE FUNCTION create_context_rpc (
    _project_id uuid,
    _name VARCHAR,
    _description VARCHAR
) RETURNS setof public.contexts AS $body$
DECLARE
    _context_id uuid;
BEGIN
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'INSERT') 
        OR check_action_policy_project(auth.uid(), 'contexts', 'INSERT', _project_id)) 
    THEN
        RETURN;
    END IF;    

    _context_id = extensions.uuid_generate_v4();

    INSERT INTO public.contexts 
        (id, created_by, created_at, name, description, project_id) 
        VALUES (_context_id, auth.uid(), NOW(), _name, _description, _project_id);
    
    RETURN QUERY SELECT * FROM public.contexts WHERE id = _context_id;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;