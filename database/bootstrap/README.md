# Bootstrap

Bootstrap is intentionally outside `core.database_change`: it creates the roles and database required before that history table exists.

Run `00_create_cluster_roles.sql` and `01_create_pfd_database.sql` while connected to an administrative database such as `postgres`. Then connect to the created PFD database and run `02_verify_bootstrap.sql`.

Role and database names are fixed except for the environment-specific database name. Existing roles are validated rather than altered silently. Passwords are never embedded.

