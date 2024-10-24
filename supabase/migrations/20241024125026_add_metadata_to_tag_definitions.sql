alter table "public"."tag_definitions" add column "metadata" json not null default '{}'::json;


