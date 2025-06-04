alter table "public"."documents" add column "document_group_id" uuid;

alter table "public"."documents" add column "is_document_group" boolean default false;


