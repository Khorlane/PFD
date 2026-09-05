\set ON_ERROR_STOP on
BEGIN;
DO $pfd$
BEGIN
  BEGIN
    INSERT INTO core.unit_of_measure (
      unit_code, unit_name, unit_class_code, decimal_scale,
      created_at, created_by_principal_code, updated_at, updated_by_principal_code
    ) VALUES (
      'TEST_UNIT', 'Test Unit', 'NOT_A_CLASS', 0,
      clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD'
    );
    RAISE EXCEPTION 'Invalid foreign key was accepted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;
END
$pfd$;
ROLLBACK;
\echo test_foreign_keys passed
