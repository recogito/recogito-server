drop policy "Users with correct policies can DELETE on tag_definitions" on "public"."tag_definitions";

drop policy "Users with correct policies can INSERT on tag_definitions" on "public"."tag_definitions";

drop policy "Users with correct policies can SELECT on tag_definitions" on "public"."tag_definitions";

drop policy "Users with correct policies can UPDATE on tag_definitions" on "public"."tag_definitions";

create policy "Enable All access for authenticated users"
on "public"."tag_definitions"
as permissive
for all
to authenticated
using (true)
with check (true);



