CREATE OR REPLACE FUNCTION check_for_creating_user(user_id uuid, annotation_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.annotations a
                  WHERE a.id = $2
                    AND a.created_by = $1);
END;
$body$
    LANGUAGE plpgsql SECURITY DEFINER;

