
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE TYPE "public"."body_formats" AS ENUM (
    'TextPlain',
    'TextHtml'
);

ALTER TYPE "public"."body_formats" OWNER TO "postgres";

CREATE TYPE "public"."body_types" AS ENUM (
    'TextualBody'
);

ALTER TYPE "public"."body_types" OWNER TO "postgres";

CREATE TYPE "public"."group_types" AS ENUM (
    'organization',
    'project',
    'layer'
);

ALTER TYPE "public"."group_types" OWNER TO "postgres";

CREATE TYPE "public"."operation_types" AS ENUM (
    'SELECT',
    'INSERT',
    'UPDATE',
    'DELETE'
);

ALTER TYPE "public"."operation_types" OWNER TO "postgres";

CREATE TYPE "public"."profile_role_types" AS ENUM (
    'admin',
    'teacher',
    'base_user'
);

ALTER TYPE "public"."profile_role_types" OWNER TO "postgres";

CREATE TYPE "public"."tag_scope_types" AS ENUM (
    'organization',
    'project'
);

ALTER TYPE "public"."tag_scope_types" OWNER TO "postgres";

CREATE TYPE "public"."tag_target_types" AS ENUM (
    'project',
    'group',
    'document',
    'context',
    'layer',
    'profile'
);

ALTER TYPE "public"."tag_target_types" OWNER TO "postgres";

CREATE TYPE "public"."target_conforms_to_types" AS ENUM (
    'Svg'
);

ALTER TYPE "public"."target_conforms_to_types" OWNER TO "postgres";

CREATE TYPE "public"."target_selector_types" AS ENUM (
    'Fragment',
    'SvgSelector'
);

ALTER TYPE "public"."target_selector_types" OWNER TO "postgres";

CREATE FUNCTION "public"."check_action_policy_organization"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.organization_groups ag
                           INNER JOIN public.groups g ON ag.group_id = g.id
                           INNER JOIN public.group_users gu ON g.id = gu.group_id AND gu.user_id = $1
                           INNER JOIN public.roles r ON g.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$_$;

ALTER FUNCTION "public"."check_action_policy_organization"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types") OWNER TO "postgres";

CREATE FUNCTION "public"."check_action_policy_project"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types", "project_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.project_id = $4
                           INNER JOIN public.groups g ON pg.group_id = g.id
                           INNER JOIN public.group_users gu ON g.id = gu.group_id AND gu.user_id = $1
                           INNER JOIN public.roles r ON g.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$_$;

ALTER FUNCTION "public"."check_action_policy_project"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types", "project_id" "uuid") OWNER TO "postgres";

CREATE FUNCTION "public"."create_dates_and_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    NEW.created_at = NOW();
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."create_dates_and_user"() OWNER TO "postgres";

CREATE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email);
    RETURN new;
END;
$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

CREATE FUNCTION "public"."update_annotation_target_body"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    NEW.updated_at = NOW();
    -- created_at cannot be changed --
    NEW.created_at = OLD.created_at;
    NEW.updated_by = auth.uid();
    -- increment version ---
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_annotation_target_body"() OWNER TO "postgres";

CREATE FUNCTION "public"."update_dates_and_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.created_at = OLD.created_at;
    NEW.created_by = auth.uid();
    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_dates_and_user"() OWNER TO "postgres";

CREATE FUNCTION "public"."update_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- id's cannot be changed
    NEW.id = OLD.id;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_profile"() OWNER TO "postgres";

CREATE FUNCTION "public"."update_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.profiles
    SET email = NEW.email
    WHERE id = NEW.id;
    RETURN new;
END;
$$;

ALTER FUNCTION "public"."update_user"() OWNER TO "postgres";

CREATE FUNCTION "public"."update_version"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_version"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE "public"."annotations" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "version" integer DEFAULT 1 NOT NULL,
    "updated_by" "uuid",
    "layer_id" "uuid"
);

ALTER TABLE "public"."annotations" OWNER TO "postgres";

CREATE TABLE "public"."bodies" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "version" integer DEFAULT 1 NOT NULL,
    "annotation_id" "uuid",
    "type" "public"."body_types",
    "language" character varying,
    "format" "public"."body_formats",
    "purpose" character varying,
    "value" "text",
    "layer_id" "uuid"
);

