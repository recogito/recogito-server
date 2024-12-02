alter table "public"."contexts" add column "assign_all_members" boolean default false;

alter table "public"."project_documents" add column "sort" integer default 0;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.do_assign_all_check_for_user(_project_id uuid, _user_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _context public.contexts % rowtype;
  _role_id uuid;
BEGIN
  -- Get the default group 
  SELECT g.role_id INTO _role_id 
  FROM public.default_groups g 
  WHERE g.group_type = 'layer' AND g.is_default = TRUE;

  -- Iterate all context in the project and check for the assign_all_members flag
  FOR _context IN SELECT * FROM public.contexts c WHERE c.project_id = _project_id
    LOOP
      IF _context.assign_all_members IS TRUE
        THEN
          IF NOT EXISTS(SELECT 1 FROM public.context_users cu WHERE cu.context_id = _context.id AND cu.user_id = _user_id)
            THEN 
              INSERT INTO public.context_users
                (context_id, user_id, role_id)
                VALUES 
                (_context.id, _user_id, _role_id);
          END IF;
      END IF;
    END LOOP;

  RETURN;
END
$function$
;

CREATE OR REPLACE FUNCTION public.set_context_to_all_members(_context_id uuid, _is_all_members boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _project_id uuid;
    _project_group_id uuid;
    _role_id uuid;
    _record RECORD;
BEGIN

    -- Find the project for this context  
    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id 
      WHERE p.id = c.project_id;

    -- Check user has the right policy
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') 
        OR check_action_policy_project(auth.uid(), 'contexts', 'INSERT', _project_id)) 
    THEN
        RETURN FALSE;
    END IF;    

    -- Update the context
    UPDATE public.contexts c 
    SET assign_all_members = _is_all_members
    WHERE c.id = _context_id;

    -- If we are setting assign_all_members to TRUE
    IF _is_all_members
      THEN

      -- Get the default group
      SELECT g.role_id INTO _role_id 
      FROM public.default_groups g 
      WHERE g.group_type = 'layer' AND g.is_default = TRUE;

      -- Get the project group
      SELECT pg.id INTO _project_group_id 
      FROM public.project_groups pg 
      WHERE pg.project_id = _project_id AND pg.is_default = TRUE;

      -- Iterate all team members and add to context   
      FOR _record IN SELECT * 
      FROM public.group_users 
      WHERE group_type = 'project' AND type_id = _project_group_id
        LOOP
          IF NOT EXISTS(SELECT 1 FROM public.context_users cu WHERE cu.context_id = _context_id AND cu.user_id = _record.user_id)
            THEN
              INSERT INTO public.context_users
              (context_id, user_id, role_id) 
              VALUES(_context_id, _record.user_id, _role_id);
          END IF;
        END LOOP;
    END IF;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.update_project_documents_sort_rpc(_project_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _current_index integer = 0;
    _document_id uuid;
BEGIN
    -- Check project policy that project documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'project_documents', 'UPDATE')
        OR check_action_policy_project(auth.uid(), 'project_documents', 'UPDATE', _project_id))
    THEN
        RETURN FALSE;
    END IF;

    FOREACH _document_id IN ARRAY _document_ids
        LOOP

            UPDATE public.project_documents pd
               SET sort = _current_index
             WHERE pd.document_id = _document_id
               AND pd.project_id = _project_id;

            _current_index :=  _current_index + 1;

        END LOOP;

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.accept_join_request_rpc(_project_id uuid, _request_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _default_group_id uuid;
    _request public.join_requests % rowtype;
BEGIN
    -- Check project policy that contexts can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'projects', 'UPDATE') 
      OR check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _project_id)) 
    THEN
        RETURN FALSE;
    END IF;

    --  Get the request
    SELECT * INTO _request FROM public.join_requests jr WHERE jr.id = _request_id LIMIT 1;

    -- Get the group id
    SELECT g.id INTO _default_group_id FROM public.project_groups g WHERE g.project_id = _project_id AND g.is_default = TRUE;

    -- Add the user to the project
    INSERT INTO public.group_users
          (group_type, type_id, user_id) 
      VALUES('project', _default_group_id, _request.user_id);

    -- Delete the request
    DELETE FROM public.join_requests WHERE id = _request_id;

    -- Check for assign_all contexts
    PERFORM do_assign_all_check_for_user(_project_id, _request.user_id);

    RETURN TRUE;
END
$function$
;

CREATE OR REPLACE FUNCTION public.accept_project_invite()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.accepted IS TRUE THEN
        INSERT INTO public.group_users
            (group_type, user_id, type_id)
        VALUES ('project', auth.uid(), NEW.project_group_id);

        PERFORM do_assign_all_check_for_user(NEW.project_id, auth.uid());
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer_from_context(user_id uuid, table_name character varying, operation operation_types, context_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _exists BOOLEAN;
BEGIN
    _exists = EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_contexts lc ON lc.context_id = $4 AND lc.is_active_layer = TRUE
                           INNER JOIN public.context_users cu ON cu.context_id = lc.context_id AND cu.user_id = $1
                           INNER JOIN public.roles r ON cu.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
    -- RAISE LOG 'Policy for layer from context % is %', $4, _exists;

    RETURN _exists;                     
END;
$function$
;

CREATE OR REPLACE FUNCTION public.join_project_rpc(_project_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _is_open_join BOOLEAN;
  _context BOOLEAN;
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

    -- Check for assign_all contexts
    PERFORM do_assign_all_check_for_user(_project_id, auth.uid());

    RETURN TRUE;
END
$function$
;


