-- on_project_document_updated was created as BEFORE INSERT instead of BEFORE
-- UPDATE, so project documents were all getting null for created_at and
-- created_by after it ran.
-- This migration updates the trigger to run BEFORE UPDATE.

-- Backfill existing records (runs first to prevent the trigger from firing).
-- Nothing modifies updated_at or updated_by on project_documents after the
-- initial insert, so these should all be accurate.
UPDATE public.project_documents
SET created_at = updated_at,
    created_by = COALESCE(created_by, updated_by)
WHERE created_at IS NULL
  AND updated_at IS NOT NULL;

DROP TRIGGER IF EXISTS on_project_document_updated ON public.project_documents;

CREATE TRIGGER on_project_document_updated
    BEFORE UPDATE ON public.project_documents
    FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();
