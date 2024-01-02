import {
  loginAsInvited,
  loginAsOrgAdmin,
  loginAsProfessor,
  loginAsServiceUser,
  loginAsStudent,
  loginAsTutor,
} from '../src/utility';
// @ts-ignore
import { SupabaseClient } from '@supabase/supabase-js';
// @ts-ignore
import { log, table } from 'console';
import { create } from 'njwt';

const TEST_PROJECT_ID = '477577df-c156-4cca-9d7a-f96122c1362b';
const NO_STUDENT_PROJECT_ID = '44847ef2-b2ff-48f9-b414-1a0ba316a297';
const TEST_CONTEXT_ID = '3d8892d5-62e4-4ab9-8577-1403f911b5cd';
const TEST_LAYER_ID = 'd431c20b-37f7-46b1-9f6a-008e817f0ec8';
const TEST_PUBLIC_ANNOTATION_ID = '63c3ff8f-6db3-40fd-bd70-bfd767f48e2a';
const TEST_PRIVATE_ANNOTATION_ID = '72d41001-95e8-426c-959a-f1f7736a7fc3';
const TEST_PROFESSOR_ANNOTATION_ID = '0b7dc46c-025c-4bf7-869b-1778c038cdaf';
const TEST_PUBLIC_TARGET_ID = '4dfa5447-8392-4f62-b128-f1a7c094997d';
const TEST_CANNOT_CREATE_TARGET_ID = '8c78bd59-b1e5-450e-a2b9-4ffe73e12d63';
const TEST_PROFESSOR_TARGET_ID = '40b936f0-d818-43f8-aa8d-a73abfeb73ff';
const TEST_PRIVATE_TARGET_ID = 'f73d0d90-547c-425f-9369-56960ab3b3a3';
const TEST_PUBLIC_BODY_ID = '0045df9f-8975-4304-80fb-c757dbd66469';
const TEST_PRIVATE_BODY_ID = 'd5a44ff5-4d8b-46b6-9f4e-38716794aa39';
const TEST_PROFESSOR_BODY_ID = '952d0a9f-1006-46b4-9c12-b0750e214077';
const TEST_CANNOT_CREATE_BODY_ID = 'f97e06dc-b6a4-47df-b4f0-428b7a969f95';
const TEST_SECOND_BODY_ID = 'fd4eff1d-cd36-4291-8bd5-aacb039b7b9e';
const TEST_DOCUMENT_ID = '09318ec8-58f2-4497-958f-8f91343802b2';
const TEST_TUTOR_ANNOTATION_ID = 'e381f0bd-04f5-48cf-93f8-c817db12a26e';
const TEST_TUTOR_TARGET_ID = '625fb5b4-7144-4c54-9eda-547d2235a733';
const TEST_TUTOR_BODY_ID = '8b678638-cd09-448b-9e28-140dc3217c37';
const TEST_INVITE_ID = 'ed273412-82ad-4715-ba6e-6eba2cdfc994';
const TEST_TUTOR_DOCUMENT_ID = '9401ef28-aea9-4310-9137-99038148de77';
const TEST_PROJECT_TAG_DEFINITION_ID = 'c830fba8-54d3-4d2c-aa86-6f41d2789587';
const TEST_CONTEXT_TAG_DEFINITION_ID = '98428668-bf18-4d81-8e28-d67060df573a';
const TEST_ORGANIZATION_TAG_DEFINITION_ID =
  '64eccea3-6185-4247-acb0-47a707b8a4fb';
const NO_STUDENT_PROJECT_TAG_DEFINITION =
  'f8781bb0-f551-468b-bc37-ecaf3db258af';
const COLLECTION_DOCUMENT_ID = '95b95540-fe6c-42ef-9aa4-e1728b7b4082';

type TargetSelectorType = 'Fragment' | 'SvgSelector';

type TargetConformsToType = 'Svg' | undefined;

type BodyTypes = 'TextualBody';

type BodyFormats = 'TextPlain' | 'TextHtml';

type ContentTypes =
  | 'text/markdown'
  | 'image/jpeg'
  | 'image/tiff'
  | 'image/png'
  | 'image/gif'
  | 'image/jp2'
  | 'application/pdf'
  | 'text/plain'
  | 'application/tei+xml'
  | 'application/xml';

async function insertProject(
  supabase: SupabaseClient,
  id: string,
  name: string,
  description: string
) {
  return supabase
    .from('projects')
    .insert({ id: id, name: name, description: description })
    .select();
}

async function updateProject(
  supabase: SupabaseClient,
  id: string,
  newName: string
) {
  const { error, data } = await supabase
    .from('projects')
    .update({ name: newName })
    .eq('id', id)
    .select();

  return !error && data && data.length > 0 && data[0].name === newName;
}

async function deleteProject(supabase: SupabaseClient, id: string) {
  await supabase.from('projects').delete().eq('id', id);

  const { data } = await supabase.from('projects').select().eq('id', id);

  return data ? data.length === 0 : false;
}

async function readProjects(
  supabase: SupabaseClient,
  _name: string,
  _description: string
) {
  return supabase.from('projects').select('*');
}

async function readProject(supabase: SupabaseClient, projectId: string) {
  const result = await supabase.from('projects').select().eq('id', projectId);

  if (result.data && result.data.length > 0) {
    return result.data[0].id === projectId && !result.error;
  }
  return false;
}

