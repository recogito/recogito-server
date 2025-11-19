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

grant delete on table "public"."jobs" to "anon";

grant insert on table "public"."jobs" to "anon";

grant references on table "public"."jobs" to "anon";

grant select on table "public"."jobs" to "anon";

grant trigger on table "public"."jobs" to "anon";

grant truncate on table "public"."jobs" to "anon";

grant update on table "public"."jobs" to "anon";

grant delete on table "public"."jobs" to "authenticated";

grant insert on table "public"."jobs" to "authenticated";

grant references on table "public"."jobs" to "authenticated";

grant select on table "public"."jobs" to "authenticated";

grant trigger on table "public"."jobs" to "authenticated";

grant truncate on table "public"."jobs" to "authenticated";

grant update on table "public"."jobs" to "authenticated";

grant delete on table "public"."jobs" to "service_role";

grant insert on table "public"."jobs" to "service_role";

grant references on table "public"."jobs" to "service_role";

grant select on table "public"."jobs" to "service_role";

grant trigger on table "public"."jobs" to "service_role";

grant truncate on table "public"."jobs" to "service_role";

grant update on table "public"."jobs" to "service_role";

create policy "Users with correct policies can DELETE on jobs"
on "public"."jobs"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'jobs'::character varying, 'DELETE'::operation_types));

create policy "Users with correct policies can INSERT on jobs"
on "public"."jobs"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'jobs'::character varying, 'INSERT'::operation_types));

create policy "Users with correct policies can SELECT on jobs"
on "public"."jobs"
as permissive
for select
to authenticated
using (check_action_policy_organization(auth.uid(), 'jobs'::character varying, 'SELECT'::operation_types));

create policy "Users with correct policies can UPDATE on jobs"
on "public"."jobs"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'jobs'::character varying, 'UPDATE'::operation_types));

CREATE TRIGGER on_job_created BEFORE INSERT ON public.jobs FOR EACH ROW EXECUTE FUNCTION create_dates_and_user();

CREATE TRIGGER on_job_updated BEFORE UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();