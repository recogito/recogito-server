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

CREATE
    OR REPLACE FUNCTION public.check_archive_project()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.contexts AS c SET is_archived = TRUE WHERE c.project_id = OLD.id;
        UPDATE public.invites AS i SET is_archived = TRUE WHERE i.project_id = OLD.id;
        UPDATE public.layers AS l SET is_archived = TRUE WHERE l.project_id = OLD.id;
        UPDATE public.project_groups AS p SET is_archived = TRUE WHERE p.project_id = OLD.id;
        SELECT public.archive_tags_for_target('project', OLD.id);
    END IF;
    RETURN NEW;
END;
$$
;