ALTER TABLE "public"."bodies" OWNER TO "postgres";

CREATE TABLE "public"."contexts" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "name" character varying,
    "project_id" "uuid"
);

ALTER TABLE "public"."contexts" OWNER TO "postgres";

CREATE TABLE "public"."documents" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "name" character varying NOT NULL,
    "bucket_id" "text"
);

ALTER TABLE "public"."documents" OWNER TO "postgres";

CREATE TABLE "public"."group_users" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "group_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "group_type" "public"."group_types" NOT NULL
);

ALTER TABLE "public"."group_users" OWNER TO "postgres";

CREATE TABLE "public"."groups" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "role_id" "uuid"
);

ALTER TABLE "public"."groups" OWNER TO "postgres";

CREATE TABLE "public"."layer_groups" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "group_id" "uuid",
    "layer_id" "uuid",
    "description" character varying,
    "name" character varying NOT NULL
);

ALTER TABLE "public"."layer_groups" OWNER TO "postgres";

CREATE TABLE "public"."layers" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "context_id" "uuid",
    "name" character varying,
    "description" character varying,
    "document_id" "uuid"
);

ALTER TABLE "public"."layers" OWNER TO "postgres";

CREATE TABLE "public"."organization_groups" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "group_id" "uuid" NOT NULL,
    "description" character varying,
    "name" character varying NOT NULL
);

ALTER TABLE "public"."organization_groups" OWNER TO "postgres";

CREATE TABLE "public"."policies" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "table_name" character varying NOT NULL,
    "operation" "public"."operation_types" NOT NULL
);

ALTER TABLE "public"."policies" OWNER TO "postgres";

CREATE TABLE "public"."profiles" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "first_name" character varying,
    "last_name" character varying,
    "email" character varying,
    "nickname" character varying,
    "avatar_url" character varying,
    "gdpr_optin" boolean DEFAULT false,
    "role" "public"."profile_role_types" DEFAULT 'base_user'::"public"."profile_role_types" NOT NULL
);

ALTER TABLE "public"."profiles" OWNER TO "postgres";

CREATE TABLE "public"."project_groups" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "project_id" "uuid" NOT NULL,
    "group_id" "uuid" NOT NULL,
    "description" character varying,
    "name" character varying NOT NULL
);

ALTER TABLE "public"."project_groups" OWNER TO "postgres";

CREATE TABLE "public"."projects" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "name" character varying,
    "description" character varying
);

ALTER TABLE "public"."projects" OWNER TO "postgres";

CREATE TABLE "public"."role_policies" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "role_id" "uuid",
    "policy_id" "uuid"
);

ALTER TABLE "public"."role_policies" OWNER TO "postgres";

CREATE TABLE "public"."roles" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "name" character varying DEFAULT '!!!'::character varying NOT NULL,
    "description" character varying
);

ALTER TABLE "public"."roles" OWNER TO "postgres";

CREATE TABLE "public"."tag_definitions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "name" character varying NOT NULL,
    "target_type" "public"."tag_scope_types" NOT NULL,
    "scope" "public"."tag_scope_types" NOT NULL,
    "scope_id" "uuid"
);

ALTER TABLE "public"."tag_definitions" OWNER TO "postgres";

CREATE TABLE "public"."tags" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "tag_definition_id" "uuid"
);

ALTER TABLE "public"."tags" OWNER TO "postgres";

CREATE TABLE "public"."targets" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid" NOT NULL,
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "version" integer DEFAULT 1 NOT NULL,
    "annotation_id" "uuid",
    "selector_type" "public"."target_selector_types",
    "conforms_to" "public"."target_conforms_to_types",
    "value" "text",
    "layer_id" "uuid"
);

ALTER TABLE "public"."targets" OWNER TO "postgres";

