-- IIIF sync status table to track progress syncing multiple large
-- collections of IIIF manifests from Google Sheets via AWS/DO. Essentially,
-- a highly simplified PSQL-backed job queue.

CREATE TABLE public.iiif_sync_status (
    id              uuid                        DEFAULT extensions.uuid_generate_v4()   NOT NULL,
    created_at      timestamp with time zone    DEFAULT now(),
    collection_id   uuid,
    iiif_url        text                        NOT NULL,
    chunk_index     integer                     NOT NULL,
    status          public.job_statuses         DEFAULT 'INITIALIZING'::public.job_statuses,
    error           text,
    attempt_count   integer                     DEFAULT 0
);

-- Only grant permissions to service_role, this table is only used internally.

ALTER TABLE "public"."iiif_sync_status" ENABLE ROW LEVEL SECURITY;

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
