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
    options: {
      data: {
        first_name: 'Prof',
        last_name: 'Prof'
      }
    }    
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

  const groupUserResp = await supabase
    .from('group_users')
    .update({
      type_id: orgProfessorGroupResp.data[0].id,
    })
    .eq('user_id', professorProfile.data[0].id);

  assert(groupUserResp.error === null);

  await supabase.auth.signUp({
    email: 'student@example.com',
    password: process.env.STUDENT_PW,
    options: {
      data: {
        first_name: 'Student',
        last_name: 'Student'
      }
    }      
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

  await supabase.auth.signUp({
    email: 'tutor@example.com',
    password: process.env.TUTOR_PW,
    options: {
      data: {
        first_name: 'Tutor',
        last_name: 'Tutor'
      }
    }  
  });

  const tutorProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', 'tutor@example.com');
  console.table(tutorProfile.data[0]);

  await supabase.auth.signUp({
    email: 'reader@example.com',
    password: process.env.READER_PW,
    options: {
      data: {
        first_name: 'Tutor',
        last_name: 'Tutor'
      }
    }      
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

  await supabase.auth.signUp({
    email: 'invited@example.com',
    password: process.env.INVITE_PW,
    options: {
      data: {
        first_name: 'Invited',
        last_name: 'Invited'
      }
    }      
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
};

const optionDefinitions = [
  { name: 'file', alias: 'f', type: String },
  { name: 'admin-id', alias: 'i', type: String },
  { name: 'admin-group-id', alias: 'g', type: String },
];

const options = commandLineArgs(optionDefinitions);

main(options);
