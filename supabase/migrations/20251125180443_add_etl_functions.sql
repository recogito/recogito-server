CREATE OR REPLACE FUNCTION etl.transform_rpc(_import_id uuid)
    RETURNS BOOLEAN AS $body$
BEGIN
    -- Only organization admins may import projects
    IF NOT (public.is_admin_organization(auth.uid()))
    THEN
        RETURN FALSE;
    END IF;

    -- Update the ID for imported documents records to preserve users that already exist
    UPDATE z_documents
       SET is_new = FALSE
      FROM public.documents
     WHERE public.documents.id = z_documents.legacy_id
       AND z_documents.import_id = _import_id
    ;

    -- Update the ID for imported profiles records to preserve users that already exist
    UPDATE z_profiles
       SET is_new = FALSE,
           new_id = public.profiles.id
      FROM public.profiles
     WHERE public.profiles.email = z_profiles.email
       AND z_profiles.import_id = _import_id
    ;

    UPDATE z_profiles
       SET new_id = z_profiles.id
     WHERE z_profiles.is_new IS TRUE
       AND z_profiles.import_id = _import_id
    ;

    -- z_annotations
    UPDATE z_annotations
       SET layer_id = z_layers.id
      FROM z_layers
     WHERE z_layers.legacy_id = z_annotations.layer_id
       AND z_layers.import_id = _import_id
       AND z_annotations.import_id = _import_id
    ;

    UPDATE z_annotations
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_annotations.created_by
       AND z_profiles.import_id = _import_id
       AND z_annotations.import_id = _import_id
    ;

    UPDATE z_annotations
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_annotations.updated_by
       AND z_profiles.import_id = _import_id
       AND z_annotations.import_id = _import_id
    ;

    -- z_bodies
    UPDATE z_bodies
       SET annotation_id = z_annotations.id
      FROM z_annotations
     WHERE z_annotations.legacy_id = z_bodies.annotation_id
       AND z_annotations.import_id = _import_id
       AND z_bodies.import_id = _import_id
    ;

    UPDATE z_bodies
       SET layer_id = z_layers.id
      FROM z_layers
     WHERE z_layers.legacy_id = z_bodies.layer_id
       AND z_layers.import_id = _import_id
       AND z_bodies.import_id = _import_id
    ;

    UPDATE z_bodies
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_bodies.created_by
       AND z_profiles.import_id = _import_id
       AND z_bodies.import_id = _import_id
    ;

    UPDATE z_bodies
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_bodies.updated_by
       AND z_profiles.import_id = _import_id
       AND z_bodies.import_id = _import_id
    ;

    -- z_context_documents
    UPDATE z_context_documents
       SET context_id = z_contexts.id
      FROM z_contexts
     WHERE z_contexts.legacy_id = z_context_documents.context_id
       AND z_contexts.import_id = _import_id
       AND z_context_documents.import_id = _import_id
    ;

    UPDATE z_context_documents
       SET document_id = z_documents.id
      FROM z_documents
     WHERE z_documents.legacy_id = z_context_documents.document_id
       AND z_documents.is_new IS TRUE
       AND z_documents.import_id = _import_id
       AND z_context_documents.import_id = _import_id
    ;

    UPDATE z_context_documents
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_documents.created_by
       AND z_profiles.import_id = _import_id
       AND z_context_documents.import_id = _import_id
    ;

    UPDATE z_context_documents
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_documents.updated_by
       AND z_profiles.import_id = _import_id
       AND z_context_documents.import_id = _import_id
    ;

    -- z_context_users
    UPDATE z_context_users
       SET context_id = z_contexts.id
      FROM z_contexts
     WHERE z_contexts.legacy_id = z_context_users.context_id
       AND z_contexts.import_id = _import_id
       AND z_context_users.import_id = _import_id
    ;

    UPDATE z_context_users
       SET user_id = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_users.user_id
       AND z_profiles.import_id = _import_id
       AND z_context_users.import_id = _import_id
    ;

    UPDATE z_context_users
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_users.created_by
       AND z_profiles.import_id = _import_id
       AND z_context_users.import_id = _import_id
    ;

    UPDATE z_context_users
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_users.updated_by
       AND z_profiles.import_id = _import_id
       AND z_context_users.import_id = _import_id
    ;

    -- z_contexts
    UPDATE z_contexts
       SET project_id = z_projects.id
      FROM z_projects
     WHERE z_projects.legacy_id = z_contexts.project_id
       AND z_projects.import_id = _import_id
       AND z_contexts.import_id = _import_id
    ;

    -- z_documents
    UPDATE z_documents
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_documents.created_by
       AND z_profiles.import_id = _import_id
       AND z_documents.import_id = _import_id
    ;

    UPDATE z_documents
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_documents.updated_by
       AND z_profiles.import_id = _import_id
       AND z_documents.import_id = _import_id
    ;

    -- z_group_users
    UPDATE z_group_users
       SET type_id = z_project_groups.id
      FROM z_project_groups
     WHERE z_project_groups.legacy_id = z_group_users.type_id
       AND z_project_groups.import_id = _import_id
       AND z_group_users.group_type = 'project'
       AND z_group_users.import_id = _import_id
    ;

    UPDATE z_group_users
       SET user_id = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_group_users.user_id
       AND z_profiles.import_id = _import_id
       AND z_group_users.import_id = _import_id
    ;

    UPDATE z_group_users
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_group_users.created_by
       AND z_profiles.import_id = _import_id
       AND z_group_users.import_id = _import_id
    ;

    UPDATE z_group_users
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_group_users.updated_by
       AND z_profiles.import_id = _import_id
       AND z_group_users.import_id = _import_id
    ;

    -- z_layer_contexts
    UPDATE z_layer_contexts
       SET layer_id = z_layers.id
      FROM z_layers
     WHERE z_layers.legacy_id = z_layer_contexts.layer_id
       AND z_layers.import_id = _import_id
       AND z_layer_contexts.import_id = _import_id
    ;

    UPDATE z_layer_contexts
       SET context_id = z_contexts.id
      FROM z_contexts
     WHERE z_contexts.legacy_id = z_layer_contexts.context_id
       AND z_contexts.import_id = _import_id
       AND z_layer_contexts.import_id = _import_id
    ;

    UPDATE z_layer_contexts
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_contexts.created_by
       AND z_profiles.import_id = _import_id
       AND z_layer_contexts.import_id = _import_id
    ;

    UPDATE z_layer_contexts
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_contexts.updated_by
       AND z_profiles.import_id = _import_id
       AND z_layer_contexts.import_id = _import_id
    ;

    -- z_layer_groups
    UPDATE z_layer_groups
       SET layer_id = z_layers.id
      FROM z_layers
     WHERE z_layers.legacy_id = z_layer_groups.layer_id
       AND z_layers.import_id = _import_id
       AND z_layer_groups.import_id = _import_id
    ;

    UPDATE z_layer_groups
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_groups.created_by
       AND z_profiles.import_id = _import_id
       AND z_layer_groups.import_id = _import_id
    ;

    UPDATE z_layer_groups
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_groups.updated_by
       AND z_profiles.import_id = _import_id
       AND z_layer_groups.import_id = _import_id
    ;

    -- z_layers
    UPDATE z_layers
       SET document_id = z_documents.id
      FROM z_documents
     WHERE z_documents.legacy_id = z_layers.document_id
       AND z_documents.is_new IS TRUE
       AND z_documents.import_id = _import_id
       AND z_layers.import_id = _import_id
    ;

    UPDATE z_layers
       SET project_id = z_projects.id
      FROM z_projects
     WHERE z_projects.legacy_id = z_layers.project_id
       AND z_projects.import_id = _import_id
       AND z_layers.import_id = _import_id
    ;

    UPDATE z_layers
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layers.created_by
       AND z_profiles.import_id = _import_id
       AND z_layers.import_id = _import_id
    ;

    UPDATE z_layers
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layers.updated_by
       AND z_profiles.import_id = _import_id
       AND z_layers.import_id = _import_id
    ;

    -- z_project_documents

    UPDATE z_project_documents
       SET project_id = z_projects.id
      FROM z_projects
     WHERE z_projects.legacy_id = z_project_documents.project_id
       AND z_projects.import_id = _import_id
       AND z_project_documents.import_id = _import_id
    ;

    UPDATE z_project_documents
       SET document_id = z_documents.id
      FROM z_documents
     WHERE z_documents.legacy_id = z_project_documents.document_id
       AND z_documents.is_new IS TRUE
       AND z_documents.import_id = _import_id
       AND z_project_documents.import_id = _import_id
    ;

    UPDATE z_project_documents
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_documents.created_by
       AND z_profiles.import_id = _import_id
       AND z_project_documents.import_id = _import_id
    ;

    UPDATE z_project_documents
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_documents.updated_by
       AND z_profiles.import_id = _import_id
       AND z_project_documents.import_id = _import_id
    ;

    -- z_project_groups
    UPDATE z_project_groups
       SET project_id = z_projects.id
      FROM z_projects
     WHERE z_projects.legacy_id = z_project_groups.project_id
       AND z_projects.import_id = _import_id
       AND z_project_groups.import_id = _import_id
    ;

    UPDATE z_project_groups
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_groups.created_by
       AND z_profiles.import_id = _import_id
       AND z_project_groups.import_id = _import_id
    ;

    UPDATE z_project_groups
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_groups.updated_by
       AND z_profiles.import_id = _import_id
       AND z_project_groups.import_id = _import_id
    ;

    -- z_projects
    UPDATE z_projects
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_projects.created_by
       AND z_profiles.import_id = _import_id
       AND z_projects.import_id = _import_id
    ;

    UPDATE z_projects
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_projects.updated_by
       AND z_profiles.import_id = _import_id
       AND z_projects.import_id = _import_id
    ;

    -- z_tag_definitions
    UPDATE z_tag_definitions
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tag_definitions.created_by
       AND z_profiles.import_id = _import_id
       AND z_tag_definitions.import_id = _import_id
    ;

    UPDATE z_tag_definitions
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tag_definitions.updated_by
       AND z_profiles.import_id = _import_id
       AND z_tag_definitions.import_id = _import_id
    ;

    UPDATE z_tag_definitions
       SET scope_id = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tag_definitions.scope_id
       AND z_profiles.import_id = _import_id
       AND z_tag_definitions.scope = 'user'
       AND z_tag_definitions.import_id = _import_id
    ;

    -- z_tags
    UPDATE z_tags
       SET tag_definition_id = z_tag_definitions.id
      FROM z_tag_definitions
     WHERE z_tag_definitions.legacy_id = z_tags.tag_definition_id
       AND z_tag_definitions.import_id = _import_id
       AND z_tags.import_id = _import_id
    ;

    UPDATE z_tags
       SET target_id = z_projects.id
      FROM z_projects
     WHERE z_projects.legacy_id = z_tags.target_id
       AND z_projects.import_id = _import_id
       AND z_tags.import_id = _import_id
    ;

    UPDATE z_tags
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tags.created_by
       AND z_profiles.import_id = _import_id
       AND z_tags.import_id = _import_id
    ;

    UPDATE z_tags
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tags.updated_by
       AND z_profiles.import_id = _import_id
       AND z_tags.import_id = _import_id
    ;

    -- z_targets
    UPDATE z_targets
       SET annotation_id = z_annotations.id
      FROM z_annotations
     WHERE z_annotations.legacy_id = z_targets.annotation_id
       AND z_annotations.import_id = _import_id
       AND z_targets.import_id = _import_id
    ;

    UPDATE z_targets
       SET layer_id = z_layers.id
      FROM z_layers
     WHERE z_layers.legacy_id = z_targets.layer_id
       AND z_layers.import_id = _import_id
       AND z_targets.import_id = _import_id
    ;

    UPDATE z_targets
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_targets.created_by
       AND z_profiles.import_id = _import_id
       AND z_targets.import_id = _import_id
    ;

    UPDATE z_targets
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_targets.updated_by
       AND z_profiles.import_id = _import_id
       AND z_targets.import_id = _import_id
    ;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;

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