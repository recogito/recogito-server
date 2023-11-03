CREATE TABLE public.project_documents
(
    id                uuid NOT NULL            DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at        timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by        uuid REFERENCES public.profiles,
    updated_at        timestamptz,
    updated_by        uuid REFERENCES public.profiles,
    is_archived       bool                     DEFAULT FALSE,
    project_id        uuid REFERENCES public.projects,
    document_id       uuid REFERENCES public.documents
);