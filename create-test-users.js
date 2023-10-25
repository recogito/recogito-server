const Supa = require('@supabase/supabase-js');
const commandLineArgs = require('command-line-args');
const fs = require('fs');
const stream = require('stream');
const assert = require('assert');

const main = async (options) => {
  let supabase = Supa.createClient(
    process.env.SUPABASE_HOST,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
      },
    }
  );

  let config;
  try {
    const configStr = fs.readFileSync(options.file, 'utf8');
    config = JSON.parse(configStr);
  } catch (err) {
    console.error(err);
    return;
  }

  await supabase.auth.signUp({
    email: 'professor@example.com',
    password: process.env.PROFESSOR_PW,
  });

  supabase = Supa.createClient(
    process.env.SUPABASE_HOST,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: { persistSession: false },
    }
  );

  const professorProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', 'professor@example.com');
  console.table(professorProfile.data[0]);

  // Add her to the Org Professors group
  const orgProfessorGroupResp = await supabase
    .from('organization_groups')
    .select()
    .eq('id', process.env.PROFESSOR_GROUP_ID);

  const groupUserResp = await supabase.from('group_users').insert({
    type_id: orgProfessorGroupResp.data[0].id,
    user_id: professorProfile.data[0].id,
    group_type: 'organization',
  });

  assert(groupUserResp.error === null);

  await supabase.auth.signUp({
    email: 'student@example.com',
    password: process.env.STUDENT_PW,
  });

  supabase = Supa.createClient(
    process.env.SUPABASE_HOST,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: { persistSession: false },
    }
  );

  const studentProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', 'student@example.com');
  console.table(studentProfile.data[0]);

  // Add him to the Org Readers group
  const orgReadersGroupResp = await supabase
    .from('organization_groups')
    .select()
    .eq('id', process.env.STUDENT_GROUP_ID);

  const groupReaderResp = await supabase.from('group_users').insert({
    type_id: orgReadersGroupResp.data[0].id,
    user_id: studentProfile.data[0].id,
    group_type: 'organization',
  });

  await supabase.auth.signUp({
    email: 'tutor@example.com',
    password: process.env.TUTOR_PW,
  });

  const tutorProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', 'tutor@example.com');
  console.table(tutorProfile.data[0]);

  // Add him to the Org Readers group
  supabase = Supa.createClient(
    process.env.SUPABASE_HOST,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: { persistSession: false },
    }
  );

  const groupTutorResp = await supabase.from('group_users').insert({
    type_id: orgReadersGroupResp.data[0].id,
    user_id: tutorProfile.data[0].id,
    group_type: 'organization',
  });

  await supabase.auth.signUp({
    email: 'reader@example.com',
    password: process.env.READER_PW,
  });

  supabase = Supa.createClient(
    process.env.SUPABASE_HOST,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: { persistSession: false },
    }
  );

  const readerProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', 'reader@example.com');
  console.table(readerProfile.data[0]);

  // Add him to the Org Readers group
  const groupDefaultResp = await supabase.from('group_users').insert({
    type_id: orgReadersGroupResp.data[0].id,
    user_id: readerProfile.data[0].id,
    group_type: 'organization',
  });

  await supabase.auth.signUp({
    email: 'invited@example.com',
    password: process.env.INVITE_PW,
  });

  supabase = Supa.createClient(
    process.env.SUPABASE_HOST,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: { persistSession: false },
    }
  );

  const inviteProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', 'invited@example.com');
  console.table(inviteProfile.data[0]);

  // Add him to the Org Readers group
  const inviteDefaultResp = await supabase.from('group_users').insert({
    type_id: orgReadersGroupResp.data[0].id,
    user_id: inviteProfile.data[0].id,
    group_type: 'organization',
  });
};

const optionDefinitions = [
  { name: 'file', alias: 'f', type: String },
  { name: 'admin-id', alias: 'i', type: String },
  { name: 'admin-group-id', alias: 'g', type: String },
];

const options = commandLineArgs(optionDefinitions);

main(options);
