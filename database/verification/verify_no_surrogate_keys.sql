DO $pfd$
DECLARE
  generated_count integer;
  generic_id_pk_count integer;
BEGIN
  SELECT count(*) INTO generated_count
    FROM information_schema.columns
   WHERE table_schema IN ('core','party','simulation','hr','product','sales','credit','purchasing',
              'inventory','warehouse','transport','quality','service','finance','reporting','audit','staging')
     AND (is_identity = 'YES' OR column_default LIKE 'nextval(%');
  IF generated_count <> 0 THEN
    RAISE EXCEPTION 'Generated identity/serial columns violate the PFD natural-key rule';
  END IF;

  SELECT count(*) INTO generic_id_pk_count
    FROM pg_constraint k
    JOIN pg_class c ON c.oid = k.conrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN unnest(k.conkey) WITH ORDINALITY AS key_column(attnum, ordinality) ON true
    JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = key_column.attnum
   WHERE n.nspname IN ('core','party','simulation','hr','product','sales','credit','purchasing',
             'inventory','warehouse','transport','quality','service','finance','reporting','audit','staging')
     AND k.contype = 'p' AND a.attname IN ('id', c.relname || '_id');
  IF generic_id_pk_count <> 0 THEN
    RAISE EXCEPTION 'Generic ID primary-key columns violate the PFD natural-key rule';
  END IF;
END
$pfd$;
