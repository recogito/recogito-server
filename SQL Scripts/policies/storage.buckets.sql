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
