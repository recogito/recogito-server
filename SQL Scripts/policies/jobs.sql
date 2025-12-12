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