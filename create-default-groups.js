const { createClient } = require('@supabase/supabase-js');
const commandLineArgs = require('command-line-args');
const fs = require('fs');

const main = async (options) => {
  let supabase = createClient(
    process.env.SUPABASE_HOST,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    }
  );

  /*
  const {data, error } = await supabase.from('policies').select();
  console.table(data);
   */

  let config;
  try {
    const configStr = fs.readFileSync(options.file, 'utf8');
    config = JSON.parse(configStr);
  } catch (err) {
    process.exitCode = 1;
    console.error(err);
    return;
  }

  // console.info(JSON.stringify(config, null, 2));

  // Create the policies
  let policiesInserts = [];
  config.policies.forEach((policy) => {
    policiesInserts.push({
      id: policy.id,
      table_name: policy.table_name,
      operation: policy.operation,
    });
  });

  const policiesResponse = await supabase
    .from('policies')
    .upsert(policiesInserts)
    .select();

  console.info('Policies:');
  console.table(policiesResponse.data);

  // Create the roles
  let rolesInsert = [];
  let rolePoliciesInsert = [];
  config.roles.forEach((role) => {
    rolesInsert.push({
      id: role.id,
      name: role.name,
      description: role.description,
    });
    role.policies.forEach((rolePolicyId) => {
      rolePoliciesInsert.push({
        role_id: role.id,
        policy_id: rolePolicyId,
      });
    });
  });

  const rolesResponse = await supabase
    .from('roles')
    .upsert(rolesInsert)
    .select();
  const rolePolicesResponse = await supabase
    .from('role_policies')
    .upsert(rolePoliciesInsert, { onConflict: 'role_id, policy_id' })
    .select();

  console.info('Roles:');
  console.table(rolesResponse.data);
  console.info('Role Policies:');
  console.table(rolePolicesResponse.data);

  // Create Organization Groups
  let organizationGroupInserts = [];
  config.org_groups.forEach((orgGroup) => {
    organizationGroupInserts.push({
      id: orgGroup.id,
      role_id: orgGroup.role_id,
      name: orgGroup.name,
      description: orgGroup.description,
      is_admin: orgGroup.is_admin,
      is_default: orgGroup.is_default,
      is_read_only: orgGroup.is_read_only
    });
  });

  const orgGroupsResponse = await supabase
    .from('organization_groups')
    .upsert(organizationGroupInserts, {
      onConflict: 'role_id',
      ignoreDuplicates: false,
    });

  if (orgGroupsResponse.error) {
    process.exitCode = 1;
    console.error('Failed to create organization_groups');
    console.error(orgGroupsResponse.error);
  }

  const orgAdminGroup = organizationGroupInserts.find(
    (g) => g.is_admin === true
  );

  console.log('Org group: ', orgAdminGroup)

  const getOrgAdminResponse = await supabase
    .from('organization_groups')
    .select()
    .eq('id', orgAdminGroup.id);

  console.info('Organization Admin Group: ');
  console.table(getOrgAdminResponse.data);

  // Retrieve the Admin Profile
  let orgAdminProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', config.admin.admin_email);

  // if no Admin found, create one
  if (orgAdminProfile.data.length === 0) {
    supabase = createClient(
      process.env.SUPABASE_HOST,
      process.env.SUPABASE_SERVICE_KEY,
      {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
          detectSessionInUrl: false,
        },
      }
    );
    // Create the Admin user
    const createAdminUserResponse = await supabase.auth.admin.createUser({
      email: config.admin.admin_email,
      password: process.env.ORG_ADMIN_PW,
      email_confirm: true,
    });

    if (createAdminUserResponse.error) {
      console.log('Error creating org admin: ', createAdminUserResponse.error);
    }

    supabase = createClient(
      process.env.SUPABASE_HOST,
      process.env.SUPABASE_SERVICE_KEY,
      {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
          detectSessionInUrl: false,
        },
      }
    );

    orgAdminProfile = await supabase
      .from('profiles')
      .select()
      .eq('email', config.admin.admin_email);
  }

  console.info('Organization Admin:');
  console.info(JSON.stringify(orgAdminProfile.data[0], null, 2));

  const adminId = orgAdminProfile.data[0].id;
  const adminGroupId = getOrgAdminResponse.data[0].id;

  // Move the Admin's organization membership to the admin group. Only the
  // organization rows are touched, and only if the Admin isn't already in it.
  const adminMembershipResponse = await supabase
    .from('group_users')
    .select()
    .eq('user_id', adminId)
    .eq('group_type', 'organization')
    .eq('type_id', adminGroupId);

  if (adminMembershipResponse.error) {
    process.exitCode = 1;
    console.error('Failed to retrieve Admin group membership');
    console.error(adminMembershipResponse.error);
  } else if (adminMembershipResponse.data.length === 0) {
    let groupAddResponse = await supabase
      .from('group_users')
      .update({ type_id: adminGroupId })
      .eq('user_id', adminId)
      .eq('group_type', 'organization')
      .select();

    if (!groupAddResponse.error && groupAddResponse.data.length === 0) {
      // No organization membership yet, so create one
      groupAddResponse = await supabase
        .from('group_users')
        .insert({
          user_id: adminId,
          group_type: 'organization',
          type_id: adminGroupId,
        })
        .select();
    }

    if (groupAddResponse.error) {
      process.exitCode = 1;
      console.error('Failed to add Admin to group: ', adminGroupId);
      console.error(groupAddResponse.error);
    }
  }

  // Create the default groups table
  let defaultGroups = [];
  config.project_groups.forEach((group) => {
    defaultGroups.push({
      id: group.id,
      group_type: 'project',
      name: group.name,
      description: group.description,
      role_id: group.role_id,
      is_admin: !!group.is_admin,
      is_default: !!group.is_default,
      is_read_only: !!group.is_read_only
    });
  });
  config.layer_groups.forEach((group) => {
    defaultGroups.push({
      id: group.id,
      group_type: 'layer',
      name: group.name,
      description: group.description,
      role_id: group.role_id,
      is_admin: !!group.is_admin,
      is_default: !!group.is_default,
      is_read_only: !!group.is_read_only
    });
  });

  const defaultGroupsResponse = await supabase
    .from('default_groups')
    .upsert(defaultGroups, { ignoreDuplicates: false, onConflict: 'id' })
    .select();
  if (defaultGroupsResponse.error) {
    process.exitCode = 1;
    console.error('Failed to create default_groups');
  } else {
    console.info('Default Groups:');
    console.table(defaultGroupsResponse.data);
  }

  // Now check for deletions
  // rolePoliciesInsert
  const remoteRolesPolicies = await supabase.from('role_policies').select();

  if (remoteRolesPolicies.error) {
    process.exitCode = 1;
    console.error('Failed to retrieve Roles');
  } else {
    for (let i = 0; i < remoteRolesPolicies.data.length; i++) {
      const rolePolicy = remoteRolesPolicies.data[i];
      const findIdx = rolePoliciesInsert.findIndex(
        (r) =>
          r.role_id === rolePolicy.role_id &&
          r.policy_id === rolePolicy.policy_id
      );
      if (findIdx === -1) {
        const deleteRolePolicyResp = await supabase
          .from('role_policies')
          .delete()
          .eq('role_id', rolePolicy.role_id)
          .eq('policy_id', rolePolicy.policy_id);

        if (deleteRolePolicyResp.error) {
          process.exitCode = 1;
          console.error('Failed to delete role_policy');
        }
      }
    }
  }

  // rolesInsert
  const remoteRoles = await supabase.from('roles').select();

  if (remoteRoles.error) {
    process.exitCode = 1;
    console.error('Failed to retrieve Roles');
  } else {
    for (let i = 0; i < remoteRoles.data.length; i++) {
      const role = remoteRoles.data[i];
      const findIdx = rolesInsert.findIndex((r) => r.id === role.id);
      if (findIdx === -1) {
        const deleteRoleResp = await supabase
          .from('roles')
          .delete()
          .eq('id', role.id);

        if (deleteRoleResp.error) {
          process.exitCode = 1;
          console.error('Failed to role');
        }
      }
    }
  }

  // organizationGroupInserts
  const remoteOrgGroups = await supabase.from('organization_groups').select();

  if (remoteOrgGroups.error) {
    process.exitCode = 1;
    console.error('Failed to retrieve Org Groups');
  } else {
    for (let i = 0; i < remoteOrgGroups.data.length; i++) {
      const group = remoteOrgGroups.data[i];
      const findIdx = organizationGroupInserts.findIndex(
        (og) => og.role_id === group.role_id
      );
      if (findIdx === -1) {
        const deleteGroupResp = await supabase
          .from('organization_groups')
          .delete()
          .eq('role_id', group.role_id);

        if (deleteGroupResp.error) {
          process.exitCode = 1;
          console.error('Failed to delete Org Group');
        }
      }
    }
  }

  // Make sure we have the 'documents' and 'jobs' buckets
  await ensureBucket(supabase, 'documents');
  await ensureBucket(supabase, 'jobs');

  // Make sure we have a DEFAULT_CONTEXT tag_definition
  const tagCreateResp = await supabase.from('tag_definitions').upsert({
    id: process.env.DEFAULT_CONTEXT_ID,
    name: 'DEFAULT_CONTEXT',
    target_type: 'context',
    scope: 'system',
  });

  if (tagCreateResp.error) {
    process.exitCode = 1;
    console.error('Failed to create DEFAULT_CONTEXT tag_definition: ', tagCreateResp.error);
  }
};

// Storage reports a missing bucket as HTTP 404, or as HTTP 400 with a '404' statusCode in the body
const isNotFound = (error) =>
  error.status === 404 || String(error.statusCode) === '404';

const ensureBucket = async (supabase, id) => {
  const { error: getError } = await supabase.storage.getBucket(id);

  if (!getError) {
    return;
  }

  if (!isNotFound(getError)) {
    process.exitCode = 1;
    console.error(`Failed to retrieve ${id} bucket: `, getError);
    return;
  }

  const { error } = await supabase.storage.createBucket(id, {
    public: false
  });

  if (error) {
    process.exitCode = 1;
    console.error(`Failed to create ${id} bucket: `, error);
  }
};

const optionDefinitions = [
  { name: 'file', alias: 'f', type: String },
  { name: 'admin-id', alias: 'i', type: String },
  { name: 'admin-group-id', alias: 'g', type: String },
];

const options = commandLineArgs(optionDefinitions);

main(options);
