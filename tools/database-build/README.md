# PFD Database Build Runner

`pfd_db_build.py` validates and applies the permanent numbered SQL changes. It uses only Python's standard library and the PostgreSQL `psql` client.

## Connection rule

Credentials do not belong in scripts, manifests, shell history, or source control. Configure a libpq service in the operator's approved `pg_service.conf`, then pass only its service name:

```text
python tools/database-build/pfd_db_build.py validate --dsn-name pfd_build
python tools/database-build/pfd_db_build.py build-and-verify --dsn-name pfd_build
python tools/database-build/pfd_db_build.py status --dsn-name pfd_build
```

The runner:

1. validates every manifest checksum;
2. requires PostgreSQL 15 or later;
3. refuses unknown, mismatched, or gapped target history;
4. holds a session-level advisory lock during the build;
5. executes each change in its own transaction;
6. records successful changes in `core.database_change`; and
7. stops at the first error.

Never edit an applied numbered file. Add the next numbered change and publish a new manifest version.
