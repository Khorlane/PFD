# PFD PostgreSQL Core Build

This package creates the PostgreSQL foundation for the selected simulated business.

It implements the approved Core Build through database change `0010`. PFD is a new system: bootstrap creates a new database, and numbered SQL changes build or update it in place. Operational data is continuous across Simulation Sessions.

## Requirements

- PostgreSQL 15 or later, on a vendor-supported release in the target environment
- `psql` available on the execution path
- Python 3.11 or later for the build runner
- Administrative access for one-time bootstrap
- A target database owned by `pfd_database_owner`

## Primary-key policy

PFD uses stable business numbers, governed codes, and composite natural keys. Surrogate, identity, serial, and UUID substitute primary keys are prohibited.

## Bootstrap

Run bootstrap files with authorized PostgreSQL administration:

1. `bootstrap/00_create_cluster_roles.sql`
2. `bootstrap/01_create_pfd_database.sql`
3. Connect to the new database and run `bootstrap/02_verify_bootstrap.sql`

The database-creation script requires the psql variable `pfd_database_name`.

Example command pattern:

```text
psql --set=pfd_database_name=pfd_dev -f bootstrap/01_create_pfd_database.sql postgres
```

Do not put passwords on the command line. Use an approved PostgreSQL password file, operating-system authentication, certificate, or secret provider.

`pfd_application` is the non-login application privilege role. `pfd_app` is the local credential-bearing login and inherits the privileges granted to `pfd_application`.

## Build runner

From the repository root:

```text
python tools/database-build/pfd_db_build.py validate --dsn-name PFD_DEV --principal DATABASE_BUILD
python tools/database-build/pfd_db_build.py build-and-verify --dsn-name PFD_DEV --principal DATABASE_BUILD
python tools/database-build/pfd_db_build.py status --dsn-name PFD_DEV
```

`--dsn-name` identifies an approved PostgreSQL service name. The runner passes `service=<name>` to `psql`; secrets remain in PostgreSQL-supported configuration.

## Direct verification

```text
psql service=PFD_DEV -v ON_ERROR_STOP=1 -f verification/verify_core_build.sql
```

Run the rollback-contained behavioral tests only in a disposable validation database:

```text
psql service=PFD_TEST -v ON_ERROR_STOP=1 -f tests/core/run_core_tests.sql
```

## Package contents

- `bootstrap` — cluster roles, database creation, and bootstrap verification
- `changes/0001-0010-core` — permanent ordered Core SQL changes `0001` through `0010`
- `manifests` — checksummed Core Build manifest
- `reference-data` — reviewable snapshots of controlled opening values represented by changes `0003` through `0009`
- `verification` — read-only structural and privilege assertions
- `tests` — controlled Core behavior tests
- `../tools/database-build` — cross-platform Python build runner using `psql`
- `operations` — guarded disposable-database helpers
- `documentation` — data dictionary and privilege matrix

## Safety rules

- Applied change files are immutable.
- The runner stops on checksum mismatch or the first SQL failure.
- Authoritative databases are never dropped by package scripts.
- Disposable drop operations accept only database names beginning `pfd_test_`.
- Every shared-environment application requires review, backup assessment, verification, and retained evidence.
