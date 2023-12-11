create extension if not exists "pg_cron" with schema "extensions";


drop trigger if exists "on_document_updated" on "public"."documents";

drop policy "Users with correct policies can DELETE on invites" on "public"."invites";

drop policy "Users with correct policies can INSERT on invites" on "public"."invites";

drop policy "Users with correct policies can SELECT on invites" on "public"."invites";

drop policy "Users with correct policies can UPDATE on invites" on "public"."invites";

drop policy "Users with correct policies can DELETE on tag_definitions" on "public"."tag_definitions";

drop policy "Users with correct policies can INSERT on tag_definitions" on "public"."tag_definitions";

drop policy "Users with correct policies can SELECT on tag_definitions" on "public"."tag_definitions";

drop policy "Users with correct policies can UPDATE on tag_definitions" on "public"."tag_definitions";

drop policy "Users with correct policies can DELETE on tags" on "public"."tags";

drop policy "Users with correct policies can INSERT on tags" on "public"."tags";

drop policy "Users with correct policies can SELECT on tags" on "public"."tags";

drop policy "Users with correct policies can UPDATE on tags" on "public"."tags";

drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

drop function if exists "public"."add_user_to_org_default"(user_id uuid);

drop function if exists "public"."check_action_policy_project_from_tag_definition"(user_id uuid, table_name character varying, operation operation_types, tag_definition_id uuid);

drop table "public"."_id";

alter type "public"."body_formats" rename to "body_formats__old_version_to_be_dropped";

create type "public"."body_formats" as enum ('TextPlain', 'TextHtml');

alter table "public"."bodies" alter column format type "public"."body_formats" using format::text::"public"."body_formats";

drop type "public"."body_formats__old_version_to_be_dropped";

alter table "public"."documents" add column "is_private" boolean default true;

alter table "public"."layer_groups" drop column "is_default";

alter table "public"."organization_groups" drop column "is_default";

alter table "public"."project_groups" drop column "is_default";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_document()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    -- These should never change --
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    IF NEW.is_private = TRUE AND auth.uid() != OLD.created_by THEN
        NEW.is_private = FALSE;
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_default_layer_groups()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _layer_group_id uuid;
    _role_id        uuid;
    _name           varchar;
    _description    varchar;
    _is_admin       bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'layer'
        LOOP
            _layer_group_id = extensions.uuid_generate_v4();
            INSERT INTO public.layer_groups
                (id, layer_id, role_id, name, description, is_admin)
            VALUES (_layer_group_id, NEW.id, _role_id, _name, _description, _is_admin);

            IF _is_admin IS TRUE AND NEW.created_by IS NOT NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('layer', _layer_group_id, NEW.created_by);
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
    _project_group_id uuid;
    _role_id          uuid;
    _name             varchar;
    _description      varchar;
    _is_admin         bool;
BEGIN
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            _project_group_id = extensions.uuid_generate_v4();
            INSERT INTO public.project_groups
                (id, project_id, role_id, name, description, is_admin)
            VALUES (_project_group_id, NEW.id, _role_id, _name, _description, _is_admin);

            IF _is_admin IS TRUE AND NEW.created_by IS NOT NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('project', _project_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email);
    RETURN new;
END;
$function$
;

create policy "Enable All access for authentocated users"
on "public"."invites"
as permissive
for all
to authenticated
using (true)
with check (true);


create policy "Enable All access for authenticated users"
on "public"."tag_definitions"
as permissive
for all
to authenticated
using (true)
with check (true);


create policy "Enable All access for authenticated users"
on "public"."tags"
as permissive
for all
to authenticated
using (true)
with check (true);


create policy "Users with correct policies can DELETE on documents"
on "public"."documents"
as permissive
for delete
to authenticated
using (((((is_private = false) OR (created_by = auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'DELETE'::operation_types, id)));


create policy "Users with correct policies can INSERT on documents"
on "public"."documents"
as permissive
for insert
to authenticated
with check (((((is_private = false) OR (created_by = auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'INSERT'::operation_types, id)));


create policy "Users with correct policies can SELECT on documents"
on "public"."documents"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND ((((is_private = false) OR (created_by = auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can UPDATE on documents"
on "public"."documents"
as permissive
for update
to authenticated
using (((((is_private = false) OR (created_by = auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id)))
with check (((((is_private = false) OR (created_by = auth.uid())) AND check_action_policy_organization(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types)) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'UPDATE'::operation_types, id)));


CREATE TRIGGER on_document_updated BEFORE UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION update_document();


