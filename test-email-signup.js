const Supa = require('@supabase/supabase-js');

const EMAIL = 'lorin+invite1@performantsoftware.com';

const main = async () => {
  const supabase = await Supa.createClient(process.env.SUPABASE_TEST_HOST, process.env.SUPABASE_TEST_SERVICE_KEY);

  const inviteResp = await supabase.auth.admin.inviteUserByEmail(EMAIL);

  if (inviteResp.error) {
    console.log('Failed to invite user ', EMAIL);
  } else {
    console.log('Success!!');
  }
}

main();