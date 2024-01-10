create extension if not exists "pg_cron" with schema "extensions";


create type "public"."activation_types" as enum ('cron', 'direct_call');

drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

create table "public"."collections" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "name" character varying not null,
    "extension_id" uuid,
    "extension_metadata" json
);


alter table "public"."collections" enable row level security;

create table "public"."extensions" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "activation_type" activation_types not null,
    "metadata" json
);


alter table "public"."extensions" enable row level security;

alter table "public"."documents" add column "collection_id" uuid;

alter table "public"."documents" add column "collection_metadata" json;

CREATE UNIQUE INDEX collections_pkey ON public.collections USING btree (id);

CREATE UNIQUE INDEX extensions_pkey ON public.extensions USING btree (id);

alter table "public"."collections" add constraint "collections_pkey" PRIMARY KEY using index "collections_pkey";

alter table "public"."extensions" add constraint "extensions_pkey" PRIMARY KEY using index "extensions_pkey";

alter table "public"."collections" add constraint "collections_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."collections" validate constraint "collections_created_by_fkey";

alter table "public"."collections" add constraint "collections_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES extensions(id) not valid;

alter table "public"."collections" validate constraint "collections_extension_id_fkey";

alter table "public"."collections" add constraint "collections_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."collections" validate constraint "collections_updated_by_fkey";

alter table "public"."documents" add constraint "documents_collection_id_fkey" FOREIGN KEY (collection_id) REFERENCES collections(id) not valid;

alter table "public"."documents" validate constraint "documents_collection_id_fkey";

alter table "public"."extensions" add constraint "extensions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."extensions" validate constraint "extensions_created_by_fkey";

alter table "public"."extensions" add constraint "extensions_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."extensions" validate constraint "extensions_updated_by_fkey";

create policy "Users with correct policies can DELETE on collections"
on "public"."collections"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on collections"
on "public"."collections"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on collections"
on "public"."collections"
as permissive
for select
to authenticated
using (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'SELECT'::operation_types));


create policy "Users with correct policies can UPDATE on collections"
on "public"."collections"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'UPDATE'::operation_types));


create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND ((collection_id IS NULL) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on documents"
on "public"."documents"
as permissive
for insert
to authenticated
with check (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND ((collection_id IS NULL) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can SELECT on documents"
on "public"."documents"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND ((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can UPDATE on documents"
on "public"."documents"
as permissive
for update
to authenticated
using (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id)))
with check (((((is_private = false) OR (created_by = auth.uid()) OR is_admin_organization(auth.uid())) AND ((collection_id IS NULL) OR is_admin_organization(auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id)));


CREATE TRIGGER on_collection_created BEFORE INSERT ON public.collections FOR EACH ROW EXECUTE FUNCTION create_dates_and_user();

CREATE TRIGGER on_collection_updated BEFORE UPDATE ON public.collections FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();