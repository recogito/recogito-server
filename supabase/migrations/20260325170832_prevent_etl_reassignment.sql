-- add new etl.is_importing config to import rpc

CREATE OR REPLACE FUNCTION etl.load_rpc(_import_id uuid)
    RETURNS BOOLEAN AS $body$
BEGIN
    -- Only organization admins may import projects
    IF NOT (public.is_admin_organization(auth.uid()))
    THEN
        RETURN FALSE;
    END IF;

    -- set flag for triggers to prevent user reassignment on create/update
    PERFORM set_config('etl.is_importing', 'true', true);

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
        document_group_id,
        author
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
        document_group_id,
        author
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
     ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
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
    ON CONFLICT DO NOTHING
    ;

    RETURN TRUE;
END
$body$ LANGUAGE plpgsql SECURITY DEFINER;

-- use it to prevent unwanted reassignments during import

CREATE OR REPLACE FUNCTION accept_project_invite()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not create a group_user for the importing user on import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    IF NEW.accepted IS TRUE THEN
        INSERT INTO public.group_users
            (group_type, user_id, type_id)
        VALUES ('project', auth.uid(), NEW.project_group_id);

        PERFORM do_assign_all_check_for_user(NEW.project_id, auth.uid());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION create_dates_and_user()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not modify date or user during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    NEW.created_at = NOW();
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR        REPLACE FUNCTION CREATE_DEFAULT_LAYER_GROUPS () RETURNS TRIGGER AS $$
DECLARE
    _layer_group_id uuid;
    _role_id        uuid;
    _name           varchar;
    _description    varchar;
    _is_admin       bool;
    _is_default     bool;
    _is_read_only   bool;
BEGIN
    -- do not create extra layer groups during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    FOR _role_id, _name, _description, _is_admin, _is_default, _is_read_only 
        IN SELECT role_id, name, description, is_admin, is_default, is_read_only
        FROM public.default_groups
        WHERE group_type = 'layer'
        LOOP
            _layer_group_id = extensions.uuid_generate_v4();
            INSERT INTO public.layer_groups
                (id, layer_id, role_id, name, description, is_admin, is_default, is_read_only)
            VALUES (_layer_group_id, NEW.id, _role_id, _name, _description, _is_admin, _is_default, _is_read_only);

            IF _is_admin IS TRUE AND NEW.created_by IS NOT NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('layer', _layer_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER;

CREATE
OR        REPLACE FUNCTION CREATE_DEFAULT_PROJECT_GROUPS () RETURNS TRIGGER AS $$
DECLARE
    _project_group_id uuid;
    _role_id          uuid;
    _name             varchar;
    _description      varchar;
    _is_admin         bool;
    _is_default       bool;
    _is_read_only     bool;
BEGIN
    -- do not create extra project groups during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    FOR _role_id, _name, _description, _is_admin, _is_default, _is_read_only 
        IN SELECT role_id, name, description, is_admin, is_default, is_read_only
        FROM public.default_groups
        WHERE group_type = 'project'
        LOOP
            _project_group_id = extensions.uuid_generate_v4();
            INSERT INTO public.project_groups
                (id, project_id, role_id, name, description, is_admin, is_default, is_read_only)
            VALUES (_project_group_id, NEW.id, _role_id, _name, _description, _is_admin, _is_default, _is_read_only);

            IF _is_admin IS TRUE AND NEW.created_by IS NOT NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('project', _project_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION create_group_user_with_check()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not modify date or user during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;

    IF public.check_for_group_membership(NEW.user_id, NEW.group_type, NEW.type_id) IS TRUE THEN
        RETURN NULL;
    END IF;
    NEW.created_at = NOW();
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION update_annotation_target_body()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not modify date or user during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    NEW.updated_at = NOW();
    -- created_at and created_by cannot be changed --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    NEW.updated_by = auth.uid();
    -- increment version ---
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION update_dates_and_user()
    RETURNS TRIGGER AS
$$
BEGIN
    -- do not modify date or user during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    -- These should never change --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE
OR        REPLACE FUNCTION PUBLIC.UPDATE_DOCUMENT () RETURNS TRIGGER LANGUAGE PLPGSQL SECURITY DEFINER AS $$
BEGIN
    -- do not modify date, user, or privacy during ETL import
    IF current_setting('etl.is_importing', true) = 'true' THEN
        RETURN NEW;
    END IF;
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    -- These should never change --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    IF NEW.is_private = TRUE AND auth.uid() != OLD.created_by THEN
        NEW.is_private = FALSE;
    END IF;
    RETURN NEW;
END;
$$;
