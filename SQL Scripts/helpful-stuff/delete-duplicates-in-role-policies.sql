BEGIN;

DELETE
FROM public.role_policies a
    USING public.role_policies b
WHERE a.created_at < b.created_at
  AND a.role_id = b.role_id
  AND a.policy_id = b.policy_id;

ROLLBACK;
