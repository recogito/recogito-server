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
};

export type REC_Collection = {
  name: string;
  extension_id: string;
  extension_metadata: object;
};
