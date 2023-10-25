CREATE OR REPLACE FUNCTION archive_record_rpc(_table_name text, _id uuid)
    RETURNS bool
AS
$body$
DECLARE
    _row_id        uuid;
    _layer_id      uuid;
    _project_id    uuid;
    _annotation_id uuid;
BEGIN
    IF _table_name = 'annotations' THEN
        SELECT id, layer_id INTO _row_id, _layer_id FROM public.annotations WHERE id = _id;
        IF (public.check_for_private_annotation(auth.uid(), _row_id) AND (
                public.check_action_policy_organization(auth.uid(), 'annotations', 'UPDATE') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'UPDATE', _layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'annotations', 'UPDATE', _layer_id)
            )) THEN
            UPDATE public.annotations SET is_archived = TRUE WHERE id = _id;
            RETURN TRUE;
        END IF;
    ELSE
        IF _table_name = 'projects' THEN
            SELECT id INTO _row_id FROM public.projects WHERE id = _id;
            IF (public.check_action_policy_organization(auth.uid(), 'projects', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _row_id)
                ) THEN
                UPDATE public.projects SET is_archived = TRUE WHERE id = _id;
                RETURN TRUE;
            END IF;
        ELSE
            IF _table_name = 'contexts' THEN
                SELECT id, project_id INTO _row_id, _project_id FROM public.contexts WHERE id = _id;
                IF (public.check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') OR
                    public.check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _project_id)) THEN
                    UPDATE public.contexts SET is_archived = TRUE WHERE id = _id;
                    RETURN TRUE;
                END IF;
            ELSE
                IF _table_name = 'layers' THEN
                    SELECT id, project_id INTO _row_id, _project_id FROM public.layers WHERE id = _id;
                    IF (public.check_action_policy_organization(auth.uid(), 'layers', 'UPDATE') OR
                        public.check_action_policy_project(auth.uid(), 'layers', 'UPDATE', _project_id) OR
                        public.check_action_policy_layer(auth.uid(), 'layers', 'UPDATE', _row_id)) THEN
                        UPDATE public.layers SET is_archived = TRUE WHERE id = _id;
                        RETURN TRUE;
                    END IF;
                ELSE
                    IF _table_name = 'bodies' THEN
                        SELECT id, layer_id, annotation_id
                        INTO _row_id, _layer_id, _annotation_id
                        FROM public.bodies
                        WHERE id = _id;
                        IF (
                                public.check_for_private_annotation(auth.uid(), _annotation_id) AND
                                (public.check_action_policy_layer(auth.uid(), 'bodies', 'UPDATE',
                                                                  _layer_id) OR
                                 public.check_action_policy_organization(auth.uid(), 'bodies', 'UPDATE') OR
                                 public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'UPDATE',
                                                                               _layer_id))
                            ) THEN
                            UPDATE public.bodies SET is_archived = TRUE WHERE id = _id;
                            RETURN TRUE;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    RETURN FALSE;
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;

DROP FUNCTION public.archive_record_rpc(_table_name text, _id uuid);
