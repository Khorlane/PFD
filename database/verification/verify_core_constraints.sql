DO $pfd$
DECLARE
    missing_pk integer;
    invalid_fk integer;
BEGIN
    SELECT count(*) INTO missing_pk
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE n.nspname = 'core' AND c.relkind = 'r'
       AND NOT EXISTS (SELECT 1 FROM pg_constraint k WHERE k.conrelid = c.oid AND k.contype = 'p');
    IF missing_pk <> 0 THEN
        RAISE EXCEPTION 'Every Core table must have a primary key; missing count %', missing_pk;
    END IF;

    SELECT count(*) INTO invalid_fk
      FROM pg_constraint k
      JOIN pg_namespace n ON n.oid = k.connamespace
     WHERE n.nspname = 'core' AND k.contype = 'f' AND NOT k.convalidated;
    IF invalid_fk <> 0 THEN
        RAISE EXCEPTION 'Core has % unvalidated foreign keys', invalid_fk;
    END IF;
END
$pfd$;
