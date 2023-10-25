drop policy "Users with correct policies can DELETE on tags" on "public"."tags";

drop policy "Users with correct policies can INSERT on tags" on "public"."tags";

drop policy "Users with correct policies can SELECT on tags" on "public"."tags";

drop policy "Users with correct policies can UPDATE on tags" on "public"."tags";

create policy "Enable All access for authenticated users"
on "public"."tags"
as permissive
for all
to authenticated
using (true)
with check (true);



