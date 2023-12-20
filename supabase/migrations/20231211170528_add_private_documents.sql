drop trigger if exists "on_document_updated" on "public"."documents";

drop policy "Users with correct policies can DELETE on documents" on "public"."documents";

drop policy "Users with correct policies can INSERT on documents" on "public"."documents";

drop policy "Users with correct policies can SELECT on documents" on "public"."documents";

drop policy "Users with correct policies can UPDATE on documents" on "public"."documents";

create table
    "public"."project_documents" (
        "id" uuid not null default uuid_generate_v4 (),
        "created_at" timestamp with time zone default now(),
        "created_by" uuid,
        "updated_at" timestamp with time zone,
        "updated_by" uuid,
        "is_archived" boolean default false,
        "project_id" uuid,
        "document_id" uuid
    );

alter table "public"."project_documents" enable row level security;

alter table "public"."documents"
add column "is_private" boolean default true;

CREATE UNIQUE INDEX project_documents_pkey ON public.project_documents USING btree (id);

alter table "public"."project_documents"
add constraint "project_documents_pkey" PRIMARY KEY using index "project_documents_pkey";

alter table "public"."project_documents"
add constraint "project_documents_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles (id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_created_by_fkey";

alter table "public"."project_documents"
add constraint "project_documents_document_id_fkey" FOREIGN KEY (document_id) REFERENCES documents (id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_document_id_fkey";

alter table "public"."project_documents"
add constraint "project_documents_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects (id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_project_id_fkey";

alter table "public"."project_documents"
add constraint "project_documents_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES profiles (id) not valid;

alter table "public"."project_documents" validate constraint "project_documents_updated_by_fkey";

set
    check_function_bodies = off;

CREATE
OR REPLACE FUNCTION public.update_document () RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $function$
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
$function$;

CREATE
OR REPLACE FUNCTION public.check_action_policy_project_from_document (
    user_id uuid,
    table_name character varying,
    operation operation_types,
    document_id uuid
) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $function$
BEGIN
    RETURN EXISTS(SELECT 1

                  FROM public.profiles pr
                           INNER JOIN public.project_documents pd ON pd.document_id = $4
                           INNER JOIN public.project_groups pg ON pg.project_id = pd.project_id
                           INNER JOIN public.group_users gu
                                      ON pg.id = gu.type_id AND gu.group_type = 'project' AND gu.user_id = $1
                           INNER JOIN public.roles r ON pg.role_id = r.id
                           INNER JOIN public.role_policies rp ON r.id = rp.role_id
                           INNER JOIN public.policies p ON rp.policy_id = p.id

                  WHERE p.table_name = $2
                    AND p.operation = $3);
END;
$function$;

create policy "Users with correct policies can DELETE on project_documents" on "public"."project_documents" as permissive for delete to authenticated using (
    (
        check_action_policy_organization (auth.uid (), 'project_documents'::character varying, 'DELETE'::operation_types)
        OR check_action_policy_project (
            auth.uid (),
            'project_documents'::character varying,
            'DELETE'::operation_types,
            project_id
        )
    )
);

create policy "Users with correct policies can INSERT on project_documents" on "public"."project_documents" as permissive for insert to authenticated
with
    check (
        (
            check_action_policy_organization (auth.uid (), 'project_documents'::character varying, 'INSERT'::operation_types)
            OR check_action_policy_project (
                auth.uid (),
                'project_documents'::character varying,
                'INSERT'::operation_types,
                project_id
            )
        )
    );

create policy "Users with correct policies can SELECT on project_documents" on "public"."project_documents" as permissive for
select
    to authenticated using (
        (
            (is_archived IS FALSE)
            AND (
                check_action_policy_organization (auth.uid (), 'project_documents'::character varying, 'SELECT'::operation_types)
                OR check_action_policy_project (
                    auth.uid (),
                    'project_documents'::character varying,
                    'SELECT'::operation_types,
                    project_id
                )
            )
        )
    );

create policy "Users with correct policies can UPDATE on project_documents" on "public"."project_documents" as permissive
for update
    to authenticated using (
        (
            check_action_policy_organization (auth.uid (), 'project_documents'::character varying, 'UPDATE'::operation_types)
            OR check_action_policy_project (
                auth.uid (),
                'project_documents'::character varying,
                'UPDATE'::operation_types,
                project_id
            )
        )
    )
with
    check (
        (
            check_action_policy_organization (auth.uid (), 'project_documents'::character varying, 'UPDATE'::operation_types)
            OR check_action_policy_project (
                auth.uid (),
                'project_documents'::character varying,
                'UPDATE'::operation_types,
                project_id
            )
        )
    );

create policy "Users with correct policies can DELETE on documents" on "public"."documents" as permissive for delete to authenticated using (
    (
        (
            (
                (is_private = false)
                OR (created_by = auth.uid ())
            )
            AND check_action_policy_organization (auth.uid (), 'documents'::character varying, 'DELETE'::operation_types)
        )
        OR check_action_policy_project_from_document (auth.uid (), 'documents'::character varying, 'DELETE'::operation_types, id)
        OR check_action_policy_layer_from_document (auth.uid (), 'documents'::character varying, 'DELETE'::operation_types, id)
    )
);

create policy "Users with correct policies can INSERT on documents" on "public"."documents" as permissive for insert to authenticated
with
    check (
        (
            (
                (
                    (is_private = false)
                    OR (created_by = auth.uid ())
                )
                AND check_action_policy_organization (auth.uid (), 'documents'::character varying, 'INSERT'::operation_types)
            )
            OR check_action_policy_project_from_document (auth.uid (), 'documents'::character varying, 'INSERT'::operation_types, id)
            OR check_action_policy_layer_from_document (auth.uid (), 'documents'::character varying, 'INSERT'::operation_types, id)
        )
    );

create policy "Users with correct policies can SELECT on documents" on "public"."documents" as permissive for
select
    to authenticated using (
        (
            (is_archived IS FALSE)
            AND (
                (
                    (
                        (is_private = false)
                        OR (created_by = auth.uid ())
                    )
                    AND check_action_policy_organization (auth.uid (), 'documents'::character varying, 'SELECT'::operation_types)
                )
                OR check_action_policy_project_from_document (auth.uid (), 'documents'::character varying, 'SELECT'::operation_types, id)
                OR check_action_policy_layer_from_document (auth.uid (), 'documents'::character varying, 'SELECT'::operation_types, id)
            )
        )
    );

create policy "Users with correct policies can UPDATE on documents" on "public"."documents" as permissive
for update
    to authenticated using (
        (
            (
                (
                    (is_private = false)
                    OR (created_by = auth.uid ())
                )
                AND check_action_policy_organization (auth.uid (), 'documents'::character varying, 'UPDATE'::operation_types)
            )
            OR check_action_policy_project_from_document (auth.uid (), 'documents'::character varying, 'UPDATE'::operation_types, id)
            OR check_action_policy_layer_from_document (auth.uid (), 'documents'::character varying, 'UPDATE'::operation_types, id)
        )
    )
with
    check (
        (
            (
                (
                    (is_private = false)
                    OR (created_by = auth.uid ())
                )
                AND check_action_policy_organization (auth.uid (), 'documents'::character varying, 'UPDATE'::operation_types)
            )
            OR check_action_policy_project_from_document (auth.uid (), 'documents'::character varying, 'UPDATE'::operation_types, id)
            OR check_action_policy_layer_from_document (auth.uid (), 'documents'::character varying, 'UPDATE'::operation_types, id)
        )
    );

CREATE TRIGGER on_project_document_created BEFORE INSERT ON public.project_documents FOR EACH ROW
EXECUTE FUNCTION create_dates_and_user ();

CREATE TRIGGER on_project_document_updated BEFORE INSERT ON public.project_documents FOR EACH ROW
EXECUTE FUNCTION update_dates_and_user ();

CREATE TRIGGER on_document_updated BEFORE
UPDATE ON public.documents FOR EACH ROW
EXECUTE FUNCTION update_document ();

DO $$
DECLARE
  t_row public.layers % rowtype;
BEGIN
  FOR t_row IN SELECT * FROM public.layers LOOP
    IF NOT EXISTS(
    SELECT 1
    FROM public.project_documents
    WHERE project_id = t_row.project_id
    AND document_id = t_row.document_id
  ) THEN
      INSERT INTO public.project_documents (project_id, document_id)
      VALUES (
        t_row.project_id,
        t_row.document_id
      );
    END IF;
  END LOOP;
END
$$
