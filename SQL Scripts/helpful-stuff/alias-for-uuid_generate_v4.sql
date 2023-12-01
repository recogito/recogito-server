CREATE OR REPLACE FUNCTION public.uuid_generate_v4() RETURNS uuid
    LANGUAGE plpgsql AS
$$ SELECT uuid_generate_v4()
$$;
