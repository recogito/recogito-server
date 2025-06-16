CREATE TYPE action_types AS ENUM ('INFO', 'ERROR');

CREATE TABLE public.notifications
(
    id               uuid    NOT NULL         DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at       timestamp WITH TIME ZONE DEFAULT NOW(),
    created_by       uuid,
    updated_at       timestamptz,
    updated_by       uuid REFERENCES public.profiles,
    target_user_id   uuid REFERENCES auth.users,
    message          varchar NOT NULL,
    action_url       varchar,
    action_message   varchar,
    message_type     action_types,
    is_acknowledged  boolean DEFAULT FALSE
);


-- Changes 6/16/25 --
ALTER TABLE public.notifications ADD COLUMN action_message varchar;

CREATE INDEX notifications_by_target_user ON public.notifications (target_user_id);