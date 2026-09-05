\set ON_ERROR_STOP on
DO $pfd$
BEGIN
    IF has_table_privilege('pfd_application', 'core.database_change', 'INSERT,UPDATE,DELETE') THEN
        RAISE EXCEPTION 'Application role has prohibited change-history write privilege';
    END IF;
    IF has_table_privilege('pfd_application', 'core.number_sequence', 'UPDATE') THEN
        RAISE EXCEPTION 'Application role can bypass the allocator';
    END IF;
    IF has_schema_privilege('pfd_application', 'core', 'CREATE') THEN
        RAISE EXCEPTION 'Application role can create Core objects';
    END IF;
END
$pfd$;
\echo test_unauthorized_access passed
