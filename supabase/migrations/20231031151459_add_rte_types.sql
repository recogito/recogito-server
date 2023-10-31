create type "public"."render_type_types" as enum ('text', 'lexical');

alter table "public"."bodies" add column "render_type" render_type_types default 'text'::render_type_types;


