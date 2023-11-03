alter table "public"."bodies" alter column "render_type" drop default;

alter type "public"."render_type_types" rename to "render_type_types__old_version_to_be_dropped";

create type "public"."render_type_types" as enum ('text', 'quill');

create table "public"."project_documents" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "is_archived" boolean default false,
    "project_id" uuid,
    "document_id" uuid
);


alter table "public"."project_documents" enable row level security;

alter table "public"."bodies" alter column render_type type "public"."render_type_types" using render_type::text::"public"."render_type_types";

alter table "public"."bodies" alter column "render_type" set default 'text'::render_type_types;

drop type "public"."render_type_types__old_version_to_be_dropped";

alter table "public"."bodies" alter column "render_type" set not null;

CREATE UNIQUE INDEX project_documents_pkey ON public.project_documents USING btree (id);

alter table "public"."project_documents" add constraint "project_documents_pkey" PRIMARY KEY using index "project_documents_pkey";

alter table "public"."project_documents" add constraint "project_documents_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_created_by_fkey";

alter table "public"."project_documents" add constraint "project_documents_document_id_fkey" FOREIGN KEY (document_id) REFERENCES documents(id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_document_id_fkey";

alter table "public"."project_documents" add constraint "project_documents_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_project_id_fkey";

alter table "public"."project_documents" add constraint "project_documents_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_updated_by_fkey";

create policy "Users with correct policies can DELETE on project_documents"
on "public"."project_documents"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'project_documents'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'project_documents'::character varying, 'DELETE'::operation_types, project_id)));


create policy "Users with correct policies can INSERT on project_documents"
on "public"."project_documents"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'project_documents'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'project_documents'::character varying, 'INSERT'::operation_types, project_id)));


create policy "Users with correct policies can SELECT on project_documents"
on "public"."project_documents"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'project_documents'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'project_documents'::character varying, 'SELECT'::operation_types, project_id))));


create policy "Users with correct policies can UPDATE on project_documents"
on "public"."project_documents"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'project_documents'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'project_documents'::character varying, 'UPDATE'::operation_types, project_id)))
with check ((check_action_policy_organization(auth.uid(), 'project_documents'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'project_documents'::character varying, 'UPDATE'::operation_types, project_id)));


CREATE TRIGGER on_project_document_created BEFORE INSERT ON public.project_documents FOR EACH ROW EXECUTE FUNCTION create_dates_and_user();

CREATE TRIGGER on_project_document_updated BEFORE INSERT ON public.project_documents FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();


