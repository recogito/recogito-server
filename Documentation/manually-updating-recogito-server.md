## Manually updating the Recogito Server

Updating the recogito server manually in a self-hosted environment requires this repository and the [Supabase CLI](https://supabase.com/docs/guides/cli).

After installing the CLI:

1. Open a terminal and CD to the root of this repository.

2. Run:

```bash
supabase start
```

This will start the local supabase docker setup and initialize it with the current schema migrations.

3. Run:

```bash
supabase db push --db-url <url of you supabase db>
```

This will sync you self-hosted DB schema with the repository's current schema.

4. Make sure that the config.json file in the repository root has the correct settings.

The repository default config.json is generic. In general you should update the sections that are specific to your installation.

Specifically:

- In the "admin" section, ensure that the email address specified matches the admin email you set during the intitial installation.

- In the "authentication" section, ensure that the methods chosen are correct.

  - If you are setup to accept email based logins, add a method where the type is "username_password" and the name to what you want to appear in the UI for this option.

  - If you are using SSO, add a method where the type is "saml", the name is what you want to appear in the UI and the domain to the accepted domains for your SAML setup.

  - If you want to use magic links, add a method where the type is "magic_link" and the name is what you want to appear in the UI.

5. Ensure you have the proper values in your environment. Consult the ~.env.example~ file to see what you need to set. Note that not all of the values are required for the next step and are used in the Jest based tests.

6. From the root of your repository run:

```bash
node create-default-groups.js -f config.json
```

At this point your supabase install should now be updated.
