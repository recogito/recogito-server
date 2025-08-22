alter type "public"."content_types_type" rename to "content_types_type__old_version_to_be_dropped";

create type "public"."content_types_type" as enum ('text/markdown', 'image/jpeg', 'image/tiff', 'image/png', 'image/gif', 'image/jp2', 'application/pdf', 'text/plain', 'application/tei+xml', 'application/xml');

alter table "public"."documents" alter column content_type type "public"."content_types_type" using content_type::text::"public"."content_types_type";

drop type "public"."content_types_type__old_version_to_be_dropped";

alter table "public"."default_groups" add column "is_admin" boolean default false;

alter table "public"."default_groups" add column "is_default" boolean default false;

alter table "public"."documents" alter column "content_type" drop not null;

alter table "public"."group_users" alter column "user_id" set not null;

CREATE UNIQUE INDEX group_users_group_id_user_id_idx ON public.group_users USING btree (group_id, user_id);

alter table "public"."group_users" add constraint "group_users_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) not valid;

alter table "public"."group_users" validate constraint "group_users_group_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_default_layer_groups()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    group_id     uuid;
    _role_id     uuid;
    _name        varchar;
    _description varchar;
    _is_admin    bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, _is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            group_id = uuid_generate_v4();
            INSERT INTO public.groups
                (id, role_id)
            VALUES (group_id, _role_id);
            INSERT INTO public.layer_groups
                (layer_id, group_id, name, description)
            VALUES (NEW.id, group_id, _name, _description);

            IF _is_admin AND NEW.created_by != NULL THEN
                INSERT INTO public.group_users (group_id, user_id) VALUES (group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$function$
;

CREATE OR REPLACE FUNCTION public.create_default_project_groups()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    group_id     uuid;
    _role_id     uuid;
    _name        varchar;
    _description varchar;
    _is_admin    bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, _is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            group_id = uuid_generate_v4();
            INSERT INTO public.groups
                (id, role_id)
            VALUES (group_id, _role_id);
            INSERT INTO public.project_groups
                (project_id, group_id, name, description)
            VALUES (NEW.id, group_id, _name, _description);

            IF _is_admin AND NEW.created_by != NULL THEN
                INSERT INTO public.group_users (group_id, user_id) VALUES (group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_storage_object()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
    DECLARE _type varchar;
        DECLARE _meta jsonb;
BEGIN
    _type = NEW.metadata->>'mimetype';
    _meta = NEW.name;
    RAISE LOG 'Metadata: %',_meta;
    RAISE LOG 'Type = %', _type;
    INSERT INTO public.documents (id, name, bucket_id, content_type)
    VALUES (NEW.id, NEW.name, NEW.bucket_id, CAST(_type AS public.content_types_type));
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER on_layer_created_create_groups AFTER INSERT ON public.layers FOR EACH ROW EXECUTE FUNCTION create_default_layer_groups();

CREATE TRIGGER on_project_created_create_groups AFTER INSERT ON public.projects FOR EACH ROW EXECUTE FUNCTION create_default_project_groups();


set check_function_bodies = off;