ALTER TABLE ONLY "public"."annotations"
    ADD CONSTRAINT "annotations_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."layer_groups"
    ADD CONSTRAINT "assignment_groups_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."contexts"
    ADD CONSTRAINT "assignments_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."bodies"
    ADD CONSTRAINT "bodies_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."group_users"
    ADD CONSTRAINT "group_users_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."layers"
    ADD CONSTRAINT "layers_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."organization_groups"
    ADD CONSTRAINT "organization_groups_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."project_groups"
    ADD CONSTRAINT "project_groups_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."role_policies"
    ADD CONSTRAINT "role_policies_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."tag_definitions"
    ADD CONSTRAINT "tag_definitions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_pkey" PRIMARY KEY ("id");

CREATE UNIQUE INDEX "contexts_pkey" ON "public"."contexts" USING "btree" ("id");

CREATE UNIQUE INDEX "layer_groups_pkey" ON "public"."layer_groups" USING "btree" ("id");

CREATE TRIGGER "on_annotation_created" BEFORE INSERT ON "public"."annotations" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_annotation_updated" BEFORE UPDATE ON "public"."annotations" FOR EACH ROW EXECUTE FUNCTION "public"."update_annotation_target_body"();

CREATE TRIGGER "on_body_created" BEFORE INSERT ON "public"."bodies" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_body_updated" BEFORE UPDATE ON "public"."bodies" FOR EACH ROW EXECUTE FUNCTION "public"."update_annotation_target_body"();

CREATE TRIGGER "on_context_created" BEFORE INSERT ON "public"."contexts" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_context_updated" BEFORE UPDATE ON "public"."contexts" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_document_created" BEFORE INSERT ON "public"."documents" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_document_updated" BEFORE UPDATE ON "public"."documents" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_group_created" BEFORE INSERT ON "public"."groups" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_group_updated" BEFORE UPDATE ON "public"."groups" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_group_user_created" BEFORE INSERT ON "public"."group_users" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_group_user_updated" BEFORE UPDATE ON "public"."group_users" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_layer_created" BEFORE INSERT ON "public"."layers" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_layer_group_created" BEFORE INSERT ON "public"."layer_groups" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_layer_group_updated" BEFORE UPDATE ON "public"."layer_groups" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_layer_updated" BEFORE UPDATE ON "public"."layers" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_organization_group_created" BEFORE INSERT ON "public"."organization_groups" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_organization_group_updated" BEFORE UPDATE ON "public"."organization_groups" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_policy_created" BEFORE INSERT ON "public"."policies" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_policy_updated" BEFORE UPDATE ON "public"."policies" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_profile_updated" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_profile"();

CREATE TRIGGER "on_project_created" BEFORE INSERT ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_project_group_created" BEFORE INSERT ON "public"."project_groups" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_project_group_updated" BEFORE UPDATE ON "public"."project_groups" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_project_updated" BEFORE UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_role_created" BEFORE INSERT ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_role_policy_created" BEFORE INSERT ON "public"."role_policies" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_role_policy_updated" BEFORE UPDATE ON "public"."role_policies" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_role_updated" BEFORE UPDATE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_tag_created" BEFORE INSERT ON "public"."tags" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_tag_definition_created" BEFORE INSERT ON "public"."tag_definitions" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_tag_definition_updated" BEFORE UPDATE ON "public"."tag_definitions" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_tag_updated" BEFORE UPDATE ON "public"."tags" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();

CREATE TRIGGER "on_target_created" BEFORE INSERT ON "public"."targets" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

CREATE TRIGGER "on_target_updated" BEFORE UPDATE ON "public"."targets" FOR EACH ROW EXECUTE FUNCTION "public"."update_annotation_target_body"();

ALTER TABLE ONLY "public"."annotations"
    ADD CONSTRAINT "annotations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."annotations"
    ADD CONSTRAINT "annotations_layer_id_fkey" FOREIGN KEY ("layer_id") REFERENCES "public"."layers"("id");

ALTER TABLE ONLY "public"."annotations"
    ADD CONSTRAINT "annotations_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."bodies"
    ADD CONSTRAINT "bodies_annotation_id_fkey" FOREIGN KEY ("annotation_id") REFERENCES "public"."annotations"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."bodies"
    ADD CONSTRAINT "bodies_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."bodies"
    ADD CONSTRAINT "bodies_layer_id_fkey" FOREIGN KEY ("layer_id") REFERENCES "public"."layers"("id");

