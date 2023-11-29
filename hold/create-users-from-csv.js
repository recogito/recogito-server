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

  const orgProfessorGroupResp = await supabase
    .from('organization_groups')
    .select()
    .eq('id', process.env.PROFESSOR_GROUP_ID);

  let str;
  try {
    str = fs.readFileSync(options.file, 'utf8');
  } catch (err) {
    console.error(err);
    return;
  }

  const arr = str.split(/\r?\n/);

  console.log(arr);

  for (let i = 0; i < arr.length; i++) {
    const username = arr[i];
    if (username.length > 0) {
      supabase = Supa.createClient(
        process.env.SUPABASE_HOST,
        process.env.SUPABASE_SERVICE_KEY,
        {
          auth: { persistSession: false },
        }
      );

      const resp = await supabase.auth.admin.createUser({
        email: username,
        password: process.env.SHARED_PASSWORD,
      });

      if (!resp.error) {
        console.log(`Login successfully created for user ${username}`);

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

        const profile = await supabase
          .from('profiles')
          .select()
          .eq('email', username);

        // Add her to the Org Professors group
        const groupUserResp = await supabase.from('group_users').insert({
          type_id: orgProfessorGroupResp.data[0].id,
          user_id: profile.data[0].id,
          group_type: 'organization',
        });

        assert(groupUserResp.error === null);

        console.log(`User ${username} added to Org Professor Group`);
      } else {
        console.error(
          `Unable to create user: ${username}, error: ${resp.error}`
        );
      }
    }
  }
};

const optionDefinitions = [{ name: 'file', alias: 'f', type: String }];

const options = commandLineArgs(optionDefinitions);

main(options);
