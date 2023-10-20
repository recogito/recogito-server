
import {createClient, SupabaseClient} from '@supabase/supabase-js'

export function initializeLocalClient() {
  return createClient('http://localhost:54321', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0');
}

export async function loginAsOrgAdmin() {

  const supabase = initializeLocalClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: 'admin@performantsoftware.com',
    password: process.env.LOCAL_ADMIN_PW || "",
  });

  if(!error && data.session?.access_token) {
    return createClient('http://localhost:54321',data.session?.access_token as string)
  }

  return null;
}

export async function loginAsStudent() {

  const supabase = initializeLocalClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: 'student@example.com',
    password: process.env.STUDENT_PW || "",
  });

  if(!error && data.session?.access_token) {
    return createClient('http://localhost:54321',data.session?.access_token as string)
  }

  return null;
}

export async function loginAsProfessor() {

  const supabase = initializeLocalClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: 'professor@example.com',
    password: process.env.PROFESSOR_PW || "",
  });

  if(!error && data.session?.access_token) {
    return createClient('http://localhost:54321',data.session?.access_token as string)
  }

  return null;
}

export async function loginAsTutor() {

  const supabase = initializeLocalClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: 'tutor@example.com',
    password: process.env.TUTOR_PW || "",
  });

  if(!error && data.session?.access_token) {
    return createClient('http://localhost:54321',data.session?.access_token as string)
  }

  return null;
}

export async function loginAsInvited() {

  const supabase = initializeLocalClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: 'invited@example.com',
    password: process.env.INVITE_PW || "",
  });

  if(!error && data.session?.access_token) {
    return createClient('http://localhost:54321',data.session?.access_token as string)
  }

  return null;
}

export async function loginAsServiceUser() {
  return createClient('http://localhost:54321', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU');
}

