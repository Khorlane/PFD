\set ON_ERROR_STOP on
BEGIN;
DO $pfd$
BEGIN
  BEGIN
    INSERT INTO core.company (
      company_code, legal_name, display_name, default_currency_code, business_timezone,
      fiscal_year_start_month, created_at, created_by_principal_code,
      updated_at, updated_by_principal_code
    ) VALUES (
      'BAD-CODE', 'Invalid Test', 'Invalid Test', 'US', 'America/New_York', 13,
      clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD'
    );
    RAISE EXCEPTION 'Invalid checked values were accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END
$pfd$;
ROLLBACK;
\echo test_check_constraints passed
