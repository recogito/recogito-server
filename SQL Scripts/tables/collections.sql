CREATE TABLE public.collections (
    id uuid NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid REFERENCES public.profiles,
    updated_at timestamptz,
    updated_by uuid REFERENCES public.profiles,
    name varchar NOT NULL,
    extension_id uuid REFERENCES public.extensions,
    extension_metadata json
);