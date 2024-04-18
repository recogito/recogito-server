set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_for_project_open_edit_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  _is_project_default BOOLEAN;  
  _is_open_edit BOOLEAN;
  _record RECORD;
  _layer_record RECORD;
  _context_id uuid;
  _layer_group_id uuid;
  _project_group_id uuid;
  _id uuid;
BEGIN
  -- See project has changed to open edit
  IF OLD.is_open_edit IS FALSE AND NEW.is_open_edit IS TRUE THEN
    -- Get the default context
    SELECT c.id INTO _context_id FROM public.contexts c WHERE c.project_id = NEW.id AND c.is_project_default IS TRUE;

    -- RAISE LOG 'Found default context: %', _context_id; 

    FOR _layer_record IN SELECT * FROM public.layers l
      INNER JOIN public.layer_contexts lc ON lc.context_id = _context_id AND l.project_id = OLD.id
    LOOP

      -- Get the layer group
      SELECT lg.id INTO _layer_group_id FROM public.layer_groups lg WHERE lg.layer_id = _layer_record.id and is_default IS TRUE;
      -- RAISE LOG 'Found layer_group: %', _layer_group_id; 

      -- Get the project group
      SELECT pg.id INTO _project_group_id FROM public.project_groups pg WHERE pg.project_id = NEW.id AND is_default IS TRUE;
      -- RAISE LOG 'Found project_group: %', _project_group_id; 

      -- Add all project members to default layer group
      FOR _record IN SELECT * FROM public.group_users WHERE group_type = 'project' AND type_id = _project_group_id
      LOOP
          -- RAISE LOG 'Adding % to layer group', _record.user_id; 
          INSERT INTO public.group_users (group_type, user_id, type_id)
          VALUES ('layer',_record.user_id, _layer_group_id);
      END LOOP; 
    END LOOP;   
  END IF;

  RETURN NEW;
END
$function$
;

CREATE OR REPLACE TRIGGER on_project_updated_check_open_edit AFTER UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION check_for_project_open_edit_change();


