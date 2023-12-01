CREATE UNIQUE INDEX role_id_unique ON public.organization_groups USING btree (role_id);

alter table "public"."organization_groups" add constraint "role_id_unique" UNIQUE using index "role_id_unique";


