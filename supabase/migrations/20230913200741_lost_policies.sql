
drop policy IF EXISTS "Enable ALL access for authenticated users" on "public"."roles";

DROP POLICY IF EXISTS "Enable ALL access for authenticated users" on "public"."project_groups";

DROP POLICY if EXISTS "Enable ALL access for authenticated users" on "public"."projects";

DROP policy IF EXISTS "Users with correct policies can DELETE on organization_groups"
    on "public"."organization_groups";

create policy "Users with correct policies can DELETE on organization_groups"
on "public"."organization_groups"
as permissive
for delete
to authenticated
using (check_action_policy_organization(auth.uid(), 'organization_groups'::character varying, 'DELETE'::operation_types));

drop policy IF EXISTS "Users with correct policies can INSERT on organization_groups"
    on "public"."organization_groups";

create policy "Users with correct policies can INSERT on organization_groups"
on "public"."organization_groups"
as permissive
for insert
to authenticated
with check (check_action_policy_organization(auth.uid(), 'organization_groups'::character varying, 'INSERT'::operation_types));

DROP policy IF EXISTS "Users with correct policies can UPDATE on organization_groups"
    on "public"."organization_groups";

create policy "Users with correct policies can UPDATE on organization_groups"
on "public"."organization_groups"
as permissive
for update
to authenticated
using (check_action_policy_organization(auth.uid(), 'organization_groups'::character varying, 'UPDATE'::operation_types))
with check (check_action_policy_organization(auth.uid(), 'organization_groups'::character varying, 'UPDATE'::operation_types));



