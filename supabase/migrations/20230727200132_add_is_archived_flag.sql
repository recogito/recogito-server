--drop policy "Users with correct policies can DELETE on projects" on "public"."project_groups";

drop policy "Users with correct policies can SELECT on annotations" on "public"."annotations";

drop policy "Users with correct policies can SELECT on bodies" on "public"."bodies";

drop policy "Users with correct policies can SELECT on contexts" on "public"."contexts";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on layer_contexts" on "public"."layer_contexts";

drop policy "Users with correct policies can SELECT on layers" on "public"."layers";

--drop policy "Users with correct policies can SELECT on organization_groups" on "public"."organization_groups";

drop policy "Users with correct policies can SELECT on project_groups" on "public"."project_groups";

drop policy "Users with correct policies can SELECT on projects" on "public"."projects";

drop policy "Users with correct policies can SELECT on targets" on "public"."targets";

alter table "public"."annotations" add column "is_archived" boolean default false;

alter table "public"."bodies" add column "is_archived" boolean default false;

alter table "public"."contexts" add column "is_archived" boolean default false;

alter table "public"."default_groups" add column "is_archived" boolean default false;

alter table "public"."documents" add column "is_archived" boolean default false;

alter table "public"."group_users" add column "is_archived" boolean default false;

alter table "public"."groups" add column "is_archived" boolean default false;

alter table "public"."invites" add column "is_archived" boolean default false;

alter table "public"."layer_contexts" add column "is_archived" boolean default false;

alter table "public"."layer_groups" add column "is_archived" boolean default false;

alter table "public"."layers" add column "is_archived" boolean default false;

alter table "public"."organization_groups" add column "is_archived" boolean default false;

alter table "public"."policies" add column "is_archived" boolean default false;

alter table "public"."profiles" add column "is_archived" boolean default false;

alter table "public"."project_groups" add column "is_archived" boolean default false;

alter table "public"."projects" add column "is_archived" boolean default false;

alter table "public"."role_policies" add column "is_archived" boolean default false;

alter table "public"."roles" add column "is_archived" boolean default false;

alter table "public"."tag_definitions" add column "is_archived" boolean default false;

alter table "public"."tags" add column "is_archived" boolean default false;

alter table "public"."targets" add column "is_archived" boolean default false;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.archive_record_rpc(_table_name text, _id uuid)
 RETURNS record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    _row RECORD;
BEGIN
    IF _table_name = 'annotations' THEN
        SELECT * INTO _row FROM public.annotations WHERE id = _id;
        IF (public.check_for_private_annotation(auth.uid(), _row.id) AND (
                public.check_action_policy_organization(auth.uid(), 'annotations', 'SELECT') OR
                public.check_action_policy_project_from_layer(auth.uid(), 'annotations', 'SELECT', _row.layer_id) OR
                public.check_action_policy_layer(auth.uid(), 'annotations', 'SELECT', _row.layer_id)
            )) THEN
            UPDATE public.annotations SET is_archived = TRUE WHERE id = _id;
            RETURN _row;
        END IF;
    ELSE
        IF _table_name = 'projects' THEN
            SELECT * INTO _row FROM public.projects WHERE id = _id;
            IF (public.check_action_policy_organization(auth.uid(), 'projects', 'UPDATE') OR
                public.check_action_policy_project(auth.uid(), 'projects', 'UPDATE', _row.id)
                ) THEN
                UPDATE public.projects SET is_archived = TRUE WHERE id = _id;
                RETURN _row;
            END IF;
        ELSE
            IF _table_name = 'contexts' THEN
                SELECT * INTO _row FROM public.contexts WHERE id = _id;
                IF (public.check_action_policy_organization(auth.uid(), 'contexts', 'UPDATE') OR
                    public.check_action_policy_project(auth.uid(), 'contexts', 'UPDATE', _row.project_id)) THEN
                    UPDATE public.contexts SET is_archived = TRUE WHERE id = _id;
                    RETURN _row;
                END IF;
            ELSE
                IF _table_name = 'layers' THEN
                    SELECT * INTO _row FROM public.layers WHERE id = _id;
                    IF (public.check_action_policy_organization(auth.uid(), 'layers', 'UPDATE') OR
                        public.check_action_policy_project(auth.uid(), 'layers', 'UPDATE', _row.project_id) OR
                        public.check_action_policy_layer(auth.uid(), 'layers', 'UPDATE', _row.id)) THEN
                        UPDATE public.layers SET is_archived = TRUE WHERE id = _id;
                        RETURN _row;
                    END IF;
                ELSE
                    IF _table_name = 'bodies' THEN
                        SELECT * INTO _row FROM public.bodies WHERE id = _id;
                        IF (
                                    public.check_for_private_annotation(auth.uid(), _row.annotation_id) AND (
                                    (public.check_for_creating_user(auth.uid(), _row.annotation_id) AND
                                     public.check_action_policy_layer(auth.uid(), 'bodies', 'UPDATE',
                                                                      _row.layer_id))) OR
                                    (public.check_action_policy_organization(auth.uid(), 'bodies', 'UPDATE') OR
                                     public.check_action_policy_project_from_layer(auth.uid(), 'bodies', 'UPDATE',
                                                                                   _row.layer_id))
                            ) THEN
                            UPDATE public.layers SET is_archived = TRUE WHERE id = _id;
                            RETURN _row;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END ;
