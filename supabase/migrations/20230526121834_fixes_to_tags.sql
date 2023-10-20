alter type "public"."tag_scope_types" rename to "tag_scope_types__old_version_to_be_dropped";

create type "public"."tag_scope_types" as enum ('system', 'organization', 'project');

alter table "public"."tag_definitions" alter column scope type "public"."tag_scope_types" using scope::text::"public"."tag_scope_types";

alter table "public"."tag_definitions" alter column "target_type" drop not null;

alter table "public"."tag_definitions" alter column "target_type" set data type tag_target_types using "target_type"::text::tag_target_types;

drop type "public"."tag_scope_types__old_version_to_be_dropped";


