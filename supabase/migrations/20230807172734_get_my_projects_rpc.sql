set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_my_projects()
 RETURNS TABLE(id uuid, created_at timestamp with time zone, created_by uuid, updated_at timestamp with time zone, updated_by uuid, is_archived boolean, name character varying, description character varying)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY SELECT p.id, p.created_at, p.created_by, p.updated_at, p.updated_by, p.is_archived, p.name,
                         p.description
                 FROM public.projects p
                          INNER JOIN public.project_groups pg ON pg.project_id = p.id
                          INNER JOIN public.group_users gu
                                     ON pg.id = gu.type_id AND gu.group_type = 'project'
                 WHERE gu.user_id = auth.uid()
                   AND p.is_archived = FALSE;
END ;
$function$
;


