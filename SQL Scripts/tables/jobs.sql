create type "public"."job_statuses" as enum ('INITIALIZING', 'PROCESSING', 'COMPLETE', 'ERROR');

create type "public"."job_types" as enum ('EXPORT');

create table "public"."jobs" (
    "id" uuid NOT NULL default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "bucket_id" text,
    "name" character varying NOT NULL,
    "job_status" job_statuses default 'INITIALIZING',
    "job_type" job_types
);

alter table "public"."jobs" ENABLE ROW LEVEL SECURITY;

create unique index jobs_pkey ON "public"."jobs" USING btree (id);

alter table "public"."jobs" add constraint "jobs_pkey" PRIMARY KEY using index "jobs_pkey";

alter table "public"."jobs" add constraint "jobs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."jobs" validate constraint "jobs_created_by_fkey";

alter table "public"."jobs" add constraint "jobs_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."jobs" validate constraint "jobs_updated_by_fkey";