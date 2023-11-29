set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_project_from_tag_definition(user_id uuid, table_name character varying, operation operation_types, tag_definition_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _scope      VARCHAR;
    _scope_id   UUID;
BEGIN
    SELECT scope, scope_id INTO _scope, _scope_id FROM public.tag_definitions WHERE id = $4;

    RETURN _scope = 'project' AND EXISTS(SELECT 1
                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.project_id = _scope_id
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END ;
$function$
;


