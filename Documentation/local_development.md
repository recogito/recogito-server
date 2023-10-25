# Local Development

We are using the [local development setup](https://supabase.com/docs/guides/cli/local-development) for Supabase.  It should be noted that this local dev setup is *NOT* appropriate for running the server locally, but rather as a way to iterate on the DB without directly interacting with the Production server (or Dev/Staging for that matter).  The process below will reset the database with every migration essentially.  In the future we will detail 

## Requirements

- Docker
- Git
- Supabase CLI
- This repository

## Running Supabase

~~~
supabase start
~~~

The dashboard should now be visible at http://localhost:54323/.  At this point is should show an empty project.

If this is the initial setup of the local dev environment you will want to link the local environment to the production project

~~~
supabase link --project-ref <project-id>
~~~

To populate the schema, from the repo's root directory run:

~~~
supabase db reset
~~~

This should populate the schema with all the migrations in the repo.  At some point we may seed data but there does not seem to be a good reason to do that yet.

## Adding a Migration by hand

If you intend to make a postgres changes directly via SQL in a migration file you can use this method.

To create a new migration run:

~~~
supabase migration new <new_migration_name>
~~~

This will create an empty file in the /supabase/migrations directory.

In this approach you write your SQL commands directly to the migration file. Any valid SQL can be added here, so you can ADD/ALTER/DROP tables, create functions and triggers, populate data, etc. 

Once finished with you changes run:

~~~
supabase db reset
~~~

This resets the database and runs all of your migrations.

#### Via the studio dashboard

Here you just go ahead and work through the dashboard, using any of the functionality provided.  At this point I believe that this is the safest approach as it should correctly pick up any Supabase secret sauce. I have no documentation to prove this, but I have seen additional SQL added to a given change done through the dashboard.

To be clear, you can make all of your changes in SQL by writing the appropriate commands in a separate file and then pasting it into the SQL console in the dashboard.

### Generating migrations from changes made in the dashboard

Once you are satisfied with the changes you have made to Supabase run:

~~~
supabase db diff -f <name of migration file you want to create>
~~~

This will generate diffs from all schemas and create and write out the changes to the filename specified.

Then run:

~~~
supabase db reset
~~~

This will apply the changes back to the DB.  It will also pickup any additional SQL commands you added directly to the migration file.

Note that db reset does indeed reset the DB, so any data you may have added since the last reset will be lost.  This would be the point of the *seed.sql* file if there was data you wished to always have in the local dev DB.

## Migrating the Production Environment (or other public environment in the future)

To apply your local changes to the production environment:

First Time run:
~~~
supabase db remote commit
~~~

After the first remote commit run:
~~~
supabase db push
~~~

This will migrate the target remote environment (set with supabase link from above) to the new schema.  It should preserve all current data.

## Diff local server with remote

To get the differences:

~~~
supabase db remote commit
~~~




