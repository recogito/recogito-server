alter table "public"."extensions" enable row level security;

drop policy if exists "Users with correct policies can DELETE on collections"
on "public"."collections";

drop policy if exists "Users with correct policies can INSERT on collections"
on "public"."collections";

drop policy if exists "Users with correct policies can SELECT on collections"
on "public"."collections";

drop policy if exists "Users with correct policies can UPDATE on collections"
on "public"."collections";

create policy "Users with correct policies can DELETE on collections"
on "public"."collections"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'DELETE'::operation_types));


create policy "Users with correct policies can INSERT on collections"
on "public"."collections"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'INSERT'::operation_types));


create policy "Users with correct policies can SELECT on collections"
on "public"."collections"
as permissive
for select
to authenticated
using (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'SELECT'::operation_types));


create policy "Users with correct policies can UPDATE on collections"
on "public"."collections"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'collections'::character varying, 'UPDATE'::operation_types));



