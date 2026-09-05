DO $pfd$
BEGIN
    IF (SELECT count(*) FROM core.principal_type WHERE is_active) <> 5 THEN
        RAISE EXCEPTION 'Principal Type baseline differs from the approved set';
    END IF;
    IF (SELECT count(*) FROM core.unit_class WHERE is_active) <> 5 THEN
        RAISE EXCEPTION 'Unit Class baseline differs from the approved set';
    END IF;
    IF (SELECT count(*) FROM core.business_area WHERE is_active) <> 12 THEN
        RAISE EXCEPTION 'Business Area baseline differs from the approved set';
    END IF;
    IF (SELECT count(*) FROM core.role_code WHERE is_active) <> 8 THEN
        RAISE EXCEPTION 'Role Code baseline differs from the approved set';
    END IF;
    IF (SELECT count(*) FROM core.transaction_type WHERE is_active) <> 6 THEN
        RAISE EXCEPTION 'Transaction Type baseline differs from the approved set';
    END IF;
    IF (SELECT count(*) FROM core.unit_of_measure WHERE is_active) <> 9 THEN
        RAISE EXCEPTION 'Unit of Measure baseline differs from the approved set';
    END IF;
    IF (SELECT count(*) FROM core.principal WHERE is_active) <> 4 THEN
        RAISE EXCEPTION 'Bootstrap Principal baseline differs from the approved set';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM core.principal WHERE principal_code = 'DATABASE_BUILD' AND is_active) THEN
        RAISE EXCEPTION 'DATABASE_BUILD Principal is missing or inactive';
    END IF;
END
$pfd$;
