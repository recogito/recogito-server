DO $$
DECLARE
  t_row public.context_documents % rowtype;
  _id uuid;
BEGIN

  FOR t_row IN SELECT * FROM public.context_documents 
    LOOP
      SELECT pd.id INTO _id FROM public.project_documents pd WHERE pd.document_id = t_row.document_id;
      IF _id IS NULL THEN
        RAISE LOG 'Updating context document %', t_row.id;
        UPDATE public.context_documents 
          SET is_archived = TRUE 
          WHERE id = t_row.id; 
      END IF;
    END LOOP;
END
$$