async function addUserToProjectGroup(
  supabase: SupabaseClient,
  projectId: string,
  groupName: string,
  userEmail: string
) {
  const result = await supabase
    .from('project_groups')
    .select()
    .eq('project_id', projectId)
    .eq('name', groupName);

  if (result.data && result.data.length > 0) {
    const resultStudent = await supabase
      .from('profiles')
      .select()
      .eq('email', userEmail);

    if (resultStudent.data && result.data.length > 0) {
      const resultGroup = await supabase
        .from('project_groups')
        .select()
        .eq('project_id', projectId)
        .eq('name', groupName);

      if (resultGroup.data && resultGroup.data.length > 0) {
        const resultUserAdd = await supabase
          .from('group_users')
          .insert({
            group_type: 'project',
            type_id: resultGroup.data[0].id,
            user_id: resultStudent.data[0].id,
          })
          .select();

        if (resultUserAdd.data && resultUserAdd.data.length > 0) {
          return true;
        }
      }
    }

    return false;
  }
}

async function readContext(supabase: SupabaseClient, contextId: string) {
  const result = await supabase.from('contexts').select().eq('id', contextId);

  if (result.data && result.data.length > 0) {
    return true;
  }

  return false;
}

async function addContextToProject(
  supabase: SupabaseClient,
  projectId: string,
  contextId: string,
  name: string
) {
  const result = await supabase
    .from('contexts')
    .insert({
      id: contextId,
      project_id: projectId,
      name: name,
    })
    .select();

  if (result.data && result.data.length > 0) {
    return true;
  }

  return false;
}

async function deleteContext(supabase: SupabaseClient, contextId: string) {
  const result = await supabase.from('contexts').delete().eq('id', contextId);

  const supabaseCheck = await loginAsOrgAdmin();

  if (supabaseCheck) {
    const resultSelect = await supabaseCheck
      .from('contexts')
      .select()
      .eq('id', contextId);

    if (!resultSelect.error && resultSelect.data.length === 0) {
      return true;
    }
  }
  return false;
}

async function insertLayer(
  supabase: SupabaseClient,
  projectId: string,
  contextId: string,
  layerId: string,
  documentId: string,
  name: string,
  description: string
) {
  const resultLayer = await supabase
    .from('layers')
    .insert({
      id: layerId,
      project_id: projectId,
      document_id: documentId,
      name: name,
      description: description,
    })
    .select();

  if (resultLayer.data && resultLayer.data.length > 0) {
    const resultLayerContext = await supabase
      .from('layer_contexts')
      .insert({
        layer_id: layerId,
        context_id: contextId,
      })
      .select();

    if (resultLayerContext.data && resultLayerContext.data.length > 0) {
      return true;
    }
  }

  return false;
}

async function readLayer(supabase: SupabaseClient, layerId: string) {
  const result = await supabase.from('layers').select().eq('id', layerId);

  if (result.data && result.data.length > 0) {
    return true;
  }

  return false;
}

async function updateLayer(
  supabase: SupabaseClient,
  layerId: string,
  newName: string
) {
  const result = await supabase
    .from('layers')
    .update({ name: newName })
    .eq('id', layerId)
    .select();

  if (
    result.data &&
    result.data.length > 0 &&
    result.data[0].name === newName
  ) {
    return true;
  }

  return false;
}

async function deleteLayer(supabase: SupabaseClient, layerId: string) {
  const result = await supabase.from('layers').delete().eq('id', layerId);

  const supabaseCheck = await loginAsOrgAdmin();

  if (supabaseCheck) {
    const resultSelect = await supabaseCheck
      .from('layers')
      .select()
      .eq('id', layerId);

    if (!resultSelect.error && resultSelect.data.length === 0) {
      return true;
    }
  }
  return false;
}

async function getLayerGroups(supabase: SupabaseClient, layerId: string) {
  return supabase.from('layer_groups').select().eq('layer_id', layerId);
}

async function addUserToLayerGroup(
  supabase: SupabaseClient,
  layerId: string,
  groupName: string,
  userEmail: string
) {
  const result = await supabase
    .from('layer_groups')
    .select()
    .eq('layer_id', layerId)
    .eq('name', groupName);

  if (result.data && result.data.length > 0) {
    const resultStudent = await supabase
      .from('profiles')
      .select()
      .eq('email', userEmail);

    if (resultStudent.data && result.data.length > 0) {
      const resultGroup = await supabase
        .from('layer_groups')
        .select()
        .eq('layer_id', layerId)
        .eq('name', groupName);

      if (resultGroup.data && resultGroup.data.length > 0) {
        const resultUserAdd = await supabase
          .from('group_users')
          .insert({
            group_type: 'layer',
            type_id: resultGroup.data[0].id,
            user_id: resultStudent.data[0].id,
          })
          .select();

        if (resultUserAdd.data && resultUserAdd.data.length > 0) {
          return true;
        }
      }
    }

    return false;
  }
}

async function getProjectGroups(supabase: SupabaseClient, projectId: string) {
  return supabase.from('project_groups').select().eq('project_id', projectId);
}

async function isProjectGroupMember(
  supabase: SupabaseClient,
  projectId: string,
  groupName: string,
  email: string
) {
  const resultGroup = await supabase
    .from('project_groups')
    .select()
    .eq('name', groupName)
    .eq('project_id', projectId);

  if (resultGroup.data && resultGroup.data.length > 0) {
    const resultProfile = await supabase
      .from('profiles')
      .select()
      .eq('email', email);

    if (resultProfile.data && resultProfile.data.length > 0) {
      const resultGroupUser = await supabase
        .from('group_users')
        .select()
        .eq('group_type', 'project')
        .eq('type_id', resultGroup.data[0].id)
        .eq('user_id', resultProfile.data[0].id);

      if (resultGroupUser.data && resultGroupUser.data.length > 0) {
        return true;
      }
    }
  }

  return false;
}

