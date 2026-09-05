\set ON_ERROR_STOP on

-- PFD Bootstrap 00: cluster roles
-- Run with an authorized PostgreSQL administrator.

DO $pfd$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_database_owner') THEN
    CREATE ROLE pfd_database_owner NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_change_executor') THEN
    CREATE ROLE pfd_change_executor LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_application') THEN
    CREATE ROLE pfd_application NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_app') THEN
    CREATE ROLE pfd_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_reporting') THEN
    CREATE ROLE pfd_reporting LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_support_readonly') THEN
    CREATE ROLE pfd_support_readonly LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_backup_operator') THEN
    CREATE ROLE pfd_backup_operator LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_roles
    WHERE rolname IN ('pfd_database_owner', 'pfd_change_executor', 'pfd_application', 'pfd_app',
              'pfd_reporting', 'pfd_support_readonly', 'pfd_backup_operator')
      AND (rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication)
  ) THEN
    RAISE EXCEPTION 'One or more PFD roles have prohibited elevated attributes';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_database_owner' AND rolcanlogin) THEN
    RAISE EXCEPTION 'pfd_database_owner must remain NOLOGIN';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_application' AND rolcanlogin) THEN
    RAISE EXCEPTION 'pfd_application must remain a NOLOGIN privilege role';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pfd_change_executor' AND rolinherit) THEN
    RAISE EXCEPTION 'pfd_change_executor must remain NOINHERIT';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_roles
     WHERE rolname IN ('pfd_change_executor', 'pfd_app', 'pfd_reporting',
               'pfd_support_readonly', 'pfd_backup_operator')
       AND NOT rolcanlogin
  ) THEN
    RAISE EXCEPTION 'PFD execution roles must remain LOGIN roles';
  END IF;
END
$pfd$;

GRANT pfd_database_owner TO pfd_change_executor;
GRANT pfd_application TO pfd_app;
