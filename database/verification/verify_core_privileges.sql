DO $pfd$
BEGIN
    IF has_schema_privilege('public', 'core', 'CREATE') THEN
        RAISE EXCEPTION 'PUBLIC must not have CREATE on Core';
    END IF;
    IF has_table_privilege('pfd_application', 'core.database_change', 'INSERT,UPDATE,DELETE') THEN
        RAISE EXCEPTION 'Application role must not write database change history';
    END IF;
    IF has_table_privilege('pfd_application', 'core.number_sequence', 'UPDATE') THEN
        RAISE EXCEPTION 'Application role must allocate numbers only through the function';
    END IF;
    IF NOT has_function_privilege('pfd_application', 'core.allocate_business_number(text,text)', 'EXECUTE') THEN
        RAISE EXCEPTION 'Application role lacks business-number allocator permission';
    END IF;
END
$pfd$;
