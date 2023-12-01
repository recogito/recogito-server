alter type "public"."content_types_type" rename to "content_types_type__old_version_to_be_dropped";

create type "public"."content_types_type" as enum ('text/markdown', 'image/jpeg', 'image/tiff', 'image/png', 'image/gif', 'image/jp2', 'application/pdf', 'text/plain', 'application/tei+xml', 'application/xml', 'text/xml');

alter table "public"."documents" alter column content_type type "public"."content_types_type" using content_type::text::"public"."content_types_type";

drop type "public"."content_types_type__old_version_to_be_dropped";


