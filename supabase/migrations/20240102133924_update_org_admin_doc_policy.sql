create extension if not exists "pg_cron" with schema "extensions";

drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

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