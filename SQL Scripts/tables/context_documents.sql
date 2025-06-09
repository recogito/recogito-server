CREATE TABLE context_documents(
    id            uuid                          NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at    timestamp WITH TIME ZONE               DEFAULT NOW(),
    created_by    uuid REFERENCES public.profiles,
    updated_at    timestamptz,
    updated_by    uuid REFERENCES public.profiles,
    context_id    uuid REFERENCES public.contexts,
    document_id   uuid REFERENCES public.documents,
    is_archived   BOOLEAN DEFAULT FALSE,
    sort          INT DEFAULT 0
);

-- Changes 3/7/24 --
ALTER TABLE public.context_documents
    ADD UNIQUE (context_id, document_id); 

-- Changes 6/9/25 --
ALTER TABLE public.context_documents
    ADD COLUMN sort INT DEFAULT 0;