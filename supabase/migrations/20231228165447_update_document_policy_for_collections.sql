DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'activation_types') THEN
      CREATE TYPE activation_types AS ENUM('cron', 'direct_call');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS public.extensions (
    id uuid NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid REFERENCES public.profiles,
    updated_at timestamptz,
    updated_by uuid REFERENCES public.profiles,
    activation_type activation_types NOT NULL,
    metadata json
);

CREATE TABLE IF NOT EXISTS public.collections (
    id uuid NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid REFERENCES public.profiles,
    updated_at timestamptz,
    updated_by uuid REFERENCES public.profiles,
    name varchar NOT NULL,
    extension_id uuid REFERENCES public.extensions,
    extension_metadata json
);

ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS collection_id uuid REFERENCES public.collections;

drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on documents"
on "public"."documents"
as permissive
for insert
to authenticated
with check (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can UPDATE on documents"
on "public"."documents"
as permissive
for update
to authenticated
using (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR (((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id))))
with check (((((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR (((is_private = false) OR (created_by = auth.uid())) AND (collection_id IS NULL) AND check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id))));



