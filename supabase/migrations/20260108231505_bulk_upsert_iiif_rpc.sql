create extension if not exists "pgaudit" with schema "extensions";

-- Function to bulk upsert documents from a JSON payload of IIIF manifests
set check_function_bodies = off;
CREATE OR REPLACE FUNCTION public.bulk_upsert_iiif_rpc(payload json)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO documents (name, collection_id, is_private, collection_metadata, meta_data)
  SELECT 
    (item->>'name'),
    (item->>'collection_id')::uuid,
    (item->>'is_private')::boolean,
    (item->'collection_metadata'),
    (item->'meta_data')
  FROM json_array_elements(payload) AS item
  ON CONFLICT (collection_id, (meta_data->>'url')) 
  DO UPDATE SET
    name = EXCLUDED.name,
    collection_metadata = EXCLUDED.collection_metadata,
    meta_data = EXCLUDED.meta_data;
END;
$function$
;

ALTER FUNCTION "public"."bulk_upsert_iiif_rpc" OWNER TO "postgres";
