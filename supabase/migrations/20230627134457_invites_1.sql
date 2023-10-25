create table "public"."invites" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "email" character varying not null,
    "project_id" uuid,
    "project_group_id" uuid,
    "accepted" boolean default false,
    "ignored" boolean default false
);


alter table "public"."invites" enable row level security;

CREATE UNIQUE INDEX invites_pkey ON public.invites USING btree (id);

alter table "public"."invites" add constraint "invites_pkey" PRIMARY KEY using index "invites_pkey";

alter table "public"."invites" add constraint "invites_project_group_id_fkey" FOREIGN KEY (project_group_id) REFERENCES project_groups(id) not valid;

alter table "public"."invites" validate constraint "invites_project_group_id_fkey";

alter table "public"."invites" add constraint "invites_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) not valid;

alter table "public"."invites" validate constraint "invites_project_id_fkey";

alter table "public"."invites" add constraint "invites_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."invites" validate constraint "invites_updated_by_fkey";

create policy "Enable ALL access for all authenticated users"
on "public"."invites"
as permissive
for all
to authenticated
using (true)
with check (true);


CREATE TRIGGER on_invite_created BEFORE INSERT ON public.invites FOR EACH ROW EXECUTE FUNCTION create_dates_and_user();

CREATE TRIGGER on_invite_updated BEFORE UPDATE ON public.invites FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();


