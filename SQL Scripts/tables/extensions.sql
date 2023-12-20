-- extensions table --
CREATE TYPE activation_types AS ENUM('cron', 'direct_call');

CREATE TABLE public.documents (
    id uuid NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
    created_at timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by uuid REFERENCES public.profiles,
    updated_at timestamptz,
    updated_by uuid REFERENCES public.profiles,
    activation_type activation_types NOT NULL,
    metadata json
);
