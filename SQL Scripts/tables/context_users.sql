CREATE TABLE context_users(
    id            uuid                          NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at    timestamp WITH TIME ZONE               DEFAULT NOW(),
    created_by    uuid REFERENCES public.profiles,
    updated_at    timestamptz,
    updated_by    uuid REFERENCES public.profiles,
    context_id    uuid REFERENCES public.contexts,
    user_id       uuid REFERENCES public.profiles,
    role_id       uuid REFERENCES public.roles
);

-- Changes 3/7/24 --
ALTER TABLE public.context_users
    ADD UNIQUE (context_id, user_id); 