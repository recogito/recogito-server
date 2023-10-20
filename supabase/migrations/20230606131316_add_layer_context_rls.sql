alter table "public"."layer_contexts" enable row level security;

create policy "Enable ALL access for authenticated users"
on "public"."layer_contexts"
as permissive
for all
to authenticated
using (true)
with check (true);



