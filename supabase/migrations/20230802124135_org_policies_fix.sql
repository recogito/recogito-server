set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_organization_policies()
 RETURNS TABLE(user_id uuid, table_name character varying, operation operation_types)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY SELECT gu.user_id, p.table_name, p.operation
                 FROM public.organization_groups ag
                          INNER JOIN public.group_users gu
                                     ON ag.id = gu.type_id AND gu.group_type = 'organization' AND
                                        gu.user_id = auth.uid()
                          INNER JOIN public.roles r ON ag.role_id = r.id
                          INNER JOIN public.role_policies rp ON r.id = rp.role_id
                          INNER JOIN public.policies p ON rp.policy_id = p.id
                 WHERE gu.user_id = auth.uid();
END ;
$function$
;


