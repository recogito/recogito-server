drop trigger if exists "on_project_document_created" on "public"."project_documents";

drop trigger if exists "on_project_document_updated" on "public"."project_documents";

drop policy "Users with correct policies can DELETE on project_documents" on "public"."project_documents";

drop policy "Users with correct policies can INSERT on project_documents" on "public"."project_documents";

drop policy "Users with correct policies can SELECT on project_documents" on "public"."project_documents";

drop policy "Users with correct policies can UPDATE on project_documents" on "public"."project_documents";

alter table "public"."project_documents" drop constraint "project_documents_created_by_fkey";

alter table "public"."project_documents" drop constraint "project_documents_document_id_fkey";

alter table "public"."project_documents" drop constraint "project_documents_project_id_fkey";

alter table "public"."project_documents" drop constraint "project_documents_updated_by_fkey";

alter table "public"."project_documents" drop constraint "project_documents_pkey";

drop index if exists "public"."project_documents_pkey";

drop table "public"."project_documents";

alter type "public"."body_formats" rename to "body_formats__old_version_to_be_dropped";

create type "public"."body_formats" as enum ('TextPlain', 'TextHtml', 'Quill');

alter table "public"."bodies" alter column format type "public"."body_formats" using format::text::"public"."body_formats";

drop type "public"."body_formats__old_version_to_be_dropped";

alter table "public"."bodies" drop column "render_type";

drop type "public"."render_type_types";


