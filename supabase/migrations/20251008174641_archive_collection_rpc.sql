set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.archive_collection_rpc(_collection_id uuid)
 RETURNS boolean 
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _row public.collections % rowtype;
BEGIN
    -- Check policy that collections can be updated by this user
    IF NOT (check_action_policy_organization(auth.uid(), 'collections', 'UPDATE')) 
    THEN
        RETURN FALSE;
    END IF; 

    -- Get the collection
    SELECT * INTO _row FROM public.collections c WHERE c.id = _collection_id;

    -- If the user is the creator or an Org Admin, attempt to archive the collection and its documents
    IF _row.created_by = auth.uid() OR is_admin_organization(auth.uid())
    THEN
        -- Prevent archiving if any of the documents are used in any project
        IF EXISTS (
            SELECT 1 FROM public.documents d
            JOIN public.project_documents pd ON pd.document_id = d.id
            WHERE d.collection_id = _collection_id AND pd.is_archived = FALSE
        ) THEN
            RETURN FALSE;
        END IF;

        -- Archive the collection
        UPDATE public.collections
        SET is_archived = TRUE
        WHERE id = _collection_id;

        -- Archive its documents
        UPDATE public.documents
        SET is_archived = TRUE
        WHERE collection_id = _collection_id;


        RETURN TRUE;
    END IF;

    RETURN FALSE;
END
$function$
;
