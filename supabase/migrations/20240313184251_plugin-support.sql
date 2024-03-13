create table "public"."installed_plugins" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "project_id" uuid not null,
    "plugin_name" character varying not null,
    "plugin_id" uuid not null,
    "plugin_settings" json
);


alter table "public"."installed_plugins" enable row level security;

CREATE UNIQUE INDEX installed_plugins_pkey ON public.installed_plugins USING btree (id);

alter table "public"."installed_plugins" add constraint "installed_plugins_pkey" PRIMARY KEY using index "installed_plugins_pkey";

alter table "public"."installed_plugins" add constraint "installed_plugins_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."installed_plugins" validate constraint "installed_plugins_created_by_fkey";

alter table "public"."installed_plugins" add constraint "installed_plugins_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) not valid;

alter table "public"."installed_plugins" validate constraint "installed_plugins_project_id_fkey";

alter table "public"."installed_plugins" add constraint "installed_plugins_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."installed_plugins" validate constraint "installed_plugins_updated_by_fkey";

grant delete on table "public"."installed_plugins" to "anon";

grant insert on table "public"."installed_plugins" to "anon";

grant references on table "public"."installed_plugins" to "anon";

grant select on table "public"."installed_plugins" to "anon";

grant trigger on table "public"."installed_plugins" to "anon";

grant truncate on table "public"."installed_plugins" to "anon";

grant update on table "public"."installed_plugins" to "anon";

grant delete on table "public"."installed_plugins" to "authenticated";

grant insert on table "public"."installed_plugins" to "authenticated";

grant references on table "public"."installed_plugins" to "authenticated";

grant select on table "public"."installed_plugins" to "authenticated";

grant trigger on table "public"."installed_plugins" to "authenticated";

grant truncate on table "public"."installed_plugins" to "authenticated";

grant update on table "public"."installed_plugins" to "authenticated";

grant delete on table "public"."installed_plugins" to "service_role";

grant insert on table "public"."installed_plugins" to "service_role";

grant references on table "public"."installed_plugins" to "service_role";

grant select on table "public"."installed_plugins" to "service_role";

grant trigger on table "public"."installed_plugins" to "service_role";

grant truncate on table "public"."installed_plugins" to "service_role";

grant update on table "public"."installed_plugins" to "service_role";

create policy "Users with correct policies can DELETE on installed_plugins"
on "public"."installed_plugins"
as permissive
for delete
to authenticated
using ((check_action_policy_organization(auth.uid(), 'installed_plugins'::character varying, 'DELETE'::operation_types) OR check_action_policy_project(auth.uid(), 'installed_plugins'::character varying, 'DELETE'::operation_types, project_id)));


create policy "Users with correct policies can INSERT on installed_plugins"
on "public"."installed_plugins"
as permissive
for insert
to authenticated
with check ((check_action_policy_organization(auth.uid(), 'installed_plugins'::character varying, 'INSERT'::operation_types) OR check_action_policy_project(auth.uid(), 'installed_plugins'::character varying, 'INSERT'::operation_types, project_id)));


create policy "Users with correct policies can SELECT on installed_plugins"
on "public"."installed_plugins"
as permissive
for select
to authenticated
using ((check_action_policy_organization(auth.uid(), 'installed_plugins'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'installed_plugins'::character varying, 'SELECT'::operation_types, project_id)));


create policy "Users with correct policies can UPDATE on installed_plugins"
on "public"."installed_plugins"
as permissive
for update
to authenticated
using ((check_action_policy_organization(auth.uid(), 'installed_plugins'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'installed_plugins'::character varying, 'UPDATE'::operation_types, project_id)))
with check ((check_action_policy_organization(auth.uid(), 'installed_plugins'::character varying, 'UPDATE'::operation_types) OR check_action_policy_project(auth.uid(), 'installed_plugins'::character varying, 'UPDATE'::operation_types, project_id)));