ALTER TABLE ONLY "public"."bodies"
    ADD CONSTRAINT "bodies_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."contexts"
    ADD CONSTRAINT "contexts_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."contexts"
    ADD CONSTRAINT "contexts_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");

ALTER TABLE ONLY "public"."contexts"
    ADD CONSTRAINT "contexts_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."annotations"
    ADD CONSTRAINT "fk_created_by" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."group_users"
    ADD CONSTRAINT "group_users_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."group_users"
    ADD CONSTRAINT "group_users_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."group_users"
    ADD CONSTRAINT "group_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id");

ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."layer_groups"
    ADD CONSTRAINT "layer_groups_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."layer_groups"
    ADD CONSTRAINT "layer_groups_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");

ALTER TABLE ONLY "public"."layer_groups"
    ADD CONSTRAINT "layer_groups_layer_id_fkey" FOREIGN KEY ("layer_id") REFERENCES "public"."layers"("id");

ALTER TABLE ONLY "public"."layer_groups"
    ADD CONSTRAINT "layer_groups_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."layers"
    ADD CONSTRAINT "layers_context_id_fkey" FOREIGN KEY ("context_id") REFERENCES "public"."contexts"("id");

ALTER TABLE ONLY "public"."layers"
    ADD CONSTRAINT "layers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."layers"
    ADD CONSTRAINT "layers_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "public"."documents"("id");

ALTER TABLE ONLY "public"."layers"
    ADD CONSTRAINT "layers_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."organization_groups"
    ADD CONSTRAINT "organization_groups_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."organization_groups"
    ADD CONSTRAINT "organization_groups_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");

ALTER TABLE ONLY "public"."organization_groups"
    ADD CONSTRAINT "organization_groups_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."project_groups"
    ADD CONSTRAINT "project_groups_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."project_groups"
    ADD CONSTRAINT "project_groups_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");

ALTER TABLE ONLY "public"."project_groups"
    ADD CONSTRAINT "project_groups_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");

ALTER TABLE ONLY "public"."project_groups"
    ADD CONSTRAINT "project_groups_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."role_policies"
    ADD CONSTRAINT "role_policies_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."role_policies"
    ADD CONSTRAINT "role_policies_policy_id_fkey" FOREIGN KEY ("policy_id") REFERENCES "public"."policies"("id");

ALTER TABLE ONLY "public"."role_policies"
    ADD CONSTRAINT "role_policies_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id");

ALTER TABLE ONLY "public"."role_policies"
    ADD CONSTRAINT "role_policies_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."tag_definitions"
    ADD CONSTRAINT "tag_definitions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."tag_definitions"
    ADD CONSTRAINT "tag_definitions_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_tag_definition_id_fkey" FOREIGN KEY ("tag_definition_id") REFERENCES "public"."tag_definitions"("id");

ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_annotation_id_fkey" FOREIGN KEY ("annotation_id") REFERENCES "public"."annotations"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_layer_id_fkey" FOREIGN KEY ("layer_id") REFERENCES "public"."layers"("id");

ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id");

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."documents" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."group_users" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."groups" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."layer_groups" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."layers" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."organization_groups" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."policies" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."project_groups" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."projects" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."role_policies" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."roles" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL access for authenticated users" ON "public"."tags" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL for authenticated users only" ON "public"."annotations" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL for authenticated users only" ON "public"."bodies" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL for authenticated users only" ON "public"."contexts" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL for authenticated users only" ON "public"."profiles" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable ALL for authenticated users only" ON "public"."targets" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable All access for Authenticated users" ON "public"."tag_definitions" TO "authenticated" USING (true) WITH CHECK (true);

ALTER TABLE "public"."annotations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."bodies" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."contexts" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."documents" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."group_users" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."groups" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."layer_groups" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."layers" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."organization_groups" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."policies" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."project_groups" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."projects" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."role_policies" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."tag_definitions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."tags" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."targets" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."check_action_policy_organization"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types") TO "anon";
GRANT ALL ON FUNCTION "public"."check_action_policy_organization"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_action_policy_organization"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types") TO "service_role";

