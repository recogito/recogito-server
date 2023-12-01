DROP POLICY IF EXISTS "Users with correct policies can SELECT on objects" ON storage.objects;

CREATE POLICY "Users with correct policies can SELECT on objects" ON storage.objects FOR SELECT TO authenticated
    USING (TRUE);

DROP POLICY IF EXISTS "Users with correct policies can INSERT on objects" ON storage.objects;

CREATE POLICY "Users with correct policies can INSERT on objects" ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Users with correct policies can UPDATE on objects" ON storage.objects;

CREATE POLICY "Users with correct policies can UPDATE on objects" ON storage.objects FOR UPDATE TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Users with correct policies can DELETE on objects" ON storage.objects;

CREATE POLICY "Users with correct policies can DELETE on objects" ON storage.objects FOR DELETE TO authenticated
    USING (TRUE);
