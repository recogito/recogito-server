// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from 'server';

serve(async (req) => {
  const { xml_id } = await req.json();

  const data = {
    xml_id: xml_id,
    fcc_url: `${Deno.env.get('FCC_URL')}/documents/${xml_id}/tei`,
  };
  return new Response(JSON.stringify(data), {
    headers: { 'Content-Type': 'application/json' },
  });
});
