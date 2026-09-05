DO $pfd$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
         WHERE schemaname = 'core' AND indexname = 'ix_principal_type_active'
    ) THEN
        RAISE EXCEPTION 'Expected active Principal Type index is missing';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
         WHERE schemaname = 'core' AND indexname = 'ix_approval_authority_lookup'
    ) THEN
        RAISE EXCEPTION 'Expected Approval Authority lookup index is missing';
    END IF;
END
$pfd$;
