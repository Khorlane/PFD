\set ON_ERROR_STOP on
SET ROLE pfd_database_owner;
\echo PFD Core verification started
\ir verify_change_history.sql
\ir verify_schemas.sql
\ir verify_core_tables.sql
\ir verify_core_constraints.sql
\ir verify_core_indexes.sql
\ir verify_core_reference_data.sql
\ir verify_core_privileges.sql
\ir verify_no_surrogate_keys.sql
\echo PFD Core verification passed
