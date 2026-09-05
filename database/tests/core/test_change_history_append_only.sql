\set ON_ERROR_STOP on
BEGIN;
DO $pfd$
BEGIN
  BEGIN
    UPDATE core.database_change SET notes = 'not permitted' WHERE change_number = '0001';
    RAISE EXCEPTION 'Database change history accepted an update';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM = 'Database change history accepted an update' THEN
      RAISE;
    END IF;
  END;
END
$pfd$;
ROLLBACK;
\echo test_change_history_append_only passed
