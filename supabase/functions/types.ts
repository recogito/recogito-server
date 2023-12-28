export type FCC_TEIDocument = {
  id: string;
  created_at: string;
  project_id: string;
  iiif_manifest?: object;
  xml?: string;
  html?: string;
  xml_id?: string;
  resource_guid?: string;
  txt?: string;
  revision_number: number;
};

export type REC_Collection = {
  name: string;
  extension_id: string;
  extension_metadata: object;
};

export type REC_Document = {
  id: string;
  bucket_id: string;
  created_at: string;
  name: string;
  collection_id: string;
  meta_data: object;
  content_type: string;
  is_archived: boolean;
  is_private: boolean;
  collection_metadata: {
    guid: string;
    revision_number: number;
  };
};