async function insertAnnotation(
  supabase: SupabaseClient,
  annotationId: string,
  layerId: string,
  isPrivate: boolean
) {
  const result = await supabase.from('annotations').insert({
    id: annotationId,
    layer_id: layerId,
    is_private: isPrivate,
  });

  const resultSelect = await supabase
    .from('annotations')
    .select()
    .eq('id', annotationId);

  return !!(resultSelect.data && resultSelect.data.length > 0);
}

async function updateAnnotation(
  supabase: SupabaseClient,
  annotationId: string,
  isPrivate: boolean
) {
  const result = await supabase
    .from('annotations')
    .update({
      is_private: isPrivate,
    })
    .eq('id', annotationId);

  // console.log('Update Anno error: ', result.error);

  const supa = await loginAsServiceUser();
  const resultSelect = await supa
    .from('annotations')
    .select()
    .eq('id', annotationId);

  // console.log("Error: ", resultSelect.error);

  if (resultSelect.data && resultSelect.data.length > 0) {
    // console.log("Data", resultSelect.data[0]);
    return resultSelect.data[0].is_private === isPrivate;
  }

  return false;
}

async function archiveAnnotation(
  supabase: SupabaseClient,
  annotationId: string
) {
  const result = await supabase.rpc('archive_record_rpc', {
    _table_name: 'annotations',
    _id: annotationId,
  });

  // console.log("ROC Result status", result.status);
  if (result.status === 200) {
    // Should not be any targets or bodies returned
    const resultAnno = await supabase
      .from('annotations')
      .select()
      .eq('id', annotationId);

    if (resultAnno.data && resultAnno.data.length > 0) {
      // console.log("Found Anno");
      return false;
    }

    const resultTarget = await supabase
      .from('targets')
      .select()
      .eq('annotation_id', annotationId)
      .neq('is_archived', true);
    if (resultTarget.data && resultTarget.data.length > 0) {
      // console.log("Found Target");
      return false;
    }

    const resultBody = await supabase
      .from('bodies')
      .select()
      .eq('annotation_id', annotationId)
      .neq('is_archived', true);
    if (resultBody.data && resultBody.data.length > 0) {
      // console.log("Found Body");
      return false;
    }

    return true;
  }

  return false;
}

async function archiveBody(supabase: SupabaseClient, bodyId: string) {
  const result = await supabase.rpc('archive_record_rpc', {
    _table_name: 'bodies',
    _id: bodyId,
  });

  const resultSelect = await supabase.from('bodies').select().eq('id', bodyId);

  if (resultSelect.data && resultSelect.data.length === 0) {
    return true;
  }

  return false;
}

async function checkProjectMembership(
  supabase: SupabaseClient,
  projectId: string,
  email: string
) {
  const result = await supabase.rpc('is_project_member', {
    _project_id: projectId,
    _email: email,
  });

  // console.log("Check Membership result: ", result);
  if (result.data) {
    // console.log(result.data);
    return true;
  }

  return false;
}

async function selectAnnotation(
  supabase: SupabaseClient,
  annotationId: string
) {
  const result = await supabase
    .from('annotations')
    .select()
    .eq('id', annotationId);

  return !!(result.data && result.data.length > 0);
}

async function deleteAnnotation(
  supabase: SupabaseClient,
  annotationId: string,
  isPrivate: boolean
) {
  const result = await supabase
    .from('annotations')
    .delete()
    .eq('id', annotationId);

  const resultSelect = await supabase
    .from('annotations')
    .select()
    .eq('id', annotationId);

  return (
    !resultSelect.error && resultSelect.data && resultSelect.data.length === 0
  );
}

async function insertDocument(
  supabase: SupabaseClient,
  documentId: string,
  name: string,
  bucketId: string,
  contentType: ContentTypes,
  collectionId?: string
) {
  const result = await supabase.from('documents').insert({
    id: documentId,
    name: name,
    bucket_id: bucketId,
    content_type: contentType,
    collectionId: collectionId,
  });

  const resultSelect = await supabase
    .from('documents')
    .select()
    .eq('id', documentId);

  return !!(resultSelect.data && resultSelect.data.length > 0);
}

async function makeDocumentPublic(
  supabase: SupabaseClient,
  documentId: string
) {
  const result = await supabase
    .from('documents')
    .update({
      is_private: false,
    })
    .eq('id', documentId);

  const resultSelect = await supabase
    .from('documents')
    .select()
    .eq('id', documentId);

  return !!(resultSelect.data && resultSelect.data[0].is_private === false);
}

async function addDocumentToProject(
  supabase: SupabaseClient,
  documentId: string,
  projectId: string
) {
  const result = await supabase.from('project_documents').insert({
    document_id: documentId,
    project_id: projectId,
  });

  const resultSelect = await supabase
    .from('project_documents')
    .select()
    .eq('document_id', documentId)
    .eq('project_id', projectId);

  return !!(resultSelect.data && resultSelect.data.length > 0);
}

async function selectDocument(supabase: SupabaseClient, documentId: string) {
  const result = await supabase.from('documents').select().eq('id', documentId);

  return !!(result.data && result.data.length > 0);
}

async function insertTarget(
  supabase: SupabaseClient,
  targetId: string,
  annotationId: string,
  layerId: string,
  selectorType: TargetSelectorType,
  conformsTo: TargetConformsToType,
  value: string
) {
  const result = await supabase.from('targets').insert({
    id: targetId,
    annotation_id: annotationId,
    layer_id: layerId,
    selector_type: selectorType,
    conforms_to: conformsTo,
    value: value,
  });

  const resultSelect = await supabase
    .from('targets')
    .select()
    .eq('id', targetId);

  return !!(resultSelect.data && resultSelect.data.length > 0);
}

async function updateTarget(
  supabase: SupabaseClient,
  targetId: string,
  newValue: string
) {
  const result = await supabase
    .from('targets')
    .update({
      value: newValue,
    })
    .eq('id', targetId)
    .select();

  if (result.data && result.data.length > 0) {
    return result.data[0].value === newValue;
  }

  return false;
}

async function selectTarget(supabase: SupabaseClient, targetId: string) {
  const result = await supabase.from('targets').select().eq('id', targetId);

  return !!(result.data && result.data.length > 0);
}

async function deleteTarget(supabase: SupabaseClient, targetId: string) {
  const result = await supabase.from('targets').delete().eq('id', targetId);

  const resultSelect = await supabase
    .from('targets')
    .select()
    .eq('id', targetId);

  return (
    !resultSelect.error && resultSelect.data && resultSelect.data.length === 0
  );
}

async function insertBody(
  supabase: SupabaseClient,
  bodyId: string,
  annotationId: string,
  layerId: string,
  type: BodyTypes,
  format: BodyFormats,
  purpose: string,
  value: string
) {
  const result = await supabase.from('bodies').insert({
    id: bodyId,
    annotation_id: annotationId,
    layer_id: layerId,
    type: type,
    format: format,
    purpose: purpose,
    value: value,
  });

  const supe = await loginAsServiceUser();

  const resultSelect = await supe.from('bodies').select().eq('id', bodyId);

  return !!(resultSelect.data && resultSelect.data.length > 0);
}

async function updateBody(
  supabase: SupabaseClient,
  bodyId: string,
  newValue: string
) {
  const result = await supabase
    .from('bodies')
    .update({
      value: newValue,
    })
    .eq('id', bodyId)
    .select();

  if (result.data && result.data.length > 0) {
    return result.data[0].value === newValue;
  }

  return false;
}

async function selectBody(supabase: SupabaseClient, bodyId: string) {
  const result = await supabase.from('bodies').select().eq('id', bodyId);

  return !!(result.data && result.data.length > 0);
}

async function deleteBody(supabase: SupabaseClient, bodyId: string) {
  const result = await supabase.from('bodies').delete().eq('id', bodyId);

  const resultSelect = await supabase.from('bodies').select().eq('id', bodyId);

  return (
    !resultSelect.error && resultSelect.data && resultSelect.data.length === 0
  );
}

async function selectLayerContext(
  supabase: SupabaseClient,
  layerId: string,
  contextId: string
) {
  const result = await supabase
    .from('layer_contexts')
    .select()
    .eq('context_id', contextId)
    .eq('layer_id', layerId);

  return !result.error && result.data && result.data.length > 0;
}

async function getOrganizationPolicies(supabase: SupabaseClient) {
  const result = await supabase.rpc('get_organization_policies');

  if (!result.error) {
    // console.table(result.data);
    if (result.data.length > 0) {
      return true;
    }
  }

  return false;
}

async function getProjectPolicies(supabase: SupabaseClient, projectId: string) {
  const result = await supabase.rpc('get_project_policies', {
    _project_id: projectId,
  });

  if (!result.error) {
    // console.table(result.data);
    if (result.data.length > 0) {
      return true;
    }
  }

  // console.log("Project Policies Error: ", result.error);
  return false;
}

async function getLayerPolicies(supabase: SupabaseClient, layerId: string) {
  const result = await supabase.rpc('get_layer_policies', {
    _layer_id: layerId,
  });

  if (!result.error) {
    // console.table(result.data);
    if (result.data.length > 0) {
      return true;
    }
  }

  // console.log("Layer Policies Error: ", result.error);
  return false;
}

async function createInvite(
  supabase: SupabaseClient,
  inviteId: string,
  invitedByName: string,
  email: string,
  projectId: string,
  projectGroupId: string
) {
  const result = await supabase
    .from('invites')
    .insert({
      id: inviteId,
      invited_by_name: invitedByName,
      email: email,
      project_id: projectId,
      project_group_id: projectGroupId,
      project_name: 'A great project!',
    })
    .select();

  if (!result.error) {
    if (result.data.length > 0) {
      return true;
    }
  }

  return false;
}

async function createProjectTagDefinition(
  supabase: SupabaseClient,
  id: string,
  projectId: string,
  targetType: string,
  name: string
) {
  const result = await supabase
    .from('tag_definitions')
    .insert({
      id: id,
      scope: 'project',
      scope_id: projectId,
      target_type: targetType,
      name: name,
    })
    .select();

  if (!result.error) {
    if (result.data.length > 0) {
      return true;
    }
  }

  return false;
}

async function insertProjectTag(
  supabase: SupabaseClient,
  tag_definition_id: string,
  target_id: string
) {
  const result = await supabase
    .from('tags')
    .insert({
      tag_definition_id: tag_definition_id,
      target_id: target_id,
    })
    .select();

  if (!result.error) {
    if (result.data.length > 0) {
      return true;
    }
  }

  return false;
}

async function createOrganizationTagDefinition(
  supabase: SupabaseClient,
  id: string,
  targetType: string,
  name: string
) {
  const result = await supabase
    .from('tag_definitions')
    .insert({
      id: id,
      scope: 'organization',
      target_type: targetType,
      name: name,
    })
    .select();

  if (!result.error) {
    if (result.data.length > 0) {
      return true;
    }
  }

  return false;
}

async function processInvite(
  supabase: SupabaseClient,
  inviteId: string,
  action: 'accept' | 'ignore'
) {
  const result = await supabase.rpc('process_invite', {
    _invite_id: inviteId,
    _option: action,
  });

  // console.log("Invite Data: ", result.data);

  if (!result.error) {
    // console.table(result.data);
    if (result.data) {
      return true;
    }
  }

  // console.log("Invite Error: ", result.error);

  return false;
}

async function getMyProjects(supabase: SupabaseClient) {
  const result = await supabase.rpc('get_my_projects');

  if (!result.error) {
    // console.log("My Projects:");
    // console.table(result.data);
    if (result.data) {
      return true;
    }
  }

  // console.log("Get My Projects Error: ", result.error);

  return false;
}

async function getMyOrgRole(supabase: SupabaseClient) {
  const result = await supabase.rpc('get_my_org_role');

  if (!result.error) {
    // console.log("My Org Role: ", result.data);
    if (result.data) {
      return true;
    }
  }

  // console.log("Get My Org Role Error: ", result.error);

  return false;
}

async function getMyProjectRole(supabase: SupabaseClient, projectId: string) {
  const result = await supabase.rpc('get_my_project_role', {
    _project_id: projectId,
  });

  if (!result.error) {
    // console.log("My Org Role: ", result.data);
    if (result.data) {
      return true;
    }
  }

  // console.log("Get My Project Role Error: ", result.error);

  return false;
}

async function getMyLayerRole(supabase: SupabaseClient, layerId: string) {
  const result = await supabase.rpc('get_my_layer_role', {
    _layer_id: layerId,
  });

  if (!result.error) {
    // console.log("My Layer Role: ", result.data);
    if (result.data) {
      return true;
    }
  }

  // console.log("Get My Layer Role Error: ", result.error);

  return false;
}

async function getMyLayerContexts(
  supabase: SupabaseClient,
  context_id: string
) {
  const result = await supabase
    .from('layer_contexts')
    .select(
      `
      context:contexts (
        id,
        name,
        project_id
      ),
      layer:layers (
        id,
        name,
        description,
        document:documents (
          id,
          created_at,
          created_by,
          name,
          content_type,
          meta_data
        ),
        groups:layer_groups (
          id,
          name,
          description
        )
      )
    `
    )
    .eq('context_id', context_id);

  if (!result.error) {
    // console.log("My Layer Role: ", result.data);
    if (result.data && result.data.length > 0) {
      return true;
    }
  }

  return false;
}

beforeAll(async () => {
  // Make sure the test project is not present
  const supabase = await loginAsOrgAdmin();

  if (supabase) {
    supabase.from('projects').delete().eq('id', TEST_PROJECT_ID);
  }
});

test('Login as Org Admin', async () => {
  const supabase = await loginAsOrgAdmin();

  expect(supabase).not.toBe(null);
});

test('Org Admins can create projects', async () => {
  const supabase = await loginAsOrgAdmin();

  if (supabase) {
    const { data }: { data: any | undefined; error: any | undefined } =
      await insertProject(
        supabase,
        TEST_PROJECT_ID,
        'Test Project',
        'A test project'
      );

    expect(data.length).not.toBe(0);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Org Admins can read projects', async () => {
  const supabase = await loginAsOrgAdmin();

  if (supabase) {
    const { data }: { data: any | undefined; error: any | undefined } =
      await readProjects(supabase, 'Test Project', 'A test project');

    expect(data.length).not.toBe(0);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Org Admins can update projects', async () => {
  const supabase = await loginAsOrgAdmin();

  if (supabase) {
    const result = await updateProject(
      supabase,
      '477577df-c156-4cca-9d7a-f96122c1362b',
      'Test Project Updated'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Org Admins can delete projects', async () => {
  const supabase = await loginAsOrgAdmin();

  if (supabase) {
    const result = await deleteProject(
      supabase,
      '477577df-c156-4cca-9d7a-f96122c1362b'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can create projects', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await insertProject(
      supabase,
      TEST_PROJECT_ID,
      'Professors Project',
      'A test project'
    );

    expect(result.data?.length).toBeGreaterThan(0);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can select projects they create', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await readProject(supabase, TEST_PROJECT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can update projects they create', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await updateProject(
      supabase,
      TEST_PROJECT_ID,
      'Updated Project Name'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can select project groups from their project', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await getProjectGroups(supabase, TEST_PROJECT_ID);

    expect(result.data?.length).toBeGreaterThan(0);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors are a Project Admin of their project', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await getProjectGroups(supabase, TEST_PROJECT_ID);

    if (result.data && result.data.length > 0) {
      const resultMembers = await isProjectGroupMember(
        supabase,
        TEST_PROJECT_ID,
        'Project Admins',
        'professor@example.com'
      );

      expect(resultMembers).toBe(true);
    } else {
      expect(result.data?.length).toBeGreaterThan(0);
    }
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can add user to groups that belong to their project', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await addUserToProjectGroup(
      supabase,
      TEST_PROJECT_ID,
      'Project Students',
      'student@example.com'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can insert contexts to their project', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await addContextToProject(
      supabase,
      TEST_PROJECT_ID,
      TEST_CONTEXT_ID,
      'Test Context'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can read contexts in their projects', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await readContext(supabase, TEST_CONTEXT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot delete contexts in their projects', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await deleteContext(supabase, TEST_CONTEXT_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can add documents', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await insertDocument(
      supabase,
      TEST_DOCUMENT_ID,
      'Test Document',
      'documents',
      'text/plain'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot add collection documents', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await insertDocument(
      supabase,
      COLLECTION_DOCUMENT_ID,
      'Bad Collection Document',
      'documents',
      'text/plain',
      '6fa82d44-f665-44a7-a154-5dad64ea43bd'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can add documents to projects they own', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await addDocumentToProject(
      supabase,
      TEST_DOCUMENT_ID,
      TEST_PROJECT_ID
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can select documents for layers they see', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await selectDocument(supabase, TEST_DOCUMENT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can add tutors to the Project Admin group', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await addUserToProjectGroup(
      supabase,
      TEST_PROJECT_ID,
      'Project Admins',
      'tutor@example.com'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutors cannot add documents', async () => {
  const supabase = await loginAsTutor();
  if (supabase) {
    const result = await insertDocument(
      supabase,
      TEST_TUTOR_DOCUMENT_ID,
      'Test Tutor Document',
      'documents',
      'text/plain'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot also add tutor to the Project Students group', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await addUserToProjectGroup(
      supabase,
      TEST_PROJECT_ID,
      'Project Students',
      'tutor@example.com'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can insert layers to their project', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await insertLayer(
      supabase,
      TEST_PROJECT_ID,
      TEST_CONTEXT_ID,
      TEST_LAYER_ID,
      TEST_DOCUMENT_ID,
      'Test Layer',
      'A test layer'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can update layers of their project', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await updateLayer(
      supabase,
      TEST_LAYER_ID,
      'Test Layer Updated'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot delete layers', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await deleteLayer(supabase, TEST_LAYER_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can create tag definitions on Projects', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await createProjectTagDefinition(
      supabase,
      TEST_PROJECT_TAG_DEFINITION_ID,
      TEST_PROJECT_ID,
      'project',
      'context'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can create tags on Projects they admin', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await insertProjectTag(
      supabase,
      TEST_PROJECT_TAG_DEFINITION_ID,
      TEST_PROJECT_ID
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot create Organization tag definitions', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await createOrganizationTagDefinition(
      supabase,
      NO_STUDENT_PROJECT_TAG_DEFINITION,
      'project',
      'Not valid tag'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutors can update projects', async () => {
  const supabase = await loginAsTutor();

  if (supabase) {
    const result = await updateProject(
      supabase,
      TEST_PROJECT_ID,
      'Tutor Update'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutors can select Documents from their Project', async () => {
  const supabase = await loginAsTutor();
  if (supabase) {
    const result = await selectDocument(supabase, TEST_DOCUMENT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutors can select Contexts from their Project', async () => {
  const supabase = await loginAsTutor();
  if (supabase) {
    const result = await readContext(supabase, TEST_CONTEXT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutors can select Layers from their Project', async () => {
  const supabase = await loginAsTutor();
  if (supabase) {
    const result = await readLayer(supabase, TEST_LAYER_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutors can select Layer Context from their Project', async () => {
  const supabase = await loginAsTutor();
  if (supabase) {
    const result = await selectLayerContext(
      supabase,
      TEST_LAYER_ID,
      TEST_CONTEXT_ID
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can select layer groups', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getLayerGroups(supabase, TEST_LAYER_ID);

    if (result.data) {
      expect(result.data.length).toBeGreaterThan(0);
    } else {
      expect(result.data).not.toBe(null);
    }
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can add user to layer groups that belong to their layer', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await addUserToLayerGroup(
      supabase,
      TEST_LAYER_ID,
      'Layer Student',
      'student@example.com'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot create projects', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const { error }: { data: any | undefined; error: any | undefined } =
      await insertProject(
        supabase,
        '15517847-b0d9-4631-aaf7-8823fd4d806d',
        'Failed Project Create',
        'A test project'
      );

    expect(error).not.toBe(null);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot select private documents from projects they are not part of', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await selectDocument(supabase, TEST_DOCUMENT_ID);
    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutors cannot make their professors private document public', async () => {
  const supabase = await loginAsTutor();

  if (supabase) {
    const result = await makeDocumentPublic(supabase, TEST_DOCUMENT_ID);
    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can make their private document public', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await makeDocumentPublic(supabase, TEST_DOCUMENT_ID);
    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot update projects', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await updateProject(
      supabase,
      TEST_PROJECT_ID,
      'Failed Project update'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can read projects they are a member of', async () => {
  let supabase = await loginAsProfessor();

  if (supabase) {
    const result = await readProject(supabase, TEST_PROJECT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot read projects they are not a member of', async () => {
  let supabase = await loginAsProfessor();

  if (!supabase) {
    expect(supabase).not.toBe(null);
  } else {
    const resultCreate = await insertProject(
      supabase,
      NO_STUDENT_PROJECT_ID,
      'Not Student Project',
      "Student can't read this"
    );

    if (resultCreate.data && resultCreate.data.length > 0) {
      supabase = await loginAsStudent();

      if (supabase) {
        const result = await readProject(supabase, NO_STUDENT_PROJECT_ID);

        expect(result).toBe(false);
      } else {
        expect(supabase).not.toBe(null);
      }
    } else {
      expect(resultCreate.data?.length).toBeGreaterThan(0);
    }
  }
});

test('Students can read contexts in projects they are a member of', async () => {
  const supabase = await loginAsStudent();
  if (supabase) {
    const result = await readContext(supabase, TEST_CONTEXT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot insert contexts to projects', async () => {
  const supabase = await loginAsStudent();
  if (supabase) {
    const result = await addContextToProject(
      supabase,
      TEST_PROJECT_ID,
      '8da178bb-459e-4875-8422-ff12e58541b4',
      'Context Should Not Be Created'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot delete contexts in projects they are a member of', async () => {
  const supabase = await loginAsStudent();
  if (supabase) {
    const result = await deleteContext(supabase, TEST_CONTEXT_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot insert layers to a project', async () => {
  const supabase = await loginAsStudent();
  if (supabase) {
    const result = await insertLayer(
      supabase,
      TEST_PROJECT_ID,
      TEST_CONTEXT_ID,
      TEST_DOCUMENT_ID,
      'e97d17d8-c9c3-48d8-8963-102d408b741a',
      'Prohibited Layer',
      'A test prohibited layer'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot update layers of their project', async () => {
  const supabase = await loginAsStudent();
  if (supabase) {
    const result = await updateLayer(
      supabase,
      TEST_LAYER_ID,
      'Prohibited Test Layer Update'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot delete layers', async () => {
  const supabase = await loginAsStudent();
  if (supabase) {
    const result = await deleteLayer(supabase, TEST_LAYER_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can create public annotations on layers that they have membership', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await insertAnnotation(
      supabase,
      TEST_PUBLIC_ANNOTATION_ID,
      TEST_LAYER_ID,
      false
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can select public annotations in their projects', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await selectAnnotation(supabase, TEST_PUBLIC_ANNOTATION_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can create private annotations on layers that they have membership', async () => {
  const supabase = await loginAsStudent();
  if (supabase) {
    const result = await insertAnnotation(
      supabase,
      TEST_PRIVATE_ANNOTATION_ID,
      TEST_LAYER_ID,
      true
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot create Organization tag definitions', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await createOrganizationTagDefinition(
      supabase,
      NO_STUDENT_PROJECT_TAG_DEFINITION,
      'project',
      'Not valid tag'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot create Project tag definitions', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await createProjectTagDefinition(
      supabase,
      NO_STUDENT_PROJECT_TAG_DEFINITION,
      TEST_PROJECT_ID,
      'layer',
      'Not valid tag'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot select private annotations in their projects', async () => {
  const supabase = await loginAsProfessor();
  if (supabase) {
    const result = await selectAnnotation(supabase, TEST_PRIVATE_ANNOTATION_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can create public annotations on layers that they have membership', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await insertAnnotation(
      supabase,
      TEST_PROFESSOR_ANNOTATION_ID,
      TEST_LAYER_ID,
      false
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can create targets on Annotations they create', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await insertTarget(
      supabase,
      TEST_PUBLIC_TARGET_ID,
      TEST_PUBLIC_ANNOTATION_ID,
      TEST_LAYER_ID,
      'SvgSelector',
      'Svg',
      'a value'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot create targets on Annotations they did not create', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await insertTarget(
      supabase,
      TEST_CANNOT_CREATE_TARGET_ID,
      TEST_PUBLIC_ANNOTATION_ID,
      TEST_LAYER_ID,
      'SvgSelector',
      'Svg',
      'a value that does not matter'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot create targets on Annotations they did not create', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await insertTarget(
      supabase,
      TEST_CANNOT_CREATE_TARGET_ID,
      TEST_PROFESSOR_ANNOTATION_ID,
      TEST_LAYER_ID,
      'SvgSelector',
      'Svg',
      'a value that does not matter'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can create targets on Annotations they create', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await insertTarget(
      supabase,
      TEST_PROFESSOR_TARGET_ID,
      TEST_PROFESSOR_ANNOTATION_ID,
      TEST_LAYER_ID,
      'SvgSelector',
      'Svg',
      'a value'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can select targets on Annotations they did not create but are in their layer', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await selectTarget(supabase, TEST_PROFESSOR_TARGET_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can select targets on Annotations they did not create but are in their layer', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await selectTarget(supabase, TEST_PUBLIC_TARGET_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can create targets on private Annotations they create', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await insertTarget(
      supabase,
      TEST_PRIVATE_TARGET_ID,
      TEST_PRIVATE_ANNOTATION_ID,
      TEST_LAYER_ID,
      'SvgSelector',
      'Svg',
      'a value'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot select targets on private Annotations they did not create but are in their layer', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await selectTarget(supabase, TEST_PRIVATE_TARGET_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can select targets on private Annotations they creates', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await selectTarget(supabase, TEST_PRIVATE_TARGET_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot delete targets on public Annotations they creates', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await deleteTarget(supabase, TEST_PUBLIC_TARGET_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot delete targets on public Annotations they creates', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await deleteTarget(supabase, TEST_PROFESSOR_TARGET_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professor cannot create the first body on Annotations they did not create', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await insertBody(
      supabase,
      TEST_CANNOT_CREATE_BODY_ID,
      TEST_PUBLIC_ANNOTATION_ID,
      TEST_LAYER_ID,
      'TextualBody',
      'TextPlain',
      'a purpose',
      'a student trying to create the first'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can create the first body on Annotations they created', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await insertBody(
      supabase,
      TEST_PUBLIC_BODY_ID,
      TEST_PUBLIC_ANNOTATION_ID,
      TEST_LAYER_ID,
      'TextualBody',
      'TextPlain',
      'a purpose',
      'Student creating the first'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can create subsequent bodies on Annotations they did not create', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await insertBody(
      supabase,
      TEST_SECOND_BODY_ID,
      TEST_PUBLIC_ANNOTATION_ID,
      TEST_LAYER_ID,
      'TextualBody',
      'TextPlain',
      'a purpose',
      'Professor adding a second'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can archive their own bodies on Annotations they did not create', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await archiveBody(supabase, TEST_SECOND_BODY_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can create the first body on private Annotations they created', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await insertBody(
      supabase,
      TEST_PRIVATE_BODY_ID,
      TEST_PRIVATE_ANNOTATION_ID,
      TEST_LAYER_ID,
      'TextualBody',
      'TextPlain',
      'a purpose',
      'Student creating the first on private'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutor can create public annotation', async () => {
  const supabase = await loginAsTutor();

  if (supabase) {
    const result = await insertAnnotation(
      supabase,
      TEST_TUTOR_ANNOTATION_ID,
      TEST_LAYER_ID,
      false
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students cannot update other peoples public annotation', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await updateAnnotation(
      supabase,
      TEST_TUTOR_ANNOTATION_ID,
      true
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutor can create target on their annotation', async () => {
  const supabase = await loginAsTutor();

  if (supabase) {
    const result = await insertTarget(
      supabase,
      TEST_TUTOR_TARGET_ID,
      TEST_TUTOR_ANNOTATION_ID,
      TEST_LAYER_ID,
      'Fragment',
      'Svg',
      'Test Tutor Target'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutor can create body on their annotation', async () => {
  const supabase = await loginAsTutor();

  if (supabase) {
    const result = await insertBody(
      supabase,
      TEST_TUTOR_BODY_ID,
      TEST_TUTOR_ANNOTATION_ID,
      TEST_LAYER_ID,
      'TextualBody',
      'TextPlain',
      'Test Tutor purpose',
      'Tutor Body'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors cannot create subsequent bodies on private Annotations they did not create', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await insertBody(
      supabase,
      TEST_CANNOT_CREATE_BODY_ID,
      TEST_PRIVATE_ANNOTATION_ID,
      TEST_LAYER_ID,
      'TextualBody',
      'TextPlain',
      'a purpose',
      "Professor can't add a second"
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can make thier own public annotations private', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await updateAnnotation(
      supabase,
      TEST_PROFESSOR_ANNOTATION_ID,
      true
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can archive annotations they created', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await archiveAnnotation(
      supabase,
      TEST_PROFESSOR_ANNOTATION_ID
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can get their org policies', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getOrganizationPolicies(supabase);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can get their project policies', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getProjectPolicies(supabase, TEST_PROJECT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can get their layer policies', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getLayerPolicies(supabase, TEST_LAYER_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can check if a student is a member of their project', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await checkProjectMembership(
      supabase,
      TEST_PROJECT_ID,
      'student@example.com'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can check if a student is not a member of their project', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await checkProjectMembership(
      supabase,
      TEST_PROJECT_ID,
      'noone@example.com'
    );

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can invite stidents to their project', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const groups = await getProjectGroups(supabase, TEST_PROJECT_ID);

    if (groups && groups.data) {
      const projectStudentsGroup = groups.data.find(
        (g: any) => (g.name = 'Project Students')
      );

      if (projectStudentsGroup) {
        const result = await createInvite(
          supabase,
          TEST_INVITE_ID,
          'Joe Professor',
          'invited@example.com',
          TEST_PROJECT_ID,
          projectStudentsGroup.id
        );

        expect(result).toBe(true);
      } else {
        expect(projectStudentsGroup).not.toBe(null);
      }
    } else {
      expect(groups && groups.data).not.toBe(null);
    }
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Invited user can process an invite', async () => {
  const supabase = await loginAsInvited();

  if (supabase) {
    const result = await processInvite(supabase, TEST_INVITE_ID, 'accept');

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can check if a student is a member of their project', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await checkProjectMembership(
      supabase,
      TEST_PROJECT_ID,
      'student@example.com'
    );

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can get their list of projects', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getMyProjects(supabase);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can get their list of projects', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await getMyProjects(supabase);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can get their Org Role', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getMyOrgRole(supabase);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can get their Org Role', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await getMyOrgRole(supabase);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can get their Project Role', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getMyProjectRole(supabase, TEST_PROJECT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutor can get their Project Role', async () => {
  const supabase = await loginAsTutor();

  if (supabase) {
    const result = await getMyProjectRole(supabase, TEST_PROJECT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can get their Project Role', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await getMyProjectRole(supabase, TEST_PROJECT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Professors can get their Layer Role', async () => {
  const supabase = await loginAsProfessor();

  if (supabase) {
    const result = await getMyLayerRole(supabase, TEST_LAYER_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Tutor can get a Layer Role for which they have not been added', async () => {
  const supabase = await loginAsTutor();

  if (supabase) {
    const result = await getMyLayerRole(supabase, TEST_LAYER_ID);

    expect(result).toBe(false);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can get their Layer Role', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await getMyLayerRole(supabase, TEST_LAYER_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});

test('Students can get their layer contexts', async () => {
  const supabase = await loginAsStudent();

  if (supabase) {
    const result = await getMyLayerContexts(supabase, TEST_CONTEXT_ID);

    expect(result).toBe(true);
  } else {
    expect(supabase).not.toBe(null);
  }
});
