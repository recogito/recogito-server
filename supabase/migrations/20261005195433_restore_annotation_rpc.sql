-- Only archive bodies and targets that are not archived yet. Previously, archiving an
-- annotation re-archived every body, which overwrote updated_by on bodies that had
-- been deleted individually before. Un-archiving relies on updated_by to tell who
-- archived a record.
CREATE OR REPLACE FUNCTION public.check_archive_annotation()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.bodies AS b SET is_archived = TRUE WHERE b.annotation_id = OLD.id AND b.is_archived IS NOT TRUE;
        UPDATE public.targets AS t SET is_archived = TRUE WHERE t.annotation_id = OLD.id AND t.is_archived IS NOT TRUE;
    END IF;
    RETURN NEW;
END;
$$
;

-- Restores (un-archives) an annotation and/or some of its bodies, e.g. when the user
-- undoes a delete.
-- 
-- Called by @recogito/annotorious-supabase when re-inserting an ID fails because the
-- record still exists in archived state.
--
-- - If the annotation is archived, it gets restored along with its target(s).
-- - Bodies are only restored if listed in _body_ids, since the archive cascade can't
--   be told apart from bodies that were deleted individually before.
-- - Records can only be restored by the user who archived them, in a layer that is
--   not archived, and with the same permissions archive_record_rpc requires.
--
-- Returns TRUE if anything was restored, FALSE if there was nothing to restore. Raises
-- P0002 (not found) or 42501 (not allowed) so the client gets an HTTP error.

CREATE OR REPLACE FUNCTION restore_annotation_rpc(_annotation_id uuid, _body_ids uuid[] DEFAULT '{}')
    RETURNS bool
AS
$body$
DECLARE
    _layer_id    uuid;
    _is_archived bool;
    _archived_by uuid;
    _body        record;
    _restored    bool := FALSE;
BEGIN
    SELECT a.layer_id, a.is_archived, a.updated_by
    INTO _layer_id, _is_archived, _archived_by
    FROM public.annotations a
    WHERE a.id = _annotation_id
    FOR UPDATE;

    IF NOT FOUND OR EXISTS(SELECT 1 FROM public.layers l WHERE l.id = _layer_id AND l.is_archived IS TRUE) THEN
        RAISE EXCEPTION 'Annotation % not found', _annotation_id USING ERRCODE = 'P0002';
    END IF;

    -- Check policies/auth
    IF _is_archived IS TRUE AND NOT COALESCE(
            _archived_by = auth.uid() AND
            public.check_for_private_annotation(auth.uid(), _annotation_id) AND (
                public.check_action_policy_organization(auth.uid(), 'annotations', 'UPDATE') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'UPDATE', _layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'annotations', 'UPDATE', _layer_id)
            ), FALSE) THEN
        RAISE EXCEPTION 'Not allowed to restore annotation %', _annotation_id USING ERRCODE = '42501';
    END IF;

    FOR _body IN
        SELECT b.id, b.layer_id, b.updated_by
        FROM public.bodies b
        WHERE b.annotation_id = _annotation_id
          AND b.id = ANY (COALESCE(_body_ids, '{}'))
          AND b.is_archived IS TRUE
        FOR UPDATE
    LOOP
        IF NOT COALESCE(
                _body.updated_by = auth.uid() AND
                public.check_for_private_annotation(auth.uid(), _annotation_id) AND (
                    public.check_action_policy_layer(auth.uid(), 'bodies', 'UPDATE', _body.layer_id) OR
                    public.check_action_policy_organization(auth.uid(), 'bodies', 'UPDATE') OR
                    public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'UPDATE', _body.layer_id)
                ), FALSE) THEN
            RAISE EXCEPTION 'Not allowed to restore body %', _body.id USING ERRCODE = '42501';
        END IF;
    END LOOP;

    -- Unarchive in the order: annotation first, then target, then bodies
    IF _is_archived IS TRUE THEN
        UPDATE public.annotations SET is_archived = FALSE WHERE id = _annotation_id;
        UPDATE public.targets SET is_archived = FALSE WHERE annotation_id = _annotation_id AND is_archived IS TRUE;
        _restored := TRUE;
    END IF;

    UPDATE public.bodies
    SET is_archived = FALSE
    WHERE annotation_id = _annotation_id
      AND id = ANY (COALESCE(_body_ids, '{}'))
      AND is_archived IS TRUE;

    IF FOUND THEN
        _restored := TRUE;
    END IF;

    RETURN _restored;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;
