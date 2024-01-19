ALTER TABLE "public"."collections" ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.documents
ADD COLUMN IF NOT EXISTS collection_metadata json;
