-- Index the foreign-key columns on public.project_documents. Postgres does not
-- create these automatically, so filtering the table by project_id (e.g. the
-- project export's documents query) was doing a sequential scan and hitting the
-- statement timeout. Btree indexes turn those into index scans.

CREATE INDEX IF NOT EXISTS project_documents_project_id_idx ON public.project_documents USING btree (project_id);
CREATE INDEX IF NOT EXISTS project_documents_document_id_idx ON public.project_documents USING btree (document_id);
