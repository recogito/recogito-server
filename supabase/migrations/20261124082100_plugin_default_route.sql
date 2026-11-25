ALTER TABLE installed_plugins
    ADD COLUMN IF NOT EXISTS provides_default_route boolean NOT NULL DEFAULT false;

CREATE UNIQUE INDEX IF NOT EXISTS installed_plugins_one_default_route_per_project
    ON installed_plugins (project_id)
    WHERE provides_default_route;