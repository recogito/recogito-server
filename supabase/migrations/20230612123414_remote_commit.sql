--
--
-- CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);
--
-- CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);
--
-- CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);
--
--
-- drop policy "Users with correct policies can DELETE on projects" on "public"."projects";
--
-- drop policy "Users with correct policies can INSERT on projects" on "public"."projects";
--
-- drop policy "Users with correct policies can SELECT on projects" on "public"."projects";
--
-- drop policy "Users with correct policies can UPDATE on projects" on "public"."projects";
--
create policy "Enable ALL access for authenticated users"
on "public"."projects"
as permissive
for all
to authenticated
using (true)
with check (true);
--
--
--
