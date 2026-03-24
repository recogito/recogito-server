CREATE SCHEMA etl;

GRANT USAGE ON SCHEMA etl TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA etl TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA etl TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA etl TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA etl GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA etl GRANT ALL ON ROUTINES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA etl GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

CREATE TABLE etl.z_annotations (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    version int4,
    layer_id uuid,
    is_private bool DEFAULT FALSE,
    import_id uuid NOT NULL
);

CREATE INDEX z_annotations_import_id_idx ON etl.z_annotations USING btree (import_id);
CREATE INDEX z_annotations_legacy_id_idx ON etl.z_annotations USING btree (legacy_id);

CREATE TYPE etl.z_body_types AS ENUM ('TextualBody');

CREATE TYPE etl.z_body_formats AS ENUM ('TextPlain', 'TextHtml', 'Quill');

CREATE TABLE etl.z_bodies (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    version int4,
    annotation_id uuid,
    type etl.z_body_types,
    language varchar,
    format etl.z_body_formats,
    purpose varchar,
    value text,
    layer_id uuid NOT NULL,
    import_id uuid NOT NULL
);

CREATE INDEX z_bodies_import_id_idx ON etl.z_bodies USING btree (import_id);
CREATE INDEX z_bodies_legacy_id_idx ON etl.z_bodies USING btree (legacy_id);

CREATE TABLE etl.z_context_documents (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    context_id uuid,
    document_id uuid,
    is_archived bool DEFAULT FALSE,
    sort INT DEFAULT 0,
    import_id uuid NOT NULL
);

CREATE INDEX z_context_documents_import_id_idx ON etl.z_context_documents USING btree (import_id);
CREATE INDEX z_context_documents_legacy_id_idx ON etl.z_context_documents USING btree (legacy_id);

CREATE TABLE etl.z_context_users (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    context_id uuid,
    user_id uuid,
    role_id uuid,
    import_id uuid NOT NULL
);

CREATE INDEX z_context_users_import_id_idx ON etl.z_context_users USING btree (import_id);
CREATE INDEX z_context_users_legacy_id_idx ON etl.z_context_users USING btree (legacy_id);

CREATE TABLE etl.z_contexts (
    id uuid NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    NAME varchar,
    description varchar,
    project_id uuid,
    is_project_default bool DEFAULT FALSE,
    assign_all_members bool DEFAULT FALSE,
    sort integer DEFAULT 0,
    import_id uuid NOT NULL
);

CREATE INDEX z_contexts_import_id_idx ON etl.z_contexts USING btree (import_id);
CREATE INDEX z_contexts_legacy_id_idx ON etl.z_contexts USING btree (legacy_id);

CREATE TYPE etl.z_content_types_type AS ENUM (
    'text/markdown',
    'image/jpeg',
    'image/tiff',
    'image/png',
    'image/gif',
    'image/jp2',
    'application/pdf',
    'text/plain',
    'application/tei+xml',
    'application/xml',
    'text/xml'
);

CREATE TABLE etl.z_documents (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived  bool DEFAULT FALSE,
    name varchar NOT NULL,
    bucket_id text,
    content_type etl.z_content_types_type,
    meta_data json DEFAULT '{}'::json,
    is_private bool DEFAULT TRUE,
    collection_id uuid,
    collection_metadata json,
    is_document_group bool DEFAULT FALSE,
    document_group_id uuid,
    import_id uuid NOT NULL,
    is_new bool DEFAULT TRUE
);

CREATE INDEX z_documents_import_id_idx ON etl.z_documents USING btree (import_id);
CREATE INDEX z_documents_legacy_id_idx ON etl.z_documents USING btree (legacy_id);

CREATE TYPE etl.z_group_types AS ENUM (
    'organization',
    'project',
    'layer'
);

CREATE TABLE etl.z_group_users (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    group_type etl.z_group_types NOT NULL,
    type_id uuid NOT NULL,
    user_id uuid NOT NULL,
    import_id uuid NOT NULL
);

CREATE INDEX z_group_users_import_id_idx ON etl.z_group_users USING btree (import_id);
CREATE INDEX z_group_users_legacy_id_idx ON etl.z_group_users USING btree (legacy_id);

CREATE TABLE etl.z_layer_contexts (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    layer_id uuid NOT NULL,
    context_id uuid NOT NULL,
    is_active_layer bool DEFAULT FALSE,
    import_id uuid NOT NULL
);

CREATE INDEX z_layer_contexts_import_id_idx ON etl.z_layer_contexts USING btree (import_id);
CREATE INDEX z_layer_contexts_legacy_id_idx ON etl.z_layer_contexts USING btree (legacy_id);

CREATE TABLE etl.z_layer_groups (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    layer_id uuid,
    name varchar NOT NULL,
    description varchar,
    role_id uuid NOT NULL,
    is_admin bool DEFAULT FALSE,
    is_default bool DEFAULT FALSE,
    is_read_only bool DEFAULT FALSE,
    import_id uuid NOT NULL
);

CREATE INDEX z_layer_groups_import_id_idx ON etl.z_layer_groups USING btree (import_id);
CREATE INDEX z_layer_groups_legacy_id_idx ON etl.z_layer_groups USING btree (legacy_id);

CREATE TABLE etl.z_layers (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    document_id uuid,
    project_id uuid NOT NULL,
    name varchar,
    description varchar,
    import_id uuid NOT NULL
);

CREATE INDEX z_layers_import_id_idx ON etl.z_layers USING btree (import_id);
CREATE INDEX z_layers_legacy_id_idx ON etl.z_layers USING btree (legacy_id);

CREATE TYPE etl.z_profile_role_types AS ENUM (
    'admin',
    'teacher',
    'base_user'
);

CREATE TABLE etl.z_profiles (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    first_name varchar,
    last_name varchar,
    email varchar,
    nickname varchar,
    avatar_url varchar,
    gdpr_optin bool DEFAULT FALSE,
    is_archived bool DEFAULT FALSE,
    accepted_eula bool DEFAULT FALSE,
    role etl.z_profile_role_types DEFAULT 'base_user',
    import_id uuid NOT NULL,
    is_new bool DEFAULT TRUE,
    new_id uuid
);

CREATE INDEX z_profiles_import_id_idx ON etl.z_profiles USING btree (import_id);
CREATE INDEX z_profiles_legacy_id_idx ON etl.z_profiles USING btree (legacy_id);

CREATE TABLE etl.z_project_documents (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    project_id uuid,
    document_id uuid,
    sort integer DEFAULT 0,
    import_id uuid NOT NULL
);

CREATE INDEX z_project_documents_import_id_idx ON etl.z_project_documents USING btree (import_id);
CREATE INDEX z_project_documents_legacy_id_idx ON etl.z_project_documents USING btree (legacy_id);

CREATE TABLE etl.z_project_groups (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    project_id uuid NOT NULL,
    name varchar NOT NULL,
    description varchar,
    role_id uuid NOT NULL,
    is_admin bool DEFAULT FALSE,
    is_default bool DEFAULT FALSE,
    is_read_only bool DEFAULT FALSE,
    import_id uuid NOT NULL
);

CREATE INDEX z_project_groups_import_id_idx ON etl.z_project_groups USING btree (import_id);
CREATE INDEX z_project_groups_legacy_id_idx ON etl.z_project_groups USING btree (legacy_id);

CREATE TYPE etl.z_document_view_type AS ENUM (
    'closed',
    'annotations',
    'notes'
);

CREATE TABLE etl.z_projects (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    NAME varchar,
    description varchar,
    is_open_join bool DEFAULT FALSE,
    is_open_edit bool DEFAULT FALSE,
    is_locked bool DEFAULT FALSE,
    document_view_right etl.z_document_view_type DEFAULT 'closed',
    import_id uuid NOT NULL
);

CREATE INDEX z_projects_import_id_idx ON etl.z_projects USING btree (import_id);
CREATE INDEX z_projects_legacy_id_idx ON etl.z_projects USING btree (legacy_id);

CREATE TYPE etl.z_tag_scope_types AS ENUM (
    'system',
    'organization',
    'project',
    'user'
);

CREATE TYPE etl.z_tag_target_types AS ENUM (
    'project',
    'group',
    'document',
    'context',
    'layer',
    'profile'
);

CREATE TABLE etl.z_tag_definitions (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    name varchar NOT NULL,
    target_type etl.z_tag_target_types NOT NULL,
    scope etl.z_tag_scope_types NOT NULL,
    scope_id uuid,
    metadata json NOT NULL DEFAULT '{}'::json,
    import_id uuid NOT NULL
);

CREATE INDEX z_tag_definitions_import_id_idx ON etl.z_tag_definitions USING btree (import_id);
CREATE INDEX z_tag_definitions_legacy_id_idx ON etl.z_tag_definitions USING btree (legacy_id);

CREATE TABLE etl.z_tags (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    tag_definition_id uuid,
    target_id uuid NOT NULL,
    import_id uuid NOT NULL
);

CREATE INDEX z_tags_import_id_idx ON etl.z_tags USING btree (import_id);
CREATE INDEX z_tags_legacy_id_idx ON etl.z_tags USING btree (legacy_id);

CREATE TYPE etl.z_target_selector_types AS ENUM (
    'Fragment',
    'SvgSelector'
);

CREATE TYPE etl.z_target_conforms_to_types AS ENUM (
    'Svg'
);

CREATE TABLE etl.z_targets (
    id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    legacy_id uuid NOT NULL,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid,
    updated_at timestamptz,
    updated_by uuid,
    is_archived bool DEFAULT FALSE,
    version int4,
    annotation_id uuid,
    selector_type etl.z_target_selector_types,
    conforms_to etl.z_target_conforms_to_types,
    value text,
    layer_id uuid NOT NULL,
    import_id uuid NOT NULL
);

CREATE INDEX z_targets_import_id_idx ON etl.z_targets USING btree (import_id);
CREATE INDEX z_targets_legacy_id_idx ON etl.z_targets USING btree (legacy_id);

-- changes 03/23/2026 --
alter table "etl"."z_documents" add column "author" text;

-- changes 03/24/2026 --
alter table "etl"."z_documents" add column "new_id" uuid;
