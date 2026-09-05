DO $pfd$
DECLARE
    table_name text;
BEGIN
    FOREACH table_name IN ARRAY ARRAY[
        'database_change', 'principal_type', 'unit_class', 'business_area',
        'transaction_type', 'role_code', 'principal', 'company',
        'unit_of_measure', 'approval_authority', 'number_sequence'
    ]
    LOOP
        IF to_regclass(format('core.%I', table_name)) IS NULL THEN
            RAISE EXCEPTION 'Expected Core table is missing: %', table_name;
        END IF;
    END LOOP;
END
$pfd$;
