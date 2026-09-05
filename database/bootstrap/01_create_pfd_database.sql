\set ON_ERROR_STOP on

-- PFD Bootstrap 01: target database
-- Required psql variable: pfd_database_name

\if :{?pfd_database_name}
\else
  \echo 'ERROR: supply --set=pfd_database_name=<approved_database_name>'
  \quit 2
\endif

SELECT format(
           'CREATE DATABASE %I OWNER pfd_database_owner ENCODING %L TEMPLATE template0',
           :'pfd_database_name',
           'UTF8'
       )
WHERE NOT EXISTS (
    SELECT 1 FROM pg_database WHERE datname = :'pfd_database_name'
)\gexec

SELECT format('REVOKE CREATE ON DATABASE %I FROM PUBLIC', :'pfd_database_name')\gexec
SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC', :'pfd_database_name')\gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO pfd_change_executor', :'pfd_database_name')\gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO pfd_application', :'pfd_database_name')\gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO pfd_reporting', :'pfd_database_name')\gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO pfd_support_readonly', :'pfd_database_name')\gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO pfd_backup_operator', :'pfd_database_name')\gexec

