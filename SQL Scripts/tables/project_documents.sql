CREATE TABLE public.project_documents
(
    id                uuid NOT NULL            DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at        timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by        uuid REFERENCES public.profiles,
    updated_at        timestamptz,
    updated_by        uuid REFERENCES public.profiles,
    is_archived       bool                     DEFAULT FALSE,
    project_id        uuid REFERENCES public.projects,
    document_id       uuid REFERENCES public.documents,
    sort              integer                  DEFAULT 0
);

CREATE INDEX IF NOT EXISTS project_documents_project_id_idx ON public.project_documents USING btree (project_id);
CREATE INDEX IF NOT EXISTS project_documents_document_id_idx ON public.project_documents USING btree (document_id);