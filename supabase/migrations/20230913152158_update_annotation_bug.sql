drop trigger if exists "on_annotation_updated" on "public"."annotations";

CREATE TRIGGER on_annotation_updated BEFORE UPDATE ON public.annotations FOR EACH ROW EXECUTE FUNCTION update_dates_and_user();


