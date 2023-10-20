CREATE UNIQUE INDEX role_policies_index_role_id_policy_id ON public.role_policies USING btree (role_id, policy_id);


