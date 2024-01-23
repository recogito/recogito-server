create type "public"."target_type_types" as enum ('profiles_table', 'org_group_override');

create table "public"."attribute_mapping" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_at" timestamp with time zone,
    "updated_by" uuid,
    "saml_attribute_name" character varying not null,
    "custom_claim" character varying not null,
    "target_type" target_type_types not null,
    "target_attribute" character varying,
    "attribute_value_mapping" json
);


alter table "public"."attribute_mapping" enable row level security;

alter table "public"."profiles" add column "user_meta_data" json;

CREATE UNIQUE INDEX attribute_mapping_pkey ON public.attribute_mapping USING btree (id);

alter table "public"."attribute_mapping" add constraint "attribute_mapping_pkey" PRIMARY KEY using index "attribute_mapping_pkey";

alter table "public"."attribute_mapping" add constraint "attribute_mapping_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) not valid;

alter table "public"."attribute_mapping" validate constraint "attribute_mapping_created_by_fkey";

alter table "public"."attribute_mapping" add constraint "attribute_mapping_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles(id) not valid;

alter table "public"."attribute_mapping" validate constraint "attribute_mapping_updated_by_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_custom_attributes()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  t_row public.attribute_mapping%rowtype;
  _result BOOLEAN;
BEGIN 
  FOR t_row IN SELECT * FROM public.attribute_mapping LOOP
    IF t_row.target_type = 'table' THEN
      EXECUTE format('UPDATE %I t
      SET %I = NEW.raw_user_meta_data->>%I
      WHERE t.%I = NEW.id', t_row.target_table, t_row.target_attribute,t_row.custom_claim, t.target_table_user_id);
    ELSIF t_row.target_type = 'org_group_override' THEN
      IF EXECUTE 't_row.attribute_value_mapping ->> ' || NEW.raw_user_meta_data->> t_row.custom_claim  || 'IS NOT NULL'  THEN
        EXECUTE format('UPDATE public.group_users g
        SET type_id = t_row.attribute_value_mapping ->> %I
        WHERE g.user_id = NEW.id', NEW.raw_user_meta_data->>t_row.custom_claim);
      END IF;
    END IF;
  END LOOP;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _id UUID;
    t_row public.attribute_mapping%rowtype;
    _first_name VARCHAR;
    _last_name VARCHAR;
    _nickname VARCHAR;
    _org_group_id uuid;
BEGIN
    FOR t_row IN SELECT * FROM public.attribute_mapping LOOP
        IF t_row.target_type = 'profiles_table' THEN
            EXECUTE '_' || t_row.target_attribute|| ' := ' || NEW.raw_user_meta_data || '::json ->> ' ||  '''' || t_row.custom_claim || '''';
        ELSIF t_row.target_type = 'org_group_override' THEN
            EXECUTE '_org_group_id := ' || NEW.raw_user_meta_data || '::json ->> ' || '''' ||  t_row.custom_claim || '''';
        END IF;
    END LOOP;
    IF _org_group_id IS NULL THEN
        IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE) THEN
            SELECT id INTO _org_group_id FROM public.organization_groups WHERE  is_default = TRUE;
        END IF;
    END IF;

    INSERT INTO public.profiles (id, email, first_name, last_name, nickname)
    VALUES (NEW.id, NEW.email, _first_name, _last_name, _nickname);

    IF _org_group_id IS NOT NULL THEN
        INSERT INTO public.group_users (user_id, group_type, type_id) VALUES (NEW.id, 'organization', _org_group_id);
    END IF;
   
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    UPDATE public.profiles
    SET email = NEW.email, user_meta_data = NEW.raw_user_meta_data
    WHERE id = NEW.id;
        RETURN new;
END;
$function$
;


