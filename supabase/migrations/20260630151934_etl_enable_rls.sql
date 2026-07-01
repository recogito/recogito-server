-- enable RLS on all etl tables, which were exposed to PostgREST without RLS, with an
-- org-admin-only policy. and revoke all anon access

REVOKE ALL ON ALL TABLES IN SCHEMA etl FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA etl FROM anon;
REVOKE ALL ON ALL ROUTINES IN SCHEMA etl FROM anon;
REVOKE USAGE ON SCHEMA etl FROM anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA etl REVOKE ALL ON TABLES FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA etl REVOKE ALL ON ROUTINES FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA etl REVOKE ALL ON SEQUENCES FROM anon;

ALTER TABLE etl.z_annotations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_annotations
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_bodies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_bodies
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_context_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_context_documents
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_context_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_context_users
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_contexts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_contexts
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_documents
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_group_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_group_users
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_layer_contexts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_layer_contexts
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_layer_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_layer_groups
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_layers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_layers
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_profiles
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_project_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_project_documents
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_project_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_project_groups
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_projects
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_tag_definitions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_tag_definitions
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_tags
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));

ALTER TABLE etl.z_targets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable ALL access for organization admins" ON etl.z_targets
    FOR ALL TO authenticated
    USING (public.is_admin_organization(auth.uid()))
    WITH CHECK (public.is_admin_organization(auth.uid()));
