// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from 'server';
import { createClient, SupabaseClient } from 'supabase';
import { FCC_TEIDocument, REC_Collection } from '../types';

// This function retrieves the collections from the recogito DB and then queries
// FairCopyCloud (FCC) for any missing or updated documents

const EXTENSION_ID = '354b462a-6625-456e-8c54-ba2d1810da7d';

serve(async (_req: object) => {
  const supabaseFCC = createClient(
    Deno.env.get('FCC_API_URL'),
    Deno.env.get('FCC_SERVICE_KEY'),
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    }
  );

  const supabaseREC = createClient(
    Deno.env.get('SUPABASE_URL'),
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY'),
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    }
  );

  // Get a list of collections managed by this extension
  const collectionsResp = await supabaseREC
    .from('collections')
    .select()
    .eq('extension_id', EXTENSION_ID);

  if (collectionsResp.error) {
    console.error('Error selecting collections: ', collectionsResp.error);
    return;
  }

  const collections = collectionsResp.data;

  // Each collection is a FCC project.  This data is stored in the
  // extension_metadata attribute of the collection. For each collection
  // get a list of documents
  console.info(collections);
  for (let i = 0; i < collections.length; i++) {
    const collection = collections[i];

    if (
      collection.extension_metadata &&
      collection.extension_metadata.fcc_project_id
    ) {
      console.info(
        `Getting TEI Document list for collection ${collection.name}, FCC Project Id: ${collection.extension_metadata.fcc_project_id}`
      );
      // Get the latest documents
      const projectsResp = await supabaseFCC
        .from('tei_documents')
        .select('id, xml_id, resource_guid, is_latest, revision_number')
        .eq('project_id', collection.extension_metadata.fcc_project_id)
        .eq('is_latest', true);

      if (projectsResp.error) {
        console.error(
          `Error retrieving FCC documents for project ${collection.extension_metadata.fcc_project_id}: `,
          projectsResp.error
        );
      } else {
        console.log('TEI Document list: ', projectsResp.data);
        processDocumentList(
          supabaseREC,
          supabaseFCC,
          collection.id,
          collection.extension_metadata.fcc_project_id,
          projectsResp.data
        );
      }
    }
  }

  return new Response(JSON.stringify({}), {
    headers: { 'Content-Type': 'application/json' },
  });
});

async function processDocumentList(
  supabaseREC: SupabaseClient,
  supabaseFCC: SupabaseClient,
  collectionId: string,
  projectId: number,
  documents: FCC_TEIDocument[]
) {
  // Get all the documents from the collection
  const collectsDocsResp = await supabaseREC
    .from('documents')
    .select()
    .eq('collection_id', collectionId);

  if (collectsDocsResp.error) {
    console.error(
      'Error retrieving collection documents: ',
      collectsDocsResp.error
    );
    return;
  }

  const collectionDocs = collectsDocsResp.data;

  // For each document determine if we have already have it.
  // If we do not add it.
  for (let i = 0; i < documents.length; i++) {
    const doc = documents[i];
    console.info(
      `Processing document ${doc.xml_id}, revison: ${doc.revision_number}`
    );
    const foundDoc = collectionDocs.find((d: REC_Collection) => {
      if (
        d.collection_metadata &&
        d.collection_metadata.guid === doc.resource_guid &&
        d.collection_metadata.revison === doc.revision_number
      ) {
        return true;
      }

      return false;
    });

    if (!foundDoc) {
      console.info('   Document revission not found!, Adding');
      const teiResp = await supabaseFCC
        .from('tei_documents')
        .select('id, project_id, xml, revision_number')
        .eq('id', doc.id);

      if (teiResp.error) {
        console.error(
          `Error retrieving TEI document ${doc.xml_id}`,
          teiResp.error
        );
      } else if (teiResp.data.length) {
        // Create a document
        const id = crypto.randomUUID();
        const createDocResp = await supabaseREC.from('documents').insert([
          {
            id: id,
            name: doc.xml_id,
            bucket_id: 'documents',
            content_type: 'text/xml',
            is_private: false,
            meta_data: {},
            collection_id: collectionId,
            collection_metadata: {
              revision_number: teiResp.data[0].revision_number,
              document_id: `${projectId}-${doc.xml_id}`,
              description: 'New draft published',
            },
          },
        ]);

        if (createDocResp.error) {
          console.error(`Error creating new document for ${foundDoc.xml_id}`);
        } else {
          // Updload the tei
          const uploadResp = await supabaseREC.storage
            .from('documents')
            .upload(id, teiResp.data[0].xml, {
              cacheControl: '3600',
              upsert: false,
            });
          if (uploadResp.error) {
            console.error(
              `Error uploading document for ${foundDoc.xml_id}`,
              uploadResp.error
            );
            // Delete the document
            await supabaseREC.from('documents').delete().eq('id', id);
          }
        }
      }
    }
  }
}

// To invoke:
// curl -i --location --request POST 'http://localhost:54321/functions/v1/' \
//   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
//   --header 'Content-Type: application/json' \
//   --data '{"name":"Functions"}'
