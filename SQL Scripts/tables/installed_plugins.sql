CREATE TABLE installed_plugins
(
    id              uuid                                NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at      timestamp WITH TIME ZONE               DEFAULT NOW(),
    created_by      uuid REFERENCES public.profiles,
    updated_at      timestamptz,
    updated_by      uuid REFERENCES public.profiles,
    project_id      uuid REFERENCES public.projects     NOT NULL,
    plugin_name     VARCHAR NOT NULL,
    plugin_id       uuid NOT NULL,
    plugin_settings json
)

