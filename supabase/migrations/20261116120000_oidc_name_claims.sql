-- Populate profile first/last names from standard OIDC claims (given_name / family_name).
--
-- OAuth/OIDC providers such as Keycloak are not SAML SSO (is_sso_user is false) and
-- Supabase Auth stores their non-standard claims under raw_user_meta_data.custom_claims.
--
-- On sign-up the names are copied into the profile. On later sign-ins they only fill names
-- that are still empty. (SAML behaviour is unchanged.)

CREATE
OR REPLACE FUNCTION public.handle_new_user () RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    _id UUID;
BEGIN
    RAISE NOTICE 'User Id: %', NEW.id;
    IF NEW.is_sso_user IS TRUE
    AND NEW.raw_user_meta_data->'custom_claims' IS NOT NULL
    AND (NEW.raw_user_meta_data->'custom_claims'->>'first_name' IS NOT NULL
    OR NEW.raw_user_meta_data->'custom_claims'->>'last_name' IS NOT NULL)
    THEN
        INSERT INTO public.profiles (id, email, first_name, last_name)
        VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->'custom_claims'->>'first_name', NEW.raw_user_meta_data->'custom_claims'->>'last_name');
    ELSIF NEW.raw_user_meta_data->'custom_claims'->>'given_name' IS NOT NULL
    OR NEW.raw_user_meta_data->'custom_claims'->>'family_name' IS NOT NULL
    THEN
        INSERT INTO public.profiles (id, email, first_name, last_name)
        VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->'custom_claims'->>'given_name', NEW.raw_user_meta_data->'custom_claims'->>'family_name');
    ELSIF NEW.raw_user_meta_data->>'first_name' IS NOT NULL
    OR NEW.raw_user_meta_data->>'last_name' IS NOT NULL
    THEN
        INSERT INTO public.profiles (id, email, first_name, last_name)
        VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'first_name', NEW.raw_user_meta_data->>'last_name');
    ELSE
        INSERT INTO public.profiles (id, email)
        VALUES (NEW.id, NEW.email);
    END IF;


    IF EXISTS(SELECT 1 FROM public.organization_groups WHERE is_default = TRUE)
    THEN
        SELECT id INTO _id FROM public.organization_groups WHERE is_default = TRUE;
        INSERT INTO public.group_users (user_id, group_type, type_id) VALUES (NEW.id, 'organization', _id);
    END IF;
    RETURN new;
END;
$$;

CREATE
    OR REPLACE FUNCTION public.update_user()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    IF NEW.is_sso_user IS TRUE
    AND NEW.raw_user_meta_data->'custom_claims' IS NOT NULL
    AND (NEW.raw_user_meta_data->'custom_claims'->>'first_name' IS NOT NULL
    OR NEW.raw_user_meta_data->'custom_claims'->>'last_name' IS NOT NULL)
    THEN
        UPDATE public.profiles
        SET email = NEW.email,
            first_name = NEW.raw_user_meta_data->'custom_claims'->>'first_name',
            last_name = NEW.raw_user_meta_data->'custom_claims'->>'last_name'
        WHERE id = NEW.id;
    ELSIF NEW.raw_user_meta_data->'custom_claims'->>'given_name' IS NOT NULL
    OR NEW.raw_user_meta_data->'custom_claims'->>'family_name' IS NOT NULL
    THEN
        UPDATE public.profiles
        SET email = NEW.email,
            first_name = COALESCE(NULLIF(first_name, ''), NEW.raw_user_meta_data->'custom_claims'->>'given_name'),
            last_name = COALESCE(NULLIF(last_name, ''), NEW.raw_user_meta_data->'custom_claims'->>'family_name')
        WHERE id = NEW.id;
    ELSE
        UPDATE public.profiles
        SET email = NEW.email
        WHERE id = NEW.id;
    END IF;
    RETURN new;
END;
$$
;

-- Backfill existing OIDC users whose profile names are still empty.
UPDATE public.profiles p
SET first_name = COALESCE(NULLIF(p.first_name, ''), u.raw_user_meta_data->'custom_claims'->>'given_name'),
    last_name = COALESCE(NULLIF(p.last_name, ''), u.raw_user_meta_data->'custom_claims'->>'family_name')
FROM auth.users u
WHERE u.id = p.id
AND u.is_sso_user IS NOT TRUE
AND (u.raw_user_meta_data->'custom_claims'->>'given_name' IS NOT NULL
OR u.raw_user_meta_data->'custom_claims'->>'family_name' IS NOT NULL)
AND (NULLIF(p.first_name, '') IS NULL
OR NULLIF(p.last_name, '') IS NULL);
