\set ON_ERROR_STOP on
BEGIN;
INSERT INTO core.number_sequence (
    sequence_code, prefix, next_value, display_width, updated_at, updated_by_principal_code
) VALUES ('TEST_ORDER', 'T-', 41, 6, clock_timestamp(), 'DATABASE_BUILD');
DO $pfd$
DECLARE
    first_number text;
    second_number text;
BEGIN
    first_number := core.allocate_business_number('TEST_ORDER', 'DATABASE_BUILD');
    second_number := core.allocate_business_number('TEST_ORDER', 'DATABASE_BUILD');
    IF first_number <> 'T-000041' OR second_number <> 'T-000042' THEN
        RAISE EXCEPTION 'Unexpected allocation results: %, %', first_number, second_number;
    END IF;
    IF (SELECT next_value FROM core.number_sequence WHERE sequence_code = 'TEST_ORDER') <> 43 THEN
        RAISE EXCEPTION 'Sequence state did not advance atomically';
    END IF;
END
$pfd$;
ROLLBACK;
\echo test_number_allocation passed
