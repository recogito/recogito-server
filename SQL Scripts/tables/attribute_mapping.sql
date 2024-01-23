CREATE TYPE target_type_types AS ENUM('profiles_table', 'org_group_override');

CREATE TABLE
  attribute_mapping (
    id UUID NOT NULL DEFAULT uuid_generate_v4 () PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.profiles,
    updated_at timestamptz,
    updated_by UUID REFERENCES public.profiles,
    saml_attribute_name VARCHAR NOT NULL,
    custom_claim VARCHAR NOT NULL,
    target_type target_type_types NOT NULL,
    target_attribute VARCHAR,
    attribute_value_mapping json
  );