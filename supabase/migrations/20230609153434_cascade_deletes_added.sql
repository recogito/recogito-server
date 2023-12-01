drop policy "Enable ALL access for authenticated users" on "public"."projects";

alter table "public"."annotations" drop constraint "annotations_layer_id_fkey";

alter table "public"."contexts" drop constraint "contexts_project_id_fkey";

alter table "public"."group_users" drop constraint "group_users_group_id_fkey";

alter table "public"."groups" drop constraint "groups_role_id_fkey";

alter table "public"."layer_contexts" drop constraint "layer_contexts_context_id_fkey";

alter table "public"."layer_contexts" drop constraint "layer_contexts_layer_id_fkey";

alter table "public"."layer_groups" drop constraint "layer_groups_group_id_fkey";

alter table "public"."layer_groups" drop constraint "layer_groups_layer_id_fkey";

alter table "public"."layers" drop constraint "layers_document_id_fkey";

alter table "public"."organization_groups" drop constraint "organization_groups_group_id_fkey";

alter table "public"."project_groups" drop constraint "project_groups_group_id_fkey";

alter table "public"."project_groups" drop constraint "project_groups_project_id_fkey";

alter table "public"."role_policies" drop constraint "role_policies_role_id_fkey";

alter table "public"."tags" drop constraint "tags_tag_definition_id_fkey";

alter table "public"."annotations" add constraint "annotations_layer_id_fkey" FOREIGN KEY (layer_id) REFERENCES layers(id) ON DELETE CASCADE not valid;

alter table "public"."annotations" validate constraint "annotations_layer_id_fkey";

alter table "public"."contexts" add constraint "contexts_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE not valid;

alter table "public"."contexts" validate constraint "contexts_project_id_fkey";

alter table "public"."group_users" add constraint "group_users_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE not valid;

alter table "public"."group_users" validate constraint "group_users_group_id_fkey";

alter table "public"."groups" add constraint "groups_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE not valid;

alter table "public"."groups" validate constraint "groups_role_id_fkey";

alter table "public"."layer_contexts" add constraint "layer_contexts_context_id_fkey" FOREIGN KEY (context_id) REFERENCES contexts(id) ON DELETE CASCADE not valid;

alter table "public"."layer_contexts" validate constraint "layer_contexts_context_id_fkey";

alter table "public"."layer_contexts" add constraint "layer_contexts_layer_id_fkey" FOREIGN KEY (layer_id) REFERENCES layers(id) ON DELETE CASCADE not valid;

alter table "public"."layer_contexts" validate constraint "layer_contexts_layer_id_fkey";

alter table "public"."layer_groups" add constraint "layer_groups_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE not valid;

alter table "public"."layer_groups" validate constraint "layer_groups_group_id_fkey";

alter table "public"."layer_groups" add constraint "layer_groups_layer_id_fkey" FOREIGN KEY (layer_id) REFERENCES layers(id) ON DELETE CASCADE not valid;

alter table "public"."layer_groups" validate constraint "layer_groups_layer_id_fkey";

alter table "public"."layers" add constraint "layers_document_id_fkey" FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE not valid;

alter table "public"."layers" validate constraint "layers_document_id_fkey";

alter table "public"."organization_groups" add constraint "organization_groups_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE not valid;

alter table "public"."organization_groups" validate constraint "organization_groups_group_id_fkey";

alter table "public"."project_groups" add constraint "project_groups_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE not valid;

alter table "public"."project_groups" validate constraint "project_groups_group_id_fkey";

alter table "public"."project_groups" add constraint "project_groups_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE not valid;

alter table "public"."project_groups" validate constraint "project_groups_project_id_fkey";

alter table "public"."role_policies" add constraint "role_policies_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE not valid;

alter table "public"."role_policies" validate constraint "role_policies_role_id_fkey";

alter table "public"."tags" add constraint "tags_tag_definition_id_fkey" FOREIGN KEY (tag_definition_id) REFERENCES tag_definitions(id) ON DELETE CASCADE not valid;

alter table "public"."tags" validate constraint "tags_tag_definition_id_fkey";

create policy "Users with correct policies can DELETE on projects"
on "public"."projects"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'projects'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on projects"
on "public"."projects"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'projects'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on projects"
on "public"."projects"
as permissive
for select
to authenticated
using ((check_action_policy_organization(auth.uid(), 'projects'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'projects'::character varying, 'SELECT'::operation_types, id)));


create policy "Users with correct policies can UPDATE on projects"
on "public"."projects"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'projects'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'projects'::character varying, 'UPDATE'::operation_types, id)))
with check ((check_action_policy_organization(auth.uid(), 'projects'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'projects'::character varying, 'UPDATE'::operation_types, id)));



