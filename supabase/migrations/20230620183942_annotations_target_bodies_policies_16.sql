alter table "public"."documents" add column "meta_data" json not null default '{}'::json;


drop trigger if exists "on_storage_object_created" on "storage"."objects";

drop trigger if exists "on_storage_object_deleted" on "storage"."objects";


