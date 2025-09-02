CREATE INDEX annotations_layer_id_idx ON public.annotations USING btree (layer_id);

CREATE INDEX bodies_annotation_id_idx ON public.bodies USING btree (annotation_id);

CREATE INDEX context_documents_context_id_idx ON public.context_documents USING btree (context_id);

CREATE INDEX context_users_context_id_idx ON public.context_users USING btree (context_id);

CREATE INDEX context_users_context_id_idx1 ON public.context_users USING btree (context_id);

CREATE INDEX contexts_project_id_idx ON public.contexts USING btree (project_id);

CREATE INDEX contexts_project_id_idx1 ON public.contexts USING btree (project_id);

CREATE INDEX documents_collection_id_idx ON public.documents USING btree (collection_id);

CREATE INDEX documents_is_archived_idx ON public.documents USING btree (is_archived);

CREATE INDEX group_users_type_id_idx ON public.group_users USING btree (type_id);

CREATE INDEX layer_contexts_context_id_idx ON public.layer_contexts USING btree (context_id);

CREATE INDEX project_documents_project_id_idx ON public.project_documents USING btree (project_id);

CREATE INDEX project_documents_project_id_idx1 ON public.project_documents USING btree (project_id);

CREATE INDEX project_documents_sort_idx ON public.project_documents USING btree (sort);

CREATE INDEX project_groups_project_id_idx ON public.project_groups USING btree (project_id);

CREATE INDEX project_groups_project_id_idx1 ON public.project_groups USING btree (project_id);

CREATE INDEX targets_annotation_id_idx ON public.targets USING btree (annotation_id);


