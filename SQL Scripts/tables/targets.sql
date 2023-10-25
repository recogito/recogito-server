-- targets table --
CREATE TYPE target_selector_types AS ENUM ('Fragment', 'SvgSelector');

CREATE TYPE target_conforms_to_types AS ENUM ('Svg');

CREATE TABLE targets
(
    id            uuid                          NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at    timestamp WITH TIME ZONE               DEFAULT NOW(),
    created_by    uuid REFERENCES auth.users,
    updated_at    timestamptz,
    updated_by    uuid REFERENCES auth.users,
    is_archived   bool                                   DEFAULT FALSE,
    version       int4 GENERATED ALWAYS AS IDENTITY (START WITH 1),
    annotation_id uuid REFERENCES public.annotations ON DELETE CASCADE,
    selector_type target_selector_types,
    conforms_to   target_conforms_to_types,
    value         text,
    layer_id      uuid REFERENCES public.layers NOT NULL
);

-- Changes 4/12/23 --
ALTER TABLE public.targets
    DROP CONSTRAINT targets_annotation_id_fkey,
    ADD CONSTRAINT targets_annotation_id_fkey
        FOREIGN KEY (annotation_id)
            REFERENCES public.annotations
            ON DELETE CASCADE;

-- Changes 5/24/23 --
ALTER TABLE public.targets
    ADD COLUMN layer_id uuid REFERENCES public.layers;

-- Changes 6/9/23 --
ALTER TABLE public.targets
    DROP CONSTRAINT targets_annotation_id_fkey,
    ADD CONSTRAINT targets_annotation_id_fkey FOREIGN KEY (annotation_id) REFERENCES public.annotations
        ON DELETE CASCADE;

-- Changes 7/26/23 --
ALTER TABLE public.targets
    ADD COLUMN is_archived bool DEFAULT FALSE;
