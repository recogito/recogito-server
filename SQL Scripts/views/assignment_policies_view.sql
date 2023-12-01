CREATE OR REPLACE VIEW assignment_policies_view AS
SELECT a.id,
       a.name,
       g.id      AS group_id,
       pr.id    AS user_id,
       r.id       AS role_id,
       p.table_name,
       p.operation
FROM public.assignments a
         INNER JOIN public.assignment_groups ag ON ag.assignment_id = a.id
         INNER JOIN public.groups g ON ag.group_id = g.id
         INNER JOIN public.group_users gu ON g.id = gu.group_id
         INNER JOIN public.profiles pr ON gu.user_id = pr.id
         INNER JOIN public.roles r ON g.role_id = r.id
         INNER JOIN public.role_policies rp ON r.id = rp.role_id
         INNER JOIN public.policies p ON rp.policy_id = p.id;
