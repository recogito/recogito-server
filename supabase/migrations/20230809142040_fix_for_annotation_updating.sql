set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.archive_record_rpc(_table_name text, _id uuid)
 RETURNS record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _row RECORD;
BEGIN
    IF _table_name = 'annotations' THEN
        SELECT * INTO _row FROM public.annotations WHERE id = _id;
        IF (public.check_for_private_annotation(auth.uid(), _row.id) AND (
                public.check_action_policy_organization(auth.uid(), 'annotations', 'UPDATE') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'UPDATE', _row.layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'annotations', 'UPDATE', _row.layer_id)
            )) THEN
            UPDATE public.annotations SET is_archived = TRUE WHERE id = _id;
            RETURN _row;
        END IF;
    ELSE
        IF _table_name = 'projects' THEN
            SELECT * INTO _row FROM public.projects WHERE id = _id;
            IF (public.check_action_policy_organization(auth.uid(), 'projects', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _row.id)
                ) THEN
                UPDATE public.projects SET is_archived = TRUE WHERE id = _id;
                RETURN _row;
            END IF;
        ELSE
            IF _table_name = 'contexts' THEN
                SELECT * INTO _row FROM public.contexts WHERE id = _id;
                IF (public.check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') OR
                    public.check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _row.project_id)) THEN
                    UPDATE public.contexts SET is_archived = TRUE WHERE id = _id;
                    RETURN _row;
                END IF;
            ELSE
                IF _table_name = 'layers' THEN
                    SELECT * INTO _row FROM public.layers WHERE id = _id;
                    IF (public.check_action_policy_organization(auth.uid(), 'layers', 'UPDATE') OR
                        public.check_action_policy_project(auth.uid(), 'layers', 'UPDATE', _row.project_id) OR
                        public.check_action_policy_layer(auth.uid(), 'layers', 'UPDATE', _row.id)) THEN
                        UPDATE public.layers SET is_archived = TRUE WHERE id = _id;
                        RETURN _row;
                    END IF;
                ELSE
                    IF _table_name = 'bodies' THEN
                        SELECT * INTO _row FROM public.bodies WHERE id = _id;
                        IF (
                                public.check_for_private_annotation(auth.uid(), _row.annotation_id) AND
                                _row.created_by = auth.uid() AND
                                (public.check_action_policy_layer(auth.uid(), 'bodies', 'UPDATE',
                                                                  _row.layer_id) OR
                                 public.check_action_policy_organization(auth.uid(), 'bodies', 'UPDATE') OR
                                 public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'UPDATE',
                                                                               _row.layer_id))
                            ) THEN
                            UPDATE public.bodies SET is_archived = TRUE WHERE id = _id;
                            RETURN _row;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END ;
$function$
;