$function$
;

CREATE OR REPLACE FUNCTION public.check_archive_annotation()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.bodies AS b SET is_archived = TRUE WHERE b.annotation_id = OLD.id;
        UPDATE public.targets AS t SET is_archived = TRUE WHERE t.annotation_id = OLD.id;
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_archive_context()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.layer_contexts AS l SET is_archived = TRUE WHERE l.context_id = OLD.id;
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_archive_layer()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.annotations AS a SET is_archived = TRUE WHERE a.layer_id = OLD.id;
        UPDATE public.layer_contexts AS l SET is_archived = TRUE WHERE l.layer_id = OLD.id;
        UPDATE public.layer_groups AS g SET is_archived = TRUE WHERE g.layer_id = OLD.id;
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_archive_project()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.is_archived IS TRUE THEN
        UPDATE public.contexts AS c SET is_archived = TRUE WHERE c.project_id = OLD.id;
        UPDATE public.invites AS i SET is_archived = TRUE WHERE i.project_id = OLD.id;
        UPDATE public.layers AS l SET is_archived = TRUE WHERE l.project_id = OLD.id;
        UPDATE public.project_groups AS p SET is_archived = TRUE WHERE p.project_id = OLD.id;
    END IF;
    RETURN NEW;
END;
$function$
;

create policy "Users with correct policies can SELECT on annotations"
on "public"."annotations"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_for_private_annotation(auth.uid(), id) AND (check_action_policy_organization(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'annotations'::character varying, 'SELECT'::operation_types, layer_id))));


create policy "Users with correct policies can SELECT on bodies"
on "public"."bodies"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'bodies'::character varying, 'SELECT'::operation_types, layer_id))));


create policy "Users with correct policies can SELECT on contexts"
on "public"."contexts"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'contexts'::character varying, 'SELECT'::operation_types, project_id))));


create policy "Users with correct policies can SELECT on documents"
on "public"."documents"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id) OR check_action_policy_layer_from_document(auth.uid(), 'documents'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can SELECT on layer_contexts"
on "public"."layer_contexts"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_context(auth.uid(), 'layer_contexts'::character varying, 'SELECT'::operation_types, context_id))));


create policy "Users with correct policies can SELECT on layers"
on "public"."layers"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types, project_id) OR check_action_policy_layer(auth.uid(), 'layers'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can SELECT on organization_groups"
on "public"."organization_groups"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND check_action_policy_organization(auth.uid(), 'organization_groups'::character varying, 'SELECT'::operation_types)));


create policy "Users with correct policies can SELECT on project_groups"
on "public"."project_groups"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'project_groups'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'project_groups'::character varying, 'SELECT'::operation_types, project_id))));


create policy "Users with correct policies can SELECT on projects"
on "public"."projects"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_action_policy_organization(auth.uid(), 'projects'::character varying, 'SELECT'::operation_types) OR check_action_policy_project(auth.uid(), 'projects'::character varying, 'SELECT'::operation_types, id))));


create policy "Users with correct policies can SELECT on targets"
on "public"."targets"
as permissive
for select
to authenticated
using (((is_archived IS FALSE) AND (check_for_private_annotation(auth.uid(), annotation_id) AND (check_action_policy_organization(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types) OR check_action_policy_project_from_layer(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types, layer_id) OR check_action_policy_layer(auth.uid(), 'targets'::character varying, 'SELECT'::operation_types, layer_id)))));


CREATE TRIGGER on_annotation_updated_check_archive BEFORE UPDATE ON public.annotations FOR EACH ROW EXECUTE FUNCTION check_archive_annotation();

CREATE TRIGGER on_context_updated_check_archive BEFORE UPDATE ON public.contexts FOR EACH ROW EXECUTE FUNCTION check_archive_context();

CREATE TRIGGER on_layer_updated_check_archive BEFORE UPDATE ON public.layers FOR EACH ROW EXECUTE FUNCTION check_archive_layer();

CREATE TRIGGER on_project_updated_check_archive BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION check_archive_project();


