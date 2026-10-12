DROP POLICY IF EXISTS "Users with correct policies can SELECT on buckets" ON storage.buckets;

CREATE POLICY "Users with correct policies can SELECT on buckets" ON storage.buckets FOR SELECT TO authenticated
    USING (TRUE);

DROP POLICY IF EXISTS "Users with correct policies can INSERT on buckets" ON storage.buckets;

CREATE POLICY "Users with correct policies can INSERT on buckets" ON storage.buckets FOR INSERT TO authenticated
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on buckets" ON storage.buckets;

CREATE POLICY "Users with correct policies can UPDATE on buckets" ON storage.buckets FOR UPDATE TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Users with correct policies can DELETE on buckets" ON storage.buckets;

CREATE POLICY "Users with correct policies can DELETE on buckets" ON storage.buckets FOR DELETE TO authenticated
    USING (TRUE);

-- storage.buckets has RLS enabled with no policy for `authenticated` by default, so a
-- SELECT policy is required for clients to read file_size_limit.
DROP POLICY IF EXISTS "Authenticated users can SELECT on buckets" ON storage.buckets;

CREATE POLICY "Authenticated users can SELECT on buckets" ON storage.buckets FOR SELECT TO authenticated
    USING (TRUE);

-- Column-level grant in case the role has no table-level SELECT grant on storage.buckets.
GRANT SELECT (id, name, file_size_limit) ON storage.buckets TO authenticated;
