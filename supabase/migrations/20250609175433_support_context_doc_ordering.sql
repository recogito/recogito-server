alter table "public"."context_documents" add column "sort" integer default 0;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_context_documents_sort_rpc(_context_id uuid, _document_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    current_index INT = 0;
    _document_id uuid;
    _project_id uuid;
BEGIN

    -- Get the project id
    SELECT INTO _project_id c.project_id FROM public.contexts c WHERE id = _context_id;
    IF _project_id = NULL
      THEN
        RETURN FALSE;
    END IF;

    -- Check project policy that project documents can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'context_documents', 'UPDATE')
        OR check_action_policy_project(auth.uid(), 'context_documents', 'UPDATE', _project_id))
    THEN
        RETURN FALSE;
    END IF;

    FOREACH _document_id IN ARRAY _document_ids
    LOOP

        UPDATE public.context_documents cd
           SET sort = current_index
         WHERE cd.document_id = _document_id
           AND cd.context_id = _context_id;

        current_index :=  current_index + 1;

    END LOOP;

    RETURN TRUE;
END
$function$
;


