// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'supabase';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('FCC_URL'),
    Deno.env.get('FCC_SERVICE_KEY'),
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    }
  );

  const projectsResp = await supabase.from('projects').select();

  return new Response(JSON.stringify(projectsResp.data), {
    headers: { 'Content-Type': 'application/json' },
  });
});
