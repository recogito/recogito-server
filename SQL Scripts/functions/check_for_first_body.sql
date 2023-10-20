CREATE OR REPLACE FUNCTION check_for_first_body(annotation_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    RETURN NOT EXISTS(SELECT 1
                  FROM public.bodies a
                  WHERE a.annotation_id = $1);
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;
