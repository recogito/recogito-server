drop policy "Users with correct policies can DELETE on invites" on "public"."invites";

drop policy "Users with correct policies can INSERT on invites" on "public"."invites";

drop policy "Users with correct policies can SELECT on invites" on "public"."invites";

drop policy "Users with correct policies can UPDATE on invites" on "public"."invites";

create policy "Enable All access for authentocated users"
on "public"."invites"
as permissive
for all
to authenticated
using (true)
with check (true);



