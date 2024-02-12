CREATE
OR REPLACE FUNCTION cron_schedule_rpc (
    _schedule_name VARCHAR,
    _schedule VARCHAR,
    _url VARCHAR
) RETURNS BOOLEAN
AS $body$
BEGIN
    IF NOT is_(auth.uid(), 'projects', 'INSERT') THEN
        RETURN;
    END IF;    

    INSERT INTO public.projects (id, created_by, created_at, name, description, is_open_join, is_open_edit) VALUES (_project_id, auth.uid(), NOW(), _name, _description, _is_open_join, _is_open_edit);

    INSERT INTO public.contexts (id, created_by, created_at, project_id, is_project_default) VALUES (_context_id, auth.uid(), NOW(), _project_id, TRUE);

    SELECT (id) INTO _default_context_definition_id FROM public.tag_definitions t WHERE t.scope = 'system' AND t.name = 'DEFAULT_CONTEXT';

    INSERT INTO public.tags (created_by, created_at, tag_definition_id, target_id) VALUES (auth.uid(), NOW(), _default_context_definition_id, _context_id);    
    
    RETURN QUERY SELECT * FROM public.projects WHERE id = _project_id;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;