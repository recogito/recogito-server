create type "public"."action_types" as enum ('INFO', 'ERROR');

create table "public"."notifications" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "target_user_id" uuid,
    "message" character varying not null,
    "action_url" character varying,
    "action_message" character varying,
    "message_type" action_types,
    "is_acknowledged" boolean default false
);


alter table "public"."notifications" enable row level security;

CREATE INDEX notifications_by_target_user ON public.notifications USING btree (target_user_id);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."notifications" add constraint "notifications_target_user_id_fkey" FOREIGN KEY (target_user_id) REFERENCES auth.users(id) not valid;

alter table "public"."notifications" validate constraint "notifications_target_user_id_fkey";

alter table "public"."notifications" add constraint "notifications_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."notifications" validate constraint "notifications_updated_by_fkey";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

create policy "Users with correct policies can DELETE on notifications"
on "public"."notifications"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'notifications'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on notifications"
on "public"."notifications"
as permissive
for insert
to authenticated
with check (((target_user_id = auth.uid()) OR check_action_policy_organization(auth.uid(), 'notifications'::character varying, 'INSERT'::operation_types)));


create policy "Users with correct policies can SELECT on notifications"
on "public"."notifications"
as permissive
for select
to authenticated
using (((target_user_id = auth.uid()) AND check_action_policy_organization(auth.uid(), 'notifications'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can UPDATE on notifications"
on "public"."notifications"
as permissive
for update
to authenticated
using (( SELECT ((auth.uid() = notifications.target_user_id) OR check_action_policy_organization(auth.uid(), 'notifications'::character varying, 'UPDATE'::operation_types))))
with check (( SELECT ((auth.uid() = notifications.target_user_id) OR check_action_policy_organization(auth.uid(), 'notifications'::character varying, 'UPDATE'::operation_types))));


CREATE TRIGGER on_notification_created BEFORE INSERT ON public.notifications FOR EACH ROW EXECUTE FUNCTION create_dates_and_user();

CREATE TRIGGER on_notification_updated BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();


