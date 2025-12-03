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
       SET is_new = FALSE
      FROM public.profiles
     WHERE public.profiles.id = z_profiles.legacy_id
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_annotations.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_annotations.import_id = _import_id
    ;

    UPDATE z_annotations
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_annotations.updated_by
       AND z_profiles.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_bodies.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_bodies.import_id = _import_id
    ;

    UPDATE z_bodies
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_bodies.updated_by
       AND z_profiles.is_new = TRUE
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
       AND z_documents.is_new = TRUE
       AND z_documents.import_id = _import_id
       AND z_context_documents.import_id = _import_id
    ;

    UPDATE z_context_documents
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_documents.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_context_documents.import_id = _import_id
    ;

    UPDATE z_context_documents
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_documents.updated_by
       AND z_profiles.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_users.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_context_users.import_id = _import_id
    ;

    UPDATE z_context_users
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_context_users.updated_by
       AND z_profiles.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_documents.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_documents.import_id = _import_id
    ;

    UPDATE z_documents
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_documents.updated_by
       AND z_profiles.is_new = TRUE
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
       SET user_id = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_group_users.user_id
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_group_users.import_id = _import_id
    ;

    UPDATE z_group_users
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_group_users.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_group_users.import_id = _import_id
    ;

    UPDATE z_group_users
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_group_users.updated_by
       AND z_profiles.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_contexts.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_layer_contexts.import_id = _import_id
    ;

    UPDATE z_layer_contexts
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_contexts.updated_by
       AND z_profiles.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_groups.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_layer_groups.import_id = _import_id
    ;

    UPDATE z_layer_groups
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layer_groups.updated_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_layer_groups.import_id = _import_id
    ;

    -- z_layers
    UPDATE z_layers
       SET document_id = z_documents.id
      FROM z_documents
     WHERE z_documents.legacy_id = z_layers.document_id
       AND z_documents.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layers.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_layers.import_id = _import_id
    ;

    UPDATE z_layers
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_layers.updated_by
       AND z_profiles.is_new = TRUE
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
       AND z_documents.is_new = TRUE
       AND z_documents.import_id = _import_id
       AND z_project_documents.import_id = _import_id
    ;

    UPDATE z_project_documents
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_documents.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_project_documents.import_id = _import_id
    ;

    UPDATE z_project_documents
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_documents.updated_by
       AND z_profiles.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_groups.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_project_groups.import_id = _import_id
    ;

    UPDATE z_project_groups
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_project_groups.updated_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_project_groups.import_id = _import_id
    ;

    -- z_projects
    UPDATE z_projects
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_projects.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_projects.import_id = _import_id
    ;

    UPDATE z_projects
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_projects.updated_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_projects.import_id = _import_id
    ;

    -- z_tag_definitions
    UPDATE z_tag_definitions
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tag_definitions.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_tag_definitions.import_id = _import_id
    ;

    UPDATE z_tag_definitions
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tag_definitions.updated_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_tag_definitions.import_id = _import_id
    ;

    UPDATE z_tag_definitions
       SET scope_id = z_profiles.id
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tags.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_tags.import_id = _import_id
    ;

    UPDATE z_tags
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_tags.updated_by
       AND z_profiles.is_new = TRUE
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
       SET created_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_targets.created_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_targets.import_id = _import_id
    ;

    UPDATE z_targets
       SET updated_by = z_profiles.id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_targets.updated_by
       AND z_profiles.is_new = TRUE
       AND z_profiles.import_id = _import_id
       AND z_targets.import_id = _import_id
    ;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;