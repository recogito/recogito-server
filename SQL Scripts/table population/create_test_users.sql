`-- Test Users
INSERT INTO auth.users
(instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token,
 confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at,
 last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone,
 phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current,
 email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at)
VALUES ('00000000-0000-0000-0000-000000000000', '35fb1d77-cb20-41c4-81c0-d344a0c641b8', 'authenticated',
        'authenticated', 'professor@example.com', '$2a$10$6zroyZ4geDj8jy7kBwb93OPX58Mpx.SaZ0yeTVNcs.H8mr0ikdbKS',
        '2023-04-22 13:10:31.463703+00', NULL, '', NULL, '', '2023-04-22 13:10:03.275387+00', '', '', NULL,
        '2023-04-22 13:10:31.458239+00', '{"provider": "email", "providers": ["email"]}', '{}', NULL,
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00', NULL, NULL, '', '', NULL, '', 0, NULL, '',
        NULL),
       ('00000000-0000-0000-0000-000000000000', '643b574b-5673-4839-8f5e-116d551a7103', 'authenticated',
        'authenticated', 'tutor@example.com', '$2a$10$5YzRg5AbxTVWRkSraxqfouAg3/BHBVITq1qQZOUOy2u4/48T45Bxi',
        '2023-04-22 13:10:31.463703+00', NULL, '', NULL, '', '2023-04-22 13:10:03.275387+00', '', '', NULL,
        '2023-04-22 13:10:31.458239+00', '{"provider": "email", "providers": ["email"]}', '{}', NULL,
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00', NULL, NULL, '', '', NULL, '', 0, NULL, '',
        NULL),
       ('00000000-0000-0000-0000-000000000000', '4fb7ae8c-51fe-4f4d-9f96-083543d4d75f', 'authenticated',
        'authenticated', 'student@example.com', '$2a$10$ORf/tNfemBLIkkaqfLnXpuiUhFlTOLGZMjETwb5laQOOFHVJSkQje',
        '2023-04-22 13:10:31.463703+00', NULL, '', NULL, '', '2023-04-22 13:10:03.275387+00', '', '', NULL,
        '2023-04-22 13:10:31.458239+00', '{"provider": "email", "providers": ["email"]}', '{}', NULL,
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00', NULL, NULL, '', '', NULL, '', 0, NULL, '',
        NULL),
       ('00000000-0000-0000-0000-000000000000', 'dfd9e45c-a435-4e55-9082-10ff52b0f5e2', 'authenticated',
        'authenticated', 'reader@example.com``', '$2a$10$/niS7BbeFQMLlIFHdCbv.ett8bAcPf5bD13z77q5bJCpV956AUJi2',
        '2023-04-22 13:10:31.463703+00', NULL, '', NULL, '', '2023-04-22 13:10:03.275387+00', '', '', NULL,
        '2023-04-22 13:10:31.458239+00', '{"provider": "email", "providers": ["email"]}', '{}', NULL,
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00', NULL, NULL, '', '', NULL, '', 0, NULL, '',
        NULL);

INSERT INTO auth.identities
(id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
VALUES ('35fb1d77-cb20-41c4-81c0-d344a0c641b8', '35fb1d77-cb20-41c4-81c0-d344a0c641b8'::uuid, '{"sub": "35fb1d77-cb20-41c4-81c0-d344a0c641b8", "email": "professor@example.com"}', 'email', '2023-04-22 13:10:31.458239+00',
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00'),
       ('643b574b-5673-4839-8f5e-116d551a7103', '643b574b-5673-4839-8f5e-116d551a7103'::uuid, '{"sub": "643b574b-5673-4839-8f5e-116d551a7103", "email": "tutor@example.com"}', 'email', '2023-04-22 13:10:31.458239+00',
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00'),
       ('4fb7ae8c-51fe-4f4d-9f96-083543d4d75f', '4fb7ae8c-51fe-4f4d-9f96-083543d4d75f'::uuid, '{"sub": "4fb7ae8c-51fe-4f4d-9f96-083543d4d75f", "email": "student@example.com"}', 'email', '2023-04-22 13:10:31.458239+00',
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00'),
       ('dfd9e45c-a435-4e55-9082-10ff52b0f5e2', 'dfd9e45c-a435-4e55-9082-10ff52b0f5e2'::uuid, '{"sub": "dfd9e45c-a435-4e55-9082-10ff52b0f5e2", "email": "reader@example.com"}', 'email', '2023-04-22 13:10:31.458239+00',
        '2022-10-04 03:41:27.391146+00', '2023-04-22 13:10:31.463703+00');
`
