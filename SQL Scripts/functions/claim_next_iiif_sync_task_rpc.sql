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
