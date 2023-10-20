
DROP TRIGGER IF EXISTS on_auth_user_created
    ON auth.users;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();

DROP TRIGGER IF EXISTS on_auth_user_updated
    ON auth.users;

CREATE TRIGGER on_auth_user_updated AFTER UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION update_user();


