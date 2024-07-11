DO $$
DECLARE
  t_row public.context_documents % rowtype;
  t_row_context public.contexts % rowtype;
  _id uuid;
BEGIN

  FOR t_row IN SELECT * FROM public.context_documents 
    LOOP
      SELECT * INTO t_row_context FROM public.contexts c WHERE c.id = t_row.context_id;
      IF NOT EXISTS(SELECT 1 FROM public.project_documents pd WHERE pd.document_id = t_row.document_id AND pd.project_id = t_row_context.project_id)
        RAISE LOG 'Project % Missing document %', t_row_context.project_id, t_row.document_id;
        INSERT INTO public.project_documents (project_id, document_id)
        VALUES (
          t_row_context.project_id,
          t_row.document_id
        );
      END IF;
    END LOOP;
END
$$
