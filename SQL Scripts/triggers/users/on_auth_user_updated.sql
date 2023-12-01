DROP TRIGGER IF EXISTS on_auth_user_updated
    ON auth.users;
CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE
    ON auth.users
    FOR EACH ROW
EXECUTE FUNCTION update_user();
