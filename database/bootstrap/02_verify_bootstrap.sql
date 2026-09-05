\set ON_ERROR_STOP on

DO $pfd$
DECLARE
  required_role text;
BEGIN
  FOREACH required_role IN ARRAY ARRAY[
    'pfd_database_owner', 'pfd_change_executor', 'pfd_application', 'pfd_app',
    'pfd_reporting', 'pfd_support_readonly', 'pfd_backup_operator'
  ]
  LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = required_role) THEN
      RAISE EXCEPTION 'Missing required role: %', required_role;
    END IF;
  END LOOP;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_database d
    JOIN pg_roles r ON r.oid = d.datdba
    WHERE d.datname = current_database()
      AND r.rolname = 'pfd_database_owner'
  ) THEN
    RAISE EXCEPTION 'Current database is not owned by pfd_database_owner';
  END IF;

  IF current_setting('server_encoding') <> 'UTF8' THEN
    RAISE EXCEPTION 'Database encoding must be UTF8';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_database d
    CROSS JOIN LATERAL aclexplode(COALESCE(d.datacl, acldefault('d', d.datdba))) privilege
    WHERE d.datname = current_database()
      AND privilege.grantee = 0
      AND privilege.privilege_type = 'CREATE'
  ) THEN
    RAISE EXCEPTION 'PUBLIC must not have CREATE on the PFD database';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_roles
    WHERE rolname IN ('pfd_database_owner', 'pfd_change_executor', 'pfd_application', 'pfd_app',
              'pfd_reporting', 'pfd_support_readonly', 'pfd_backup_operator')
      AND (rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication)
  ) THEN
    RAISE EXCEPTION 'PFD roles have prohibited elevated attributes';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_change_executor' AND rolinherit) THEN
    RAISE EXCEPTION 'pfd_change_executor must be NOINHERIT';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_roles
     WHERE rolname IN ('pfd_change_executor', 'pfd_app', 'pfd_reporting',
               'pfd_support_readonly', 'pfd_backup_operator')
       AND NOT rolcanlogin
  ) THEN
    RAISE EXCEPTION 'PFD execution roles must be LOGIN roles';
  END IF;

  IF NOT pg_has_role('pfd_change_executor', 'pfd_database_owner', 'MEMBER') THEN
    RAISE EXCEPTION 'pfd_change_executor must be a member of pfd_database_owner';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_application' AND rolcanlogin) THEN
    RAISE EXCEPTION 'pfd_application must remain a NOLOGIN privilege role';
  END IF;

  IF NOT pg_has_role('pfd_app', 'pfd_application', 'MEMBER') THEN
    RAISE EXCEPTION 'pfd_app must be a member of pfd_application';
  END IF;
END
$pfd$;

SELECT 'PFD bootstrap verification passed' AS result;
