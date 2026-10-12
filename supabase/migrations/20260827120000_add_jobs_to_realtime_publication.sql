-- Publish changes to jobs so the frontend can watch via WebSocket
alter publication supabase_realtime add table public.jobs;
