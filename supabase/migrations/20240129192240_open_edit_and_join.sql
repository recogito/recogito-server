drop policy "Users with correct policies can SELECT on project_groups" on "public"."project_groups";

drop policy "Users with correct policies can SELECT on projects" on "public"."projects";

alter table "public"."contexts" add column "is_project_default" boolean default false;

alter table "public"."projects" add column "is_open_edit" boolean default false;

alter table "public"."projects" add column "is_open_join" boolean default false;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_group_user_for_open_edit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _project_id uuid;
  _is_default_group BOOLEAN;
  _context_id uuid;
  _is_open_edit BOOLEAN;
  _record RECORD;
  _layer_group_id uuid;
BEGIN
  -- Is this a project group?
  IF NEW.group_type = 'project' THEN
    -- Get the project group
    SELECT g.is_default, g.project_id INTO _is_default_group, _project_id FROM public.project_groups g WHERE g.id = NEW.type_id;

    -- Get the project
    SELECT is_open_edit INTO _is_open_edit FROM public.projects p WHERE p.id = _project_id;

    -- Is this a new member of the default group of an open edit project
    IF _is_open_edit AND _is_default_group THEN

      -- Get the default context
      SELECT c.id INTO _context_id FROM public.contexts c WHERE c.project_id = _project_id AND c.name IS NULL;

      -- Iterate all of the layers and add the users
      FOR _record IN SELECT * from public.layer_contexts l WHERE l.context_id = _context_id LOOP

        -- Get the layer group
        SELECT (id) INTO _layer_group_id FROM public.layer_groups g WHERE g.layer_id = _record.layer_id and g.is_default IS TRUE;

        INSERT INTO public.group_users (group_type, user_id, type_id)
        VALUES ('layer',NEW.user_id, _layer_group_id);
      END LOOP; 
    END IF;
  END IF;
  RETURN NEW;
END
$function$
;

CREATE OR REPLACE FUNCTION public.check_layer_context_for_open_edit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _project_id uuid;
  _context_name VARCHAR;
  _is_project_default BOOLEAN;  
  _is_open_edit BOOLEAN;
  _record RECORD;
  _project_group_id uuid;
  _layer_group_id uuid;
  _id uuid;
BEGIN
  -- See if the layer is in the default context on an open edit project
  SELECT c.project_id, c.name, c.is_project_default INTO _project_id, _context_name, _is_project_default FROM public.contexts c WHERE c.id = NEW.context_id;
  SELECT is_open_edit INTO _is_open_edit FROM public.projects p WHERE p.id = _project_id;

  IF _is_open_edit AND _context_name IS NULL THEN
    -- Get the project group
    SELECT (id) INTO _project_group_id FROM public.project_groups WHERE project_id = _project_id and is_default = TRUE;

    -- Get the layer group
    SELECT (id) INTO _layer_group_id FROM public.layer_groups WHERE layer_id = NEW.layer_id and is_default IS TRUE;

    RAISE LOG '_layer_group_id %',_layer_group_id;
    -- Add all project members to default layer group
    FOR _record IN SELECT * FROM public.group_users WHERE group_type = 'project' AND type_id = _project_group_id
    LOOP
        INSERT INTO public.group_users (group_type, user_id, type_id)
        VALUES ('layer',_record.user_id, _layer_group_id);
    END LOOP; 
  END IF;

  RETURN NEW;
END
$function$
;

CREATE OR REPLACE FUNCTION public.create_project_rpc(_name character varying, _description character varying, _is_open_join boolean, _is_open_edit boolean)
 RETURNS SETOF projects
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid := gen_random_uuid();    -- The id of the new project
    _context_id uuid := gen_random_uuid();    -- The id of the default context
    _default_context_definition_id uuid;
BEGIN
    IF NOT check_action_policy_organization(auth.uid(), 'projects', 'INSERT') THEN
        RETURN;
    END IF;    

    INSERT INTO public.projects (id, created_by, created_at, name, description, is_open_join, is_open_edit) VALUES (_project_id, auth.uid(), NOW(), _name, _description, _is_open_join, _is_open_edit);

    INSERT INTO public.contexts (id, created_by, created_at, project_id, is_project_default) VALUES (_context_id, auth.uid(), NOW(), _project_id, TRUE);

    SELECT (id) INTO _default_context_definition_id FROM public.tag_definitions t WHERE t.scope = 'system' AND t.name = 'DEFAULT_CONTEXT';

    INSERT INTO public.tags (created_by, created_at, tag_definition_id, target_id) VALUES (auth.uid(), NOW(), _default_context_definition_id, _context_id);    
    
    RETURN QUERY SELECT * FROM public.projects WHERE id = _project_id;
END
$function$
;

CREATE OR REPLACE FUNCTION public.join_project_rpc(_project_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _is_open_join BOOLEAN;
  _project_group_id uuid;
BEGIN


    SELECT (is_open_join) INTO _is_open_join FROM public.projects WHERE id = _project_id;

    -- They at least have to be authenticated
    IF NOT check_action_policy_organization(auth.uid(), 'documents', 'SELECT') OR _is_open_join IS FALSE THEN
        RETURN FALSE;
    END IF;    

    SELECT (id) INTO _project_group_id FROM public.project_groups WHERE project_id = _project_id AND is_default IS TRUE;

    INSERT INTO public.group_users
      (group_type, user_id, type_id)
      VALUES 
      ('project', auth.uid(), _project_group_id);

    RETURN TRUE;
END
$function$
;

create policy "Users with correct policies can SELECT on project_groups"
on "public"."project_groups"
as permissive
for select
to authenticated
using ((((is_archived IS FALSE) AND (EXISTS ( SELECT 1
   FROM projects
  WHERE ((projects.id = project_groups.project_id) AND (projects.is_open_join IS TRUE))))) OR ((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'project_groups'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'project_groups'::character varying, 'SELECT'::operation_types, project_id)))));


create policy "Users with correct policies can SELECT on projects"
on "public"."projects"
as permissive
for select
to authenticated
using ((((is_archived IS FALSE) AND (is_open_join IS TRUE)) OR ((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'projects'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'projects'::character varying, 'SELECT'::operation_types, id)))));


CREATE TRIGGER on_group_user_created_open_edit_check AFTER INSERT ON public.group_users FOR EACH ROW EXECUTE FUNCTION check_group_user_for_open_edit();

CREATE TRIGGER on_layer_context_created_check_open_edit AFTER INSERT ON public.layer_contexts FOR EACH ROW EXECUTE FUNCTION check_layer_context_for_open_edit();


