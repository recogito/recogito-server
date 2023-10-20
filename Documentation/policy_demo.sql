CREATE FUNCTION can_update() RETURNS trigger AS
$can_update$
DECLARE
    owner_id varchar := tg_argv[0];
    context uuid := tg_argv[1];
    group_row groups%ROWTYPE;
BEGIN
    SELECT * INTO group_row FROM groups WHERE context := context;
END;

$can_update$
    LANGUAGE plpgsql;
