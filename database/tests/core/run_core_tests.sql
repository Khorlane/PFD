\set ON_ERROR_STOP on
SET ROLE pfd_database_owner;
\echo PFD Core tests started
\ir test_natural_keys.sql
\ir test_foreign_keys.sql
\ir test_check_constraints.sql
\ir test_reference_inactivation.sql
\ir test_number_allocation.sql
\ir test_unauthorized_access.sql
\ir test_change_history_append_only.sql
\echo PFD Core tests passed