GRANT ALL ON FUNCTION "public"."check_action_policy_project"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types", "project_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_action_policy_project"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types", "project_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_action_policy_project"("user_id" "uuid", "table_name" character varying, "operation" "public"."operation_types", "project_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."create_dates_and_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_dates_and_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_dates_and_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."update_annotation_target_body"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_annotation_target_body"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_annotation_target_body"() TO "service_role";

GRANT ALL ON FUNCTION "public"."update_dates_and_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_dates_and_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_dates_and_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."update_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_profile"() TO "service_role";

GRANT ALL ON FUNCTION "public"."update_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."update_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_version"() TO "service_role";

GRANT ALL ON TABLE "public"."annotations" TO "anon";
GRANT ALL ON TABLE "public"."annotations" TO "authenticated";
GRANT ALL ON TABLE "public"."annotations" TO "service_role";

GRANT ALL ON TABLE "public"."bodies" TO "anon";
GRANT ALL ON TABLE "public"."bodies" TO "authenticated";
GRANT ALL ON TABLE "public"."bodies" TO "service_role";

GRANT ALL ON TABLE "public"."contexts" TO "anon";
GRANT ALL ON TABLE "public"."contexts" TO "authenticated";
GRANT ALL ON TABLE "public"."contexts" TO "service_role";

GRANT ALL ON TABLE "public"."documents" TO "anon";
GRANT ALL ON TABLE "public"."documents" TO "authenticated";
GRANT ALL ON TABLE "public"."documents" TO "service_role";

GRANT ALL ON TABLE "public"."group_users" TO "anon";
GRANT ALL ON TABLE "public"."group_users" TO "authenticated";
GRANT ALL ON TABLE "public"."group_users" TO "service_role";

GRANT ALL ON TABLE "public"."groups" TO "anon";
GRANT ALL ON TABLE "public"."groups" TO "authenticated";
GRANT ALL ON TABLE "public"."groups" TO "service_role";

GRANT ALL ON TABLE "public"."layer_groups" TO "anon";
GRANT ALL ON TABLE "public"."layer_groups" TO "authenticated";
GRANT ALL ON TABLE "public"."layer_groups" TO "service_role";

GRANT ALL ON TABLE "public"."layers" TO "anon";
GRANT ALL ON TABLE "public"."layers" TO "authenticated";
GRANT ALL ON TABLE "public"."layers" TO "service_role";

GRANT ALL ON TABLE "public"."organization_groups" TO "anon";
GRANT ALL ON TABLE "public"."organization_groups" TO "authenticated";
GRANT ALL ON TABLE "public"."organization_groups" TO "service_role";

GRANT ALL ON TABLE "public"."policies" TO "anon";
GRANT ALL ON TABLE "public"."policies" TO "authenticated";
GRANT ALL ON TABLE "public"."policies" TO "service_role";

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";

GRANT ALL ON TABLE "public"."project_groups" TO "anon";
GRANT ALL ON TABLE "public"."project_groups" TO "authenticated";
GRANT ALL ON TABLE "public"."project_groups" TO "service_role";

GRANT ALL ON TABLE "public"."projects" TO "anon";
GRANT ALL ON TABLE "public"."projects" TO "authenticated";
GRANT ALL ON TABLE "public"."projects" TO "service_role";

GRANT ALL ON TABLE "public"."role_policies" TO "anon";
GRANT ALL ON TABLE "public"."role_policies" TO "authenticated";
GRANT ALL ON TABLE "public"."role_policies" TO "service_role";

GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";

GRANT ALL ON TABLE "public"."tag_definitions" TO "anon";
GRANT ALL ON TABLE "public"."tag_definitions" TO "authenticated";
GRANT ALL ON TABLE "public"."tag_definitions" TO "service_role";

GRANT ALL ON TABLE "public"."tags" TO "anon";
GRANT ALL ON TABLE "public"."tags" TO "authenticated";
GRANT ALL ON TABLE "public"."tags" TO "service_role";

GRANT ALL ON TABLE "public"."targets" TO "anon";
GRANT ALL ON TABLE "public"."targets" TO "authenticated";
GRANT ALL ON TABLE "public"."targets" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
