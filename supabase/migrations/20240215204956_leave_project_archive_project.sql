drop policy "Users with correct policies can SELECT on collections" on "public"."collections";

alter table "public"."collections" add column "is_archived" boolean default false;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.leave_project_rpc(_project_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _project_group_id uuid;
  _group_user_id uuid;
BEGIN


    -- They at least have to be authenticated
    IF NOT check_action_policy_organization(auth.uid(), 'documents', 'SELECT') THEN
        RETURN FALSE;
    END IF;    

    SELECT (id) INTO _project_group_id FROM public.project_groups WHERE project_id = _project_id AND is_default IS TRUE;

    SELECT gu.id INTO _group_user_id FROM public.group_users gu 
      INNER JOIN public.project_groups pg ON pg.project_id = _project_id 
      WHERE gu.type_id = pg.id AND gu.user_id = auth.uid();

    IF _group_user_id IS NOT NULL THEN
      DELETE FROM public.group_users WHERE id = _group_user_id;
    ELSE 
      RETURN FALSE;
    END IF;

    RETURN TRUE;
END
$function$
;

create policy "Users with correct policies can SELECT on collections"
on "public"."collections"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'collections'::character varying, 'SELECT'::operation_types)));



