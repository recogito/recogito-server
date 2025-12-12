CREATE OR REPLACE FUNCTION get_project_users_rpc(_project_id uuid)
    RETURNS TABLE (
        user_id uuid
    )
AS
$body$
BEGIN
    RETURN QUERY (
        SELECT gu.user_id AS user_id
          FROM public.group_users gu
          JOIN public.project_groups pg ON pg.id = gu.type_id AND gu.group_type = 'project'
         WHERE pg.project_id = _project_id
         UNION
        SELECT b.created_by AS user_id
          FROM public.bodies b
          JOIN public.layers l ON l.id = b.layer_id
         WHERE l.project_id = _project_id
         UNION
        SELECT b.updated_by AS user_id
          FROM public.bodies b
          JOIN public.layers l ON l.id = b.layer_id
         WHERE l.project_id = _project_id
         UNION
        SELECT t.created_by AS user_id
          FROM public.targets t
          JOIN public.layers l ON l.id = t.layer_id
         WHERE l.project_id = _project_id
         UNION
        SELECT t.updated_by AS user_id
          FROM public.targets t
          JOIN public.layers l ON l.id = t.layer_id
         WHERE l.project_id = _project_id
         UNION
        SELECT d.created_by AS user_id
          FROM public.documents d
          JOIN public.project_documents pd ON pd.document_id = d.id
         WHERE pd.project_id = _project_id
         UNION
        SELECT d.updated_by AS user_id
          FROM public.documents d
          JOIN public.project_documents pd ON pd.document_id = d.id
         WHERE pd.project_id = _project_id
    );
END ;
$body$ LANGUAGE plpgsql SECURITY DEFINER;