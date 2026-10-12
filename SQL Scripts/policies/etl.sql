-- enable RLS on all recogito_etl tables, which were exposed to PostgREST without RLS, with an
-- org-admin-only policy. and revoke all anon access

REVOKE ALL ON ALL TABLES IN SCHEMA recogito_etl FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA recogito_etl FROM anon;
REVOKE ALL ON ALL ROUTINES IN SCHEMA recogito_etl FROM anon;
REVOKE USAGE ON SCHEMA recogito_etl FROM anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA recogito_etl REVOKE ALL ON TABLES FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA recogito_etl REVOKE ALL ON ROUTINES FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA recogito_etl REVOKE ALL ON SEQUENCES FROM anon;

ALTER TABLE recogito_etl.z_annotations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_annotations;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_annotations
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_bodies ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_bodies;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_bodies
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_context_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_context_documents;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_context_documents
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_context_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_context_users;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_context_users
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_contexts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_contexts;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_contexts
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_documents;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_documents
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_group_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_group_users;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_group_users
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_layer_contexts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_layer_contexts;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_layer_contexts
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_layer_groups ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_layer_groups;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_layer_groups
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_layers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_layers;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_layers
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_profiles;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_profiles
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_project_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_project_documents;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_project_documents
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_project_groups ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_project_groups;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_project_groups
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_projects ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_projects;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_projects
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_tag_definitions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_tag_definitions;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_tag_definitions
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_tags ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_tags;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_tags
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE recogito_etl.z_targets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable ALL access for organization admins" ON recogito_etl.z_targets;
CREATE POLICY "Enable ALL access for organization admins" ON recogito_etl.z_targets
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));
