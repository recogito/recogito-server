CREATE OR REPLACE FUNCTION etl.load_rpc(_import_id uuid)
    RETURNS BOOLEAN AS $body$
BEGIN
    -- Only organization admins may import projects
    IF NOT (public.is_admin_organization(auth.uid()))
    THEN
        RETURN FALSE;
    END IF;

    -- profiles
    INSERT INTO public.profiles (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        first_name,
        last_name,
        email,
        nickname,
        avatar_url,
        gdpr_optin,
        is_archived,
        accepted_eula,
        role
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        first_name,
        last_name,
        email,
        nickname,
        avatar_url,
        gdpr_optin,
        is_archived,
        accepted_eula,
        role::varchar::public.profile_role_types
      FROM z_profiles
     WHERE z_profiles.import_id = _import_id
       AND z_profiles.is_new IS TRUE
    ;

    -- documents
    INSERT INTO public.documents (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        bucket_id,
        content_type,
        meta_data,
        is_private,
        collection_id,
        collection_metadata,
        is_document_group,
        document_group_id
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        bucket_id,
        content_type::varchar::public.content_types_type,
        meta_data,
        is_private,
        collection_id,
        collection_metadata,
        is_document_group,
        document_group_id
      FROM z_documents
     WHERE z_documents.import_id = _import_id
       AND z_documents.is_new IS TRUE
    ;

    -- projects
    INSERT INTO public.projects (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        description,
        is_open_join,
        is_open_edit,
        is_locked,
        document_view_right
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        description,
        is_open_join,
        is_open_edit,
        is_locked,
        document_view_right::varchar::public.document_view_type
      FROM z_projects
     WHERE z_projects.import_id = _import_id
    ;

    -- contexts
    INSERT INTO public.contexts (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        description,
        project_id,
        is_project_default,
        assign_all_members,
        sort
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        description,
        project_id,
        is_project_default,
        assign_all_members,
        sort
      FROM z_contexts
     WHERE z_contexts.import_id = _import_id
    ;

    -- context_documents
    INSERT INTO public.context_documents (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        context_id,
        document_id,
        is_archived,
        sort
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        context_id,
        document_id,
        is_archived,
        sort
      FROM z_context_documents
     WHERE z_context_documents.import_id = _import_id
    ;

    -- context_users
    INSERT INTO public.context_users (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        context_id,
        user_id,
        role_id
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        context_id,
        user_id,
        role_id
      FROM z_context_users
     WHERE z_context_users.import_id = _import_id
    ;

    -- layers
    INSERT INTO public.layers (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        document_id,
        project_id,
        name,
        description
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        document_id,
        project_id,
        name,
        description
      FROM z_layers
     WHERE z_layers.import_id = _import_id
    ;

    -- layer_contexts
    INSERT INTO public.layer_contexts (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        layer_id,
        context_id,
        is_active_layer
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        layer_id,
        context_id,
        is_active_layer
      FROM z_layer_contexts
     WHERE z_layer_contexts.import_id = _import_id
    ;

    -- layer_groups
    INSERT INTO public.layer_groups (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        layer_id,
        name,
        description,
        role_id,
        is_admin,
        is_default,
        is_read_only
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        layer_id,
        name,
        description,
        role_id,
        is_admin,
        is_default,
        is_read_only
      FROM z_layer_groups
     WHERE z_layer_groups.import_id = _import_id
    ;

    -- project_documents
    INSERT INTO public.project_documents (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        project_id,
        document_id,
        sort
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        project_id,
        document_id,
        sort
      FROM z_project_documents
     WHERE z_project_documents.import_id = _import_id
    ;

    -- project_groups
    INSERT INTO public.project_groups (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        project_id,
        name,
        description,
        role_id,
        is_admin,
        is_default,
        is_read_only
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        project_id,
        name,
        description,
        role_id,
        is_admin,
        is_default,
        is_read_only
      FROM z_project_groups
     WHERE z_project_groups.import_id = _import_id
    ;

    -- group_users
    INSERT INTO public.group_users (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        group_type,
        type_id,
        user_id
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        group_type::varchar::public.group_types,
        type_id,
        user_id
      FROM z_group_users
     WHERE z_group_users.import_id = _import_id
    ;

    -- annotations
    INSERT INTO public.annotations (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        version,
        layer_id,
        is_private
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        version,
        layer_id,
        is_private
      FROM z_annotations
     WHERE import_id = _import_id
    ;

    -- bodies
    INSERT INTO public.bodies (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        version,
        annotation_id,
        type,
        language,
        format,
        purpose,
        value,
        layer_id
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        version,
        annotation_id,
        type::varchar::public.body_types,
        language,
        format::varchar::public.body_formats,
        purpose,
        value,
        layer_id
       FROM z_bodies
      WHERE z_bodies.import_id = _import_id
    ;

    -- tag_definitions
    INSERT INTO public.tag_definitions (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        target_type,
        scope,
        scope_id,
        metadata
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        name,
        target_type::varchar::public.tag_target_types,
        scope::varchar::public.tag_scope_types,
        scope_id,
        metadata
      FROM z_tag_definitions
     WHERE z_tag_definitions.import_id = _import_id
    ;

    -- tags
    INSERT INTO public.tags (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        tag_definition_id,
        target_id
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        tag_definition_id,
        target_id
      FROM z_tags
     WHERE z_tags.import_id = _import_id
    ;

    -- targets
    INSERT INTO public.targets (
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        version,
        annotation_id,
        selector_type,
        conforms_to,
        value,
        layer_id
    )
    SELECT
        id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_archived,
        version,
        annotation_id,
        selector_type::varchar::public.target_selector_types,
        conforms_to::varchar::public.target_conforms_to_types,
        value,
        layer_id
      FROM z_targets
     WHERE z_targets.import_id = _import_id
    ;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;