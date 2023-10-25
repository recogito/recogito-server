create type "public"."content_types_type" as enum ('text', 'iiif', 'tei');

alter table "public"."layers" drop constraint "layers_context_id_fkey";

create table "public"."layer_contexts" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "layer_id" uuid not null,
    "context_id" uuid not null
);


alter table "public"."annotations" add column "is_private" boolean default false;

alter table "public"."annotations" alter column "layer_id" set not null;

alter table "public"."bodies" alter column "layer_id" set not null;

alter table "public"."documents" add column "content_type" content_types_type not null;

alter table "public"."layers" drop column "context_id";

alter table "public"."targets" alter column "layer_id" set not null;

CREATE UNIQUE INDEX layer_contexts_pkey ON public.layer_contexts USING btree (id);

alter table "public"."layer_contexts" add constraint "layer_contexts_pkey" PRIMARY KEY using index "layer_contexts_pkey";

alter table "public"."layer_contexts" add constraint "layer_contexts_context_id_fkey" FOREIGN KEY (context_id) REFERENCES contexts(id) not valid;

alter table "public"."layer_contexts" validate constraint "layer_contexts_context_id_fkey";

alter table "public"."layer_contexts" add constraint "layer_contexts_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."layer_contexts" validate constraint "layer_contexts_created_by_fkey";

alter table "public"."layer_contexts" add constraint "layer_contexts_layer_id_fkey" FOREIGN KEY (layer_id) REFERENCES layers(id) not valid;

alter table "public"."layer_contexts" validate constraint "layer_contexts_layer_id_fkey";

alter table "public"."layer_contexts" add constraint "layer_contexts_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."layer_contexts" validate constraint "layer_contexts_updated_by_fkey";

CREATE TRIGGER on_layer_context_created BEFORE INSERT ON public.layer_contexts FOR EACH ROW EXECUTE FUNCTION create_dates_and_user();

CREATE TRIGGER on_layer_context_updated BEFORE UPDATE ON public.layer_contexts FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();


