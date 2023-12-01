set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_for_first_body(annotation_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN NOT EXISTS(SELECT 1
                  FROM public.bodies a
                  WHERE a.annotation_id = $1);
END;
$function$
;


