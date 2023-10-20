set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_for_private_annotation(user_id uuid, annotation_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RAISE LOG 'Hitting check_for_private_annotation';
    RETURN EXISTS(SELECT 1
                  FROM public.annotations a
                  WHERE a.id = $2
                    AND (a.is_private IS NOT TRUE OR a.created_by = $1));
END;
$function$
;


