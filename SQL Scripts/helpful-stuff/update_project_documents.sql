DO $$
DECLARE
  t_row public.layers % rowtype;
BEGIN
  FOR t_row IN SELECT * FROM public.layers LOOP
    IF NOT EXISTS(
    SELECT 1
    FROM public.project_documents
    WHERE project_id = t_row.project_id
    AND document_id = t_row.document_id
  ) THEN
      INSERT INTO public.project_documents (project_id, document_id)
      VALUES (
        t_row.project_id,
        t_row.document_id
      );
    END IF;
  END LOOP;
END
$$
