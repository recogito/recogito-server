set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.is_open_edit_join_from_context_rpc(_context_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _project_id   uuid;
BEGIN


    -- They at least have to be authenticated
    IF NOT check_action_policy_organization(auth.uid(), 'documents', 'SELECT') THEN
        RETURN NULL;
    END IF;    

    SELECT p.id INTO _project_id FROM public.projects p 
      INNER JOIN public.contexts c ON c.id = _context_id
      WHERE p.is_open_join IS TRUE AND p.is_open_edit IS TRUE AND c.project_id = p.id;
    
    RAISE log 'Project ID: %', _project_id;
    RETURN _project_id;

END
$function$
;


