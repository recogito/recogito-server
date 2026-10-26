const Supa = require('@supabase/supabase-js');
const assert = require('assert');

const main = async () => {
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
  });

  const tutorProfile = await supabase
    .from('profiles')
    .select()
    .eq('email', 'tutor@example.com');
  console.table(tutorProfile.data[0]);

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
};

main();
