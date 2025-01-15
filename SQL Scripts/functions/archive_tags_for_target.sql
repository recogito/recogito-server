CREATE OR REPLACE FUNCTION archive_tags_for_target(_target_type tag_target_types, _target_id uuid)
    RETURNS bool
AS
$body$
BEGIN
    UPDATE public.tags t
       SET is_archived = TRUE
      FROM public.tag_definitions td
     WHERE td.id = t.tag_definition_id
       AND td.target_type = _target_type
       AND t.target_id = _target_id;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;