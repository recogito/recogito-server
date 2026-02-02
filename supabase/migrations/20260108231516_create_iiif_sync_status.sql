-- Create a IIIF sync status table to track progress syncing multiple large
-- collections of IIIF manifests from Google Sheets via AWS/DO. Essentially,
-- a highly simplified PSQL-backed job queue.

CREATE TABLE IF NOT EXISTS "public"."iiif_sync_status" (
    "id" uuid NOT NULL default uuid_generate_v4() PRIMARY KEY,
    "created_at" timestamp with time zone default now(),
    "collection_id" uuid REFERENCES collections(id) ON DELETE CASCADE,
    "iiif_url" text NOT NULL,
    "chunk_index" int NOT NULL,
    "status" job_statuses default 'INITIALIZING',
    "error" text,
    "attempt_count" int default 0
);

-- Only grant permissions to service_role, this table is only used internally.

ALTER TABLE "public"."iiif_sync_status" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role has full access" ON "public"."iiif_sync_status" FOR ALL TO "service_role" USING (true) WITH CHECK (true);

revoke all on table "public"."iiif_sync_status" from "anon";

revoke all on table "public"."iiif_sync_status" from "authenticated";

grant delete on table "public"."iiif_sync_status" to "service_role";

grant insert on table "public"."iiif_sync_status" to "service_role";

grant references on table "public"."iiif_sync_status" to "service_role";

grant select on table "public"."iiif_sync_status" to "service_role";

grant trigger on table "public"."iiif_sync_status" to "service_role";

grant truncate on table "public"."iiif_sync_status" to "service_role";

grant update on table "public"."iiif_sync_status" to "service_role";


-- Index for the edge function to efficiently claim the next task
CREATE INDEX IF NOT EXISTS "idx_iiif_sync_status_pending" ON "public"."iiif_sync_status" (status) WHERE status = 'INITIALIZING';

-- Unique index on collection+chunk so that upsert will not produce extra task rows
CREATE UNIQUE INDEX IF NOT EXISTS "uniq_iiif_collection_chunk" ON "public"."iiif_sync_status" (collection_id, chunk_index);

-- RPC that grabs IIIF sync task and updates its status and attempt count

CREATE
    OR REPLACE FUNCTION claim_next_iiif_sync_task_rpc()
    RETURNS SETOF iiif_sync_status AS $body$
BEGIN
  RETURN QUERY
  UPDATE iiif_sync_status
  SET status = 'PROCESSING', attempt_count = attempt_count + 1
  WHERE id = (
    SELECT id
    FROM iiif_sync_status
    WHERE status = 'INITIALIZING'
    ORDER BY created_at
    LIMIT 1
    FOR UPDATE SKIP LOCKED -- Prevent race condition; see https://www.netdata.cloud/academy/update-skip-locked/
  )
  RETURNING *;
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER;
