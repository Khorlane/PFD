\set ON_ERROR_STOP on
\if :{?test_database_name}
\else
  \echo Supply test_database_name, for example: --set=test_database_name=pfd_test_core
  \quit
\endif

SELECT CASE
     WHEN :'test_database_name' ~ '^pfd_test_[a-z0-9_]+$' THEN 1
     ELSE 1 / 0
     END AS validated_disposable_database_name;

SELECT pg_terminate_backend(pid)
  FROM pg_stat_activity
 WHERE datname = :'test_database_name'
   AND pid <> pg_backend_pid();

SELECT format('DROP DATABASE %I', :'test_database_name') \gexec
