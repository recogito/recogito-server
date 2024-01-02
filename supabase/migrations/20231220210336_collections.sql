create type "public"."activation_types" as enum ('cron', 'direct_call');

create table "public"."collections" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "name" character varying not null,
    "extension_id" uuid,
    "extension_metadata" json
);


alter table "public"."collections" enable row level security;

create table "public"."extensions" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "activation_type" activation_types not null,
    "metadata" json
);


alter table "public"."extensions" enable row level security;

alter table "public"."documents" add column "collection_id" uuid;

alter table "public"."documents" add column "collection_metadata" json;

CREATE UNIQUE INDEX collections_pkey ON public.collections USING btree (id);

CREATE UNIQUE INDEX extensions_pkey ON public.extensions USING btree (id);

alter table "public"."collections" add constraint "collections_pkey" PRIMARY KEY using index "collections_pkey";

alter table "public"."extensions" add constraint "extensions_pkey" PRIMARY KEY using index "extensions_pkey";

alter table "public"."collections" add constraint "collections_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."collections" validate constraint "collections_created_by_fkey";

alter table "public"."collections" add constraint "collections_extension_id_fkey" FOREIGN KEY (extension_id) REFERENCES extensions(id) not valid;

alter table "public"."collections" validate constraint "collections_extension_id_fkey";

alter table "public"."collections" add constraint "collections_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."collections" validate constraint "collections_updated_by_fkey";

alter table "public"."documents" add constraint "documents_collection_id_fkey" FOREIGN KEY (collection_id) REFERENCES collections(id) not valid;

alter table "public"."documents" validate constraint "documents_collection_id_fkey";

alter table "public"."extensions" add constraint "extensions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."extensions" validate constraint "extensions_created_by_fkey";

alter table "public"."extensions" add constraint "extensions_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."extensions" validate constraint "extensions_updated_by_fkey";


