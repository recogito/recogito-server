create type "public"."default_group_types" as enum ('project', 'layer');

create table "public"."default_groups" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "group_type" default_group_types not null,
    "name" character varying not null,
    "description" character varying not null,
    "role_id" uuid not null
);


alter table "public"."default_groups" enable row level security;

CREATE UNIQUE INDEX default_groups_pkey ON public.default_groups USING btree (id);

alter table "public"."default_groups" add constraint "default_groups_pkey" PRIMARY KEY using index "default_groups_pkey";

alter table "public"."default_groups" add constraint "default_groups_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) not valid;

alter table "public"."default_groups" validate constraint "default_groups_role_id_fkey";

alter table "public"."default_groups" add constraint "default_groups_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."default_groups" validate constraint "default_groups_updated_by_fkey";

create policy "Enable All access for Authenticated users"
on "public"."default_groups"
as permissive
for all
to authenticated
using (true)
with check (true);



