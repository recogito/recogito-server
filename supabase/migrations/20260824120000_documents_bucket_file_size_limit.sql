-- Raise the `documents` storage bucket file size limit to 500MB, and let authenticated
-- users read it so the client can validate uploads before sending them.

-- The bucket is created outside of migrations (see "SQL Scripts/storage/documents_buckets.sql"),
-- so it may not exist yet on a fresh database -- upsert rather than a no-op UPDATE.
INSERT INTO storage.buckets (id, name, file_size_limit)
VALUES ('documents', 'documents', 500 * 1024 * 1024) -- 500 MB
ON CONFLICT (id) DO UPDATE
    SET file_size_limit = EXCLUDED.file_size_limit;

-- storage.buckets has RLS enabled with no policy for `authenticated` by default, so a
-- SELECT policy is required for clients to read file_size_limit.
DROP POLICY IF EXISTS "Authenticated users can SELECT on buckets" ON storage.buckets;

CREATE POLICY "Authenticated users can SELECT on buckets" ON storage.buckets FOR SELECT TO authenticated
    USING (TRUE);

-- Column-level grant in case the role has no table-level SELECT grant on storage.buckets.
GRANT SELECT (id, name, file_size_limit) ON storage.buckets TO authenticated;
