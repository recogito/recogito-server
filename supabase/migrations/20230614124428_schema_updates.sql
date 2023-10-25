alter table "public"."group_users" drop constraint "group_users_group_id_fkey";

alter table "public"."layer_groups" drop constraint "layer_groups_group_id_fkey";

alter table "public"."organization_groups" drop constraint "organization_groups_group_id_fkey";

alter table "public"."project_groups" drop constraint "project_groups_group_id_fkey";

drop index if exists "public"."group_users_group_id_user_id_idx";

alter table "public"."group_users" drop column "group_id";

alter table "public"."group_users" add column "type_id" uuid not null;

alter table "public"."layer_groups" drop column "group_id";

alter table "public"."layer_groups" add column "role_id" uuid not null;

alter table "public"."organization_groups" drop column "group_id";

alter table "public"."organization_groups" add column "role_id" uuid not null;

alter table "public"."project_groups" drop column "group_id";

alter table "public"."project_groups" add column "role_id" uuid not null;

CREATE UNIQUE INDEX group_users_user_type_type_id_unique ON public.group_users USING btree (user_id, type_id, group_type);

alter table "public"."group_users" add constraint "group_users_user_type_type_id_unique" UNIQUE using index "group_users_user_type_type_id_unique";

alter table "public"."layer_groups" add constraint "layer_groups_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) not valid;

alter table "public"."layer_groups" validate constraint "layer_groups_role_id_fkey";

alter table "public"."organization_groups" add constraint "organization_groups_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) not valid;

alter table "public"."organization_groups" validate constraint "organization_groups_role_id_fkey";

alter table "public"."project_groups" add constraint "project_groups_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) not valid;

alter table "public"."project_groups" validate constraint "project_groups_role_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_action_policy_layer(user_id uuid, table_name character varying, operation operation_types, layer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.layer_groups pg ON pg.layer_id = $4
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'layer' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_organization(user_id uuid, table_name character varying, operation operation_types)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1
                  FROM public.organization_groups ag
                           INNER JOIN public.group_users gu
                                      ON ag.id = gu.type_id AND gu.group_type = 'organization' AND gu.user_id = $1
                           INNER JOIN public.roles r ON ag.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END ;
$function$
;

CREATE OR REPLACE FUNCTION public.check_action_policy_project(user_id uuid, table_name character varying, operation operation_types, project_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.project_groups pg ON pg.project_id = $4
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
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
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, _is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            _layer_group_id = uuid_generate_v4();
            INSERT INTO public.layer_groups
                (id, layer_id, role_id, name, description)
            VALUES (_layer_group_id, NEW.id, _role_id, _name, _description);

            IF _is_admin AND NEW.created_by != NULL THEN
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
    FOR _role_id, _name, _description, _is_admin IN SELECT role_id, name, description, _is_admin
                                                    FROM public.default_groups
                                                    WHERE group_type = 'project'
        LOOP
            _project_group_id = uuid_generate_v4();
            INSERT INTO public.project_groups
                (id, project_id, role_id, name, description)
            VALUES (_project_group_id, NEW.id, _role_id, _name, _description);

            IF _is_admin AND NEW.created_by != NULL THEN
                INSERT INTO public.group_users (group_type, type_id, user_id)
                VALUES ('project', _project_group_id, NEW.created_by);
            END IF;
        END LOOP;
    RETURN NEW;
END
$function$
;


