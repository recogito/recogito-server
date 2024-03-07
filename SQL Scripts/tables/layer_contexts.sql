CREATE TABLE public.layer_contexts
(
    id          uuid                                              NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE                                   DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                                                       DEFAULT FALSE,
    layer_id    uuid REFERENCES public.layers ON DELETE CASCADE   NOT NULL,
    context_id  uuid REFERENCES public.contexts ON DELETE CASCADE NOT NULL
);

-- Changes 6/9/23 --
ALTER TABLE public.layer_contexts
    DROP CONSTRAINT layer_contexts_context_id_fkey,
    ADD CONSTRAINT layer_contexts_context_id_fkey FOREIGN KEY (context_id) REFERENCES public.contexts
        ON DELETE CASCADE;

ALTER TABLE public.layer_contexts
    DROP CONSTRAINT layer_contexts_layer_id_fkey,
    ADD CONSTRAINT layer_contexts_layer_id_fkey FOREIGN KEY (layer_id) REFERENCES public.layers
        ON DELETE CASCADE;

-- Changes 7/26/23 --
ALTER TABLE public.layer_contexts
    ADD COLUMN is_archived bool DEFAULT FALSE;

-- Changes 3/6/24 --
ALTER TABLE public.layer_contexts
    ADD COLUMN is_active_layer BOOLEAN DEFAULT FALSE;
