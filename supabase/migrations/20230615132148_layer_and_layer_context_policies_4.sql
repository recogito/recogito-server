alter table "public"."layers" add column "project_id" uuid not null;

alter table "public"."layers" add constraint "layers_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) not valid;

alter table "public"."layers" validate constraint "layers_project_id_fkey";

create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on documents"
on "public"."documents"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on documents"
on "public"."documents"
as permissive
for select
to authenticated
using (check_action_policy_organization(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types));


create policy "Users with correct policies can UPDATE on documents"
on "public"."documents"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types));



