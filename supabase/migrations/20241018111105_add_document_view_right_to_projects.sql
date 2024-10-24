create type "public".document_view_type as enum ('closed', 'annotations', 'notes');

alter table "public"."projects" add column "document_view_right" document_view_type default 'closed';

CREATE
    OR REPLACE FUNCTION create_project_rpc (
    _name VARCHAR,
    _description VARCHAR,
    _is_open_join BOOLEAN,
    _is_open_edit BOOLEAN,
    _document_view_right DOCUMENT_VIEW_TYPE
) RETURNS SETOF public.projects AS $body$
DECLARE
    _project_id uuid := gen_random_uuid();    -- The id of the new project
    _context_id uuid := gen_random_uuid();    -- The id of the default context
    _default_context_definition_id uuid;
BEGIN
    IF NOT check_action_policy_organization(auth.uid(), 'projects', 'INSERT') THEN
        RETURN;
    END IF;

    INSERT INTO public.projects (id, created_by, created_at, name, description, is_open_join, is_open_edit, document_view_right) VALUES (_project_id, auth.uid(), NOW(), _name, _description, _is_open_join, _is_open_edit, _document_view_right);

    INSERT INTO public.contexts (id, created_by, created_at, project_id, is_project_default) VALUES (_context_id, auth.uid(), NOW(), _project_id, TRUE);

    SELECT (id) INTO _default_context_definition_id FROM public.tag_definitions t WHERE t.scope = 'system' AND t.name = 'DEFAULT_CONTEXT';

    INSERT INTO public.tags (created_by, created_at, tag_definition_id, target_id) VALUES (auth.uid(), NOW(), _default_context_definition_id, _context_id);

    RETURN QUERY SELECT * FROM public.projects WHERE id = _project_id;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;