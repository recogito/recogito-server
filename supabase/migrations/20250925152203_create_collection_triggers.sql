DROP TRIGGER IF EXISTS "on_collection_created" ON "public"."collections";
CREATE TRIGGER "on_collection_created" BEFORE INSERT ON "public"."collections" FOR EACH ROW EXECUTE FUNCTION "public"."create_dates_and_user"();

DROP TRIGGER IF EXISTS "on_collection_updated" ON "public"."collections";
CREATE TRIGGER "on_collection_updated" BEFORE UPDATE ON "public"."collections" FOR EACH ROW EXECUTE FUNCTION "public"."update_dates_and_user"();
