-- Rename the etl schema to recogito_etl
ALTER SCHEMA etl RENAME TO recogito_etl;

-- Update function that referenced it by name
CREATE OR REPLACE FUNCTION recogito_etl.transform_rpc(_import_id uuid)
    RETURNS BOOLEAN AS $body$
BEGIN
    -- Only organization admins may import projects
    IF NOT (public.is_admin_organization(auth.uid()))
    THEN
        RETURN FALSE;
    END IF;

    -- Update the ID for imported documents records to preserve users that already exist
    -- Document pre-existence by document UUID
    UPDATE z_documents
       SET is_new = FALSE,
           new_id = public.documents.id
      FROM public.documents
     WHERE public.documents.id = z_documents.legacy_id
       AND z_documents.import_id = _import_id
    ;

    -- Document pre-existence by collection ID + IIIF URL combo, to prevent collision
    UPDATE z_documents
       SET is_new = FALSE,
           new_id = public.documents.id
      FROM public.documents
     WHERE public.documents.collection_id = z_documents.collection_id
       AND public.documents.meta_data->>'url' = z_documents.meta_data->>'url'
       AND z_documents.import_id = _import_id
       AND z_documents.is_new IS TRUE
    ;

    -- Set truly new documents to use new UUID, and remove them from any collection
    UPDATE z_documents
       SET new_id = z_documents.id,
           collection_id = NULL
     WHERE z_documents.is_new IS TRUE
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

    UPDATE z_profiles z
       SET created_by = z_creator.new_id
      FROM z_profiles z_creator
     WHERE z_creator.legacy_id = z.created_by
       AND z_creator.import_id = _import_id
       AND z.import_id = _import_id
    ;

    UPDATE z_profiles z
       SET updated_by = z_updater.new_id
      FROM z_profiles z_updater
     WHERE z_updater.legacy_id = z.updated_by
       AND z_updater.import_id = _import_id
       AND z.import_id = _import_id
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
       SET document_id = z_documents.new_id
      FROM z_documents
     WHERE z_documents.legacy_id = z_context_documents.document_id
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
    UPDATE z_contexts
       SET created_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_contexts.created_by
       AND z_profiles.import_id = _import_id
       AND z_contexts.import_id = _import_id
    ;

    UPDATE z_contexts
       SET updated_by = z_profiles.new_id
      FROM z_profiles
     WHERE z_profiles.legacy_id = z_contexts.updated_by
       AND z_profiles.import_id = _import_id
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
       SET document_id = z_documents.new_id
      FROM z_documents
     WHERE z_documents.legacy_id = z_layers.document_id
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
       SET document_id = z_documents.new_id
      FROM z_documents
     WHERE z_documents.legacy_id = z_project_documents.document_id
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

    -- add importing user as a group_user on the project_group for this project,
    -- as an admin

    -- first, delete to prevent duplicate group_users entry
    DELETE FROM recogito_etl.z_group_users
     WHERE user_id = auth.uid()
       AND group_type = 'project'
       AND import_id = _import_id
    ;

    -- then create a new one (with brand new uuids) for the Admin project group
    INSERT INTO recogito_etl.z_group_users (
        id,
        legacy_id,
        created_by,
        updated_by,
        group_type,
        type_id,
        user_id,
        import_id
    )
    SELECT 
        extensions.uuid_generate_v4(),
        extensions.uuid_generate_v4(),
        auth.uid(),
        auth.uid(),
        'project',
        zpg.id,
        auth.uid(),
        _import_id
      FROM recogito_etl.z_project_groups zpg
     WHERE zpg.import_id = _import_id
       AND zpg.is_admin = TRUE
    ;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;
