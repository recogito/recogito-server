-- annotations table --
CREATE TABLE annotations
(
    id          uuid                                            NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at  timestamp WITH TIME ZONE                                 DEFAULT NOW(),
    created_by  uuid REFERENCES public.profiles,
    updated_at  timestamptz,
    updated_by  uuid REFERENCES public.profiles,
    is_archived bool                                                     DEFAULT FALSE,
    version     int4 GENERATED ALWAYS AS IDENTITY (START WITH 1),
    layer_id    uuid REFERENCES public.layers ON DELETE CASCADE NOT NULL,
    is_private  bool                                                     DEFAULT FALSE
);

-- changes 4/12/23 --
ALTER TABLE public.annotations
    ADD COLUMN assignment_id uuid REFERENCES public.assignments;

-- changes 5/1/23 ---
ALTER TABLE public.annotations
    RENAME COLUMN assignment_id TO context_id;

-- changes 5/23/23 --
ALTER TABLE public.annotations
    DROP COLUMN context_id;

ALTER TABLE public.annotations
    ADD COLUMN layer_id uuid REFERENCES public.layers;

ALTER TABLE public.annotations
    ADD CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES public.profiles (id);

-- changes 6/6/23 --
ALTER TABLE public.annotations
    ADD COLUMN is_private bool DEFAULT FALSE;

-- Changes 6/9/23 --
ALTER TABLE public.annotations
    DROP CONSTRAINT annotations_layer_id_fkey,
    ADD CONSTRAINT annotations_layer_id_fkey FOREIGN KEY (layer_id) REFERENCES public.layers
        ON DELETE CASCADE;

-- Changes 7/26/23 --
ALTER TABLE public.annotations
    ADD COLUMN is_archived bool DEFAULT FALSE;



