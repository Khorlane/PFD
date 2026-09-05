DO $pfd$
DECLARE
    actual_count integer;
BEGIN
    IF to_regclass('core.database_change') IS NULL THEN
        RAISE EXCEPTION 'core.database_change does not exist';
    END IF;
    SELECT count(*) INTO actual_count FROM core.database_change;
    IF actual_count <> 10 THEN
        RAISE EXCEPTION 'Expected 10 applied changes; found %', actual_count;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM core.database_change WHERE change_number = '0010') THEN
        RAISE EXCEPTION 'Final change 0010 is not recorded';
    END IF;
END
$pfd$;
