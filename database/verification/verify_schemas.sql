DO $pfd$
DECLARE
  schema_name text;
BEGIN
  FOREACH schema_name IN ARRAY ARRAY[
    'core', 'party', 'simulation', 'hr', 'product', 'sales', 'credit', 'purchasing',
    'inventory', 'warehouse', 'transport', 'quality', 'service', 'finance',
    'reporting', 'audit', 'staging'
  ]
  LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = schema_name) THEN
      RAISE EXCEPTION 'Expected schema is missing: %', schema_name;
    END IF;
  END LOOP;
END
$pfd$;
