#### Roles

[Discussion on Suprabase](https://github.com/orgs/supabase/discussions/11948#discussioncomment-4802137)

Thanks everyone, that was some team effort!
So to recap the answer from the discussion:

Create a new role
~~~~
CREATE ROLE new_role_1;
~~~~

Grant privileged access to the role to authenticator

~~~~
GRANT new_role_1 TO authenticator;
~~~~

Change the role for a user in auth.users

~~~~
UPDATE auth.users SET role = 'new_role_1' WHERE id = <some-user-uuid>
~~~~

On the next log in (or jwt refresh?) of the user, he will have the new role in its JWT and the subsequent DB queries

And voilà.

### Implications

I believe we can do this with a stored procedure but there may be implications I cannot know yet.





