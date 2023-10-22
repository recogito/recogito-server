BEGIN;
 
-- remove the supabase_realtime publication
DROP
  publication IF EXISTS supabase_realtime;
 
-- re-create the supabase_realtime publication with no tables
CREATE publication supabase_realtime;
 
COMMIT;
 
-- add a table called 'messages' to the publication
-- (update this to match your tables)
ALTER
  publication supabase_realtime ADD TABLE annotations, targets, bodies;