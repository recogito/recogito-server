export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json }
  | Json[]

export interface Database {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          operationName?: string
          query?: string
          variables?: Json
          extensions?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      annotations: {
        Row: {
          context_id: string | null
          created_at: string | null
          created_by: string | null
          id: string
          updated_at: string | null
          updated_by: string | null
          version: number
        }
        Insert: {
          context_id?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          updated_at?: string | null
          updated_by?: string | null
          version?: number
        }
        Update: {
          context_id?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          updated_at?: string | null
          updated_by?: string | null
          version?: number
        }
      }
      bodies: {
        Row: {
          annotation_id: string | null
          created_at: string | null
          created_by: string | null
          format: Database["public"]["Enums"]["body_formats"] | null
          id: string
          language: string | null
          purpose: string | null
          type: Database["public"]["Enums"]["body_types"] | null
          updated_at: string | null
          updated_by: string | null
          value: string | null
          version: number
        }
        Insert: {
          annotation_id?: string | null
          created_at?: string | null
          created_by?: string | null
          format?: Database["public"]["Enums"]["body_formats"] | null
          id?: string
          language?: string | null
          purpose?: string | null
          type?: Database["public"]["Enums"]["body_types"] | null
          updated_at?: string | null
          updated_by?: string | null
          value?: string | null
          version?: number
        }
        Update: {
          annotation_id?: string | null
          created_at?: string | null
          created_by?: string | null
          format?: Database["public"]["Enums"]["body_formats"] | null
          id?: string
          language?: string | null
          purpose?: string | null
          type?: Database["public"]["Enums"]["body_types"] | null
          updated_at?: string | null
          updated_by?: string | null
          value?: string | null
          version?: number
        }
      }
      contexts: {
        Row: {
          created_at: string | null
          created_by: string | null
          id: string
          name: string | null
          project_id: string | null
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          name?: string | null
          project_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          name?: string | null
          project_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      documents: {
        Row: {
          bucket_id: string | null
          created_at: string | null
          created_by: string | null
          id: string
          name: string
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          bucket_id?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          name: string
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          bucket_id?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          name?: string
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      group_users: {
        Row: {
          created_at: string | null
          created_by: string | null
          group_id: string | null
          id: string
          updated_at: string | null
          updated_by: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          group_id?: string | null
          id?: string
          updated_at?: string | null
          updated_by?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          group_id?: string | null
          id?: string
          updated_at?: string | null
          updated_by?: string | null
          user_id?: string | null
        }
      }
      groups: {
        Row: {
          created_at: string | null
          created_by: string | null
          id: string
          is_system_group: boolean | null
          project_id: string | null
          role_id: string | null
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          is_system_group?: boolean | null
          project_id?: string | null
          role_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          is_system_group?: boolean | null
          project_id?: string | null
          role_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      layer_documents: {
        Row: {
          created_at: string | null
          created_by: string | null
          document_id: string | null
          id: string
          layer_id: string | null
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          document_id?: string | null
          id?: string
          layer_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          document_id?: string | null
          id?: string
          layer_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      layer_groups: {
        Row: {
          created_at: string | null
          created_by: string | null
          group_id: string | null
          id: string
          layer_id: string | null
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          group_id?: string | null
          id?: string
          layer_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          group_id?: string | null
          id?: string
          layer_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      layers: {
        Row: {
          context_id: string | null
          created_at: string | null
          created_by: string | null
          description: string | null
          id: string
          name: string | null
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          context_id?: string | null
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          name?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          context_id?: string | null
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          name?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      organization_groups: {
        Row: {
          created_at: string | null
          created_by: string | null
          group_id: string
          id: string
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          group_id: string
          id?: string
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          group_id?: string
          id?: string
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      policies: {
        Row: {
          created_at: string | null
          created_by: string | null
          id: string
          operation: Database["public"]["Enums"]["operation_types"]
          table_name: string
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          operation: Database["public"]["Enums"]["operation_types"]
          table_name: string
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          operation?: Database["public"]["Enums"]["operation_types"]
          table_name?: string
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string | null
          created_by: string | null
          email: string | null
          first_name: string | null
          gdpr_optin: boolean | null
          id: string
          last_name: string | null
          nickname: string | null
          role: Database["public"]["Enums"]["profile_role_types"]
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string | null
          created_by?: string | null
          email?: string | null
          first_name?: string | null
          gdpr_optin?: boolean | null
          id: string
          last_name?: string | null
          nickname?: string | null
          role?: Database["public"]["Enums"]["profile_role_types"]
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          avatar_url?: string | null
          created_at?: string | null
          created_by?: string | null
          email?: string | null
          first_name?: string | null
          gdpr_optin?: boolean | null
          id?: string
          last_name?: string | null
          nickname?: string | null
          role?: Database["public"]["Enums"]["profile_role_types"]
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      project_groups: {
        Row: {
          created_at: string | null
          created_by: string | null
          group_id: string
          id: string
          project_id: string
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          group_id: string
          id?: string
          project_id: string
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          group_id?: string
          id?: string
          project_id?: string
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      projects: {
        Row: {
          created_at: string | null
          created_by: string | null
          description: string | null
          id: string
          name: string | null
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          name?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          name?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      role_policies: {
        Row: {
          created_at: string | null
          created_by: string | null
          id: string
          policy_id: string | null
          role_id: string | null
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          policy_id?: string | null
          role_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          policy_id?: string | null
          role_id?: string | null
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      roles: {
        Row: {
          created_at: string | null
          created_by: string | null
          description: string | null
          id: string
          name: string
          updated_at: string | null
          updated_by: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          name?: string
          updated_at?: string | null
          updated_by?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          name?: string
          updated_at?: string | null
          updated_by?: string | null
        }
      }
      targets: {
        Row: {
          annotation_id: string | null
          conforms_to:
            | Database["public"]["Enums"]["target_conforms_to_types"]
            | null
          created_at: string | null
          created_by: string
          id: string
          selector_type:
            | Database["public"]["Enums"]["target_selector_types"]
            | null
          updated_at: string | null
          updated_by: string | null
          value: string | null
          version: number
        }
        Insert: {
          annotation_id?: string | null
          conforms_to?:
            | Database["public"]["Enums"]["target_conforms_to_types"]
            | null
          created_at?: string | null
          created_by: string
          id?: string
          selector_type?:
            | Database["public"]["Enums"]["target_selector_types"]
            | null
          updated_at?: string | null
          updated_by?: string | null
          value?: string | null
          version?: number
        }
        Update: {
          annotation_id?: string | null
          conforms_to?:
            | Database["public"]["Enums"]["target_conforms_to_types"]
            | null
          created_at?: string | null
          created_by?: string
          id?: string
          selector_type?:
            | Database["public"]["Enums"]["target_selector_types"]
            | null
          updated_at?: string | null
          updated_by?: string | null
          value?: string | null
          version?: number
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      check_action_policy_layer: {
        Args: {
          user_id: string
          table_name: string
          operation: Database["public"]["Enums"]["operation_types"]
          layer_id: string
        }
        Returns: boolean
      }
      check_action_policy_organization: {
        Args: {
          user_id: string
          table_name: string
          operation: Database["public"]["Enums"]["operation_types"]
        }
        Returns: boolean
      }
      check_action_policy_project: {
        Args: {
          user_id: string
          table_name: string
          operation: Database["public"]["Enums"]["operation_types"]
          project_id: string
        }
        Returns: boolean
      }
    }
    Enums: {
      body_formats: "TextPlain" | "TextHtml"
      body_types: "TextualBody"
      operation_types: "SELECT" | "INSERT" | "UPDATE" | "DELETE"
      profile_role_types: "admin" | "teacher" | "base_user"
      target_conforms_to_types: "Svg"
      target_selector_types: "Fragment" | "SvgSelector"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  storage: {
    Tables: {
      buckets: {
        Row: {
          allowed_mime_types: string[] | null
          avif_autodetection: boolean | null
          created_at: string | null
          file_size_limit: number | null
          id: string
          name: string
          owner: string | null
          public: boolean | null
          updated_at: string | null
        }
        Insert: {
          allowed_mime_types?: string[] | null
          avif_autodetection?: boolean | null
          created_at?: string | null
          file_size_limit?: number | null
          id: string
          name: string
          owner?: string | null
          public?: boolean | null
          updated_at?: string | null
        }
        Update: {
          allowed_mime_types?: string[] | null
          avif_autodetection?: boolean | null
          created_at?: string | null
          file_size_limit?: number | null
          id?: string
          name?: string
          owner?: string | null
          public?: boolean | null
          updated_at?: string | null
        }
      }
      migrations: {
        Row: {
          executed_at: string | null
          hash: string
          id: number
          name: string
        }
        Insert: {
          executed_at?: string | null
          hash: string
          id: number
          name: string
        }
        Update: {
          executed_at?: string | null
          hash?: string
          id?: number
          name?: string
        }
      }
      objects: {
        Row: {
          bucket_id: string | null
          created_at: string | null
          id: string
          last_accessed_at: string | null
          metadata: Json | null
          name: string | null
          owner: string | null
          path_tokens: string[] | null
          updated_at: string | null
        }
        Insert: {
          bucket_id?: string | null
          created_at?: string | null
          id?: string
          last_accessed_at?: string | null
          metadata?: Json | null
          name?: string | null
          owner?: string | null
          path_tokens?: string[] | null
          updated_at?: string | null
        }
        Update: {
          bucket_id?: string | null
          created_at?: string | null
          id?: string
          last_accessed_at?: string | null
          metadata?: Json | null
          name?: string | null
          owner?: string | null
          path_tokens?: string[] | null
          updated_at?: string | null
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      extension: {
        Args: {
          name: string
        }
        Returns: string
      }
      filename: {
        Args: {
          name: string
        }
        Returns: string
      }
      foldername: {
        Args: {
          name: string
        }
        Returns: string[]
      }
      get_size_by_bucket: {
        Args: Record<PropertyKey, never>
        Returns: {
          size: number
          bucket_id: string
        }[]
      }
      search: {
        Args: {
          prefix: string
          bucketname: string
          limits?: number
          levels?: number
          offsets?: number
          search?: string
          sortcolumn?: string
          sortorder?: string
        }
        Returns: {
          name: string
          id: string
          updated_at: string
          created_at: string
          last_accessed_at: string
          metadata: Json
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

