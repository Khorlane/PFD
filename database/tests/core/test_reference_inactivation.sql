\set ON_ERROR_STOP on
BEGIN;
UPDATE core.unit_of_measure
   SET is_active = false, updated_at = clock_timestamp(),
       updated_by_principal_code = 'DATABASE_BUILD', row_version = row_version + 1
 WHERE unit_code = 'CASE';
DO $pfd$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM core.unit_of_measure WHERE unit_code = 'CASE' AND NOT is_active) THEN
        RAISE EXCEPTION 'Reference row could not be inactivated in place';
    END IF;
END
$pfd$;
ROLLBACK;
\echo test_reference_inactivation passed
