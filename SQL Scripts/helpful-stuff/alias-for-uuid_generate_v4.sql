CREATE OR REPLACE FUNCTION public.uuid_generate_v4() RETURNS uuid
    LANGUAGE plpgsql AS
$$ SELECT extensions.uuid_generate_v4()
$$;
