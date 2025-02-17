alter table "public"."contexts" add column "sort" integer default 0;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_context_sort_rpc(_project_id uuid, _context_ids uuid[])
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    current_index INT = 0;
    _context_id uuid;
BEGIN
    -- Check project policy that contexts can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE')
        OR check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id))
    THEN
        RETURN FALSE;
    END IF;

    FOREACH _context_id IN ARRAY _context_ids
    LOOP

        UPDATE public.contexts c
           SET sort = current_index
         WHERE c.id = _context_id
           AND c.project_id = _project_id;

        current_index :=  current_index + 1;

    END LOOP;

    RETURN TRUE;
END
$function$
;


