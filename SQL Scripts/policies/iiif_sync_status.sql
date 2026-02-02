DROP POLICY IF EXISTS "Service role has full access" ON public.iiif_sync_status;

CREATE POLICY "Service role has full access" ON "public"."iiif_sync_status" FOR ALL TO "service_role" USING (true) WITH CHECK (true);
