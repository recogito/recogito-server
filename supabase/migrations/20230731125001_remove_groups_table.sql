drop trigger if exists "on_group_created" on "public"."groups";

drop trigger if exists "on_group_updated" on "public"."groups";

drop policy "Enable ALL access for authenticated users" on "public"."groups";

alter table "public"."groups" drop constraint "groups_created_by_fkey";

alter table "public"."groups" drop constraint "groups_role_id_fkey";

alter table "public"."groups" drop constraint "groups_updated_by_fkey";

alter table "public"."groups" drop constraint "groups_pkey";

drop index if exists "public"."groups_pkey";

drop table "public"."groups";


