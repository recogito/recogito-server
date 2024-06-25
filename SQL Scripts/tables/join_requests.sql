CREATE TABLE public.join_requests
(
    id               uuid    NOT NULL         DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at       timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by       uuid,
    updated_at       timestamptz,
    updated_by       uuid REFERENCES public.profiles,
    user_id          uuid NOT NULL,
    project_id       uuid REFERENCES public.projects,
    accepted         bool                     DEFAULT FALSE,
    ignored          bool                     DEFAULT FALSE
);