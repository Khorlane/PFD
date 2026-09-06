# Project Log

This append-only log records completed project work in enough operational detail to repeat or audit it. Design requirements remain authoritative in `SESSION.md` and the referenced specifications; this log does not duplicate them.

Never record passwords, private company data, personal filesystem paths, or other secrets here. Use environment-variable paths and placeholders for machine-local details.

## 2026-09-05 15:45:44 -04:00 — Local PostgreSQL development bootstrap

### Completed

- Confirmed PostgreSQL 16 was accepting connections at `127.0.0.1:5432`.
- Created the UTF-8 local development database `pfd_dev`, owned by `pfd_database_owner`.
- Created or validated the bootstrap roles defined by `database/bootstrap/00_create_cluster_roles.sql`.
- Changed `pfd_application` to a `NOLOGIN` privilege role.
- Added `pfd_app` as the credential-bearing application login and granted it membership in `pfd_application`.
- Generated a strong local password for `pfd_app` without printing or committing it.
- Stored the private libpq connection string at `%LOCALAPPDATA%\PFD\config\database.local.conf` and restricted the file to the current Windows account.
- Added the public, secret-free example at `config/examples/database.local.conf.example`.
- Corrected bootstrap verification of the PostgreSQL `PUBLIC` pseudo-role by inspecting the database ACL rather than treating `PUBLIC` as a login role.
- Updated bootstrap manifest checksums and the Visual Studio solution Resources listing.
- Did not run the numbered database changes. No schemas, tables, reference data, or opening data were created.

### Repeat procedure

Prerequisites:

- PostgreSQL 16 server running at `127.0.0.1:5432`.
- `psql.exe` from PostgreSQL 16.
- An authorized PostgreSQL administrator credential supplied through a password file, operating-system authentication, or another approved secret mechanism. Do not put its password in these commands.
- Run commands from the repository root.

Set a neutral local variable for the PostgreSQL client location:

```powershell
$pfdPgBin = '<path-to-postgresql-16-bin>'
$pfdPsql = Join-Path $pfdPgBin 'psql.exe'
```

Create or validate the cluster roles, then create the empty database:

```powershell
& $pfdPsql -X -v ON_ERROR_STOP=1 -h 127.0.0.1 -p 5432 -U postgres -d postgres -f database/bootstrap/00_create_cluster_roles.sql
& $pfdPsql -X -v ON_ERROR_STOP=1 -h 127.0.0.1 -p 5432 -U postgres -d postgres --set=pfd_database_name=pfd_dev -f database/bootstrap/01_create_pfd_database.sql
```

Generate and assign the application password without placing it on the command line:

```powershell
$pfdPasswordBytes = [Security.Cryptography.RandomNumberGenerator]::GetBytes(36)
$pfdPassword = [Convert]::ToBase64String($pfdPasswordBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
"ALTER ROLE pfd_app PASSWORD '$pfdPassword';" | & $pfdPsql -X -v ON_ERROR_STOP=1 -h 127.0.0.1 -p 5432 -U postgres -d postgres
```

Create the private connection file and restrict it to the current Windows account:

```powershell
$pfdConfigDirectory = Join-Path $env:LOCALAPPDATA 'PFD\config'
$pfdConfigFile = Join-Path $pfdConfigDirectory 'database.local.conf'
[IO.Directory]::CreateDirectory($pfdConfigDirectory) | Out-Null
$pfdConnection = "host=127.0.0.1 port=5432 dbname=pfd_dev user=pfd_app password=$pfdPassword sslmode=prefer"
[IO.File]::WriteAllText($pfdConfigFile, $pfdConnection + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
$pfdWindowsAccount = [Security.Principal.WindowsIdentity]::GetCurrent().Name
& icacls.exe $pfdConfigFile /inheritance:r /grant:r "${pfdWindowsAccount}:(F)"
$pfdPassword = $null
```

Connect as an administrator to the new database and run the bootstrap verifier:

```powershell
& $pfdPsql -X -v ON_ERROR_STOP=1 -h 127.0.0.1 -p 5432 -U postgres -d pfd_dev -f database/bootstrap/02_verify_bootstrap.sql
```

Confirm that the database is still empty of objects:

```sql
SELECT nspname
FROM pg_namespace
WHERE nspname <> 'information_schema'
  AND nspname NOT LIKE 'pg_%'
ORDER BY nspname;

SELECT count(*) AS user_table_count
FROM pg_tables
WHERE schemaname <> 'information_schema'
  AND schemaname NOT LIKE 'pg_%';
```

Expected result: only the standard `public` schema and a user-table count of zero.

### Verification results

- Bootstrap verifier: passed.
- `pfd_app`: `LOGIN`, `INHERIT`, member of `pfd_application`.
- `pfd_application`: `NOLOGIN`.
- Application connection: succeeded as `pfd_app` to `pfd_dev`.
- Server encoding: `UTF8`.
- Non-system schemas: only `public`.
- User tables: zero.
- Bootstrap manifest checksums: valid.
- `Pfd.slnx`: valid XML.

### Cross-references

- `SESSION.md`, section 22, “Local PostgreSQL development bootstrap.”
- `database/README.md`.
- `docs/enterprise/Database_Repository_and_Core_Build_Specification.md`.
- `docs/enterprise/PostgreSQL_Database_Build_and_Change-Control_Plan.md`.

### Deferred

- Running `database/changes/0001-0010-core`.
- Creating schemas or tables.
- Loading public sample or private opening data.

## 2026-09-05 16:57:27 -04:00 — First C++ PostgreSQL connectivity slice

### Completed

- Added the approved PostgreSQL 16.14 Windows x64 client headers, import library, runtime DLLs, and vendor notices under `external/postgresql/16/windows-x64`.
- Set the shared PostgreSQL property sheet to client major version 16.
- Added automatic copying of the approved `libpq` runtime DLL set beside executable targets that import the property sheet.
- Added `pfd::database::Connection`, a small movable, non-copyable RAII owner for `PGconn`.
- Kept direct `libpq` calls inside `PfdDatabase`.
- Added a connection health operation that executes `SELECT 1` and preserves PostgreSQL failure details without exposing the connection string.
- Added a Windows implementation in `PfdPlatform` that reads `%LOCALAPPDATA%\PFD\config\database.local.conf` as UTF-8 and returns a standard C++ string.
- Replaced the original component-only test executable behavior with one small live PostgreSQL connectivity smoke check.
- Recorded the lightweight verification policy in `SESSION.md`, section 23.
- Did not create or change any PostgreSQL schemas or tables.

### Implementation locations

- PostgreSQL build and deployment settings: `build/visual-studio/Pfd.PostgreSQL.props`.
- Database connection interface and implementation: `projects/PfdDatabase/include/pfd/database/Connection.hpp` and `projects/PfdDatabase/src/Connection.cpp`.
- Local configuration boundary: `projects/PfdPlatform/include/pfd/platform/LocalConfiguration.hpp` and `projects/PfdPlatform/src/windows/LocalConfiguration.cpp`.
- Connectivity smoke check: `projects/PfdTests/src/main.cpp`.
- Approved client inventory and provenance: `external/postgresql/16/windows-x64/README.md`.

### Verification performed

Only the intentionally narrow verification was run:

```powershell
& '<Visual Studio MSBuild path>\MSBuild.exe' Pfd.slnx /t:Build /p:Configuration=Debug /p:Platform=x64 /m /nologo /v:minimal
& 'out\build\Debug\x64\PfdTests.exe'
```

Results:

- Debug/x64 solution build: passed.
- Live connection to `pfd_dev` as `pfd_app`: passed.
- `SELECT 1` health query: passed.
- Six required non-system runtime DLLs were copied beside `PfdTests.exe`.
- Release build and broader tests were intentionally not run.

### Issue encountered

The first compile identified that `postgres_ext.h` includes `pg_config_ext.h`. The missing vendor header was added to the approved client bundle, after which the focused build passed.

### Deferred

- General query-result abstraction.
- Parameterized and prepared statement execution.
- Transaction RAII.
- Database schema and table creation.
- Desktop user-interface integration.

## 2026-09-05 17:28:30 -04:00 — Completed the initial libpq access layer

### Completed

- Added `DatabaseError`, which retains the PostgreSQL primary message, SQLSTATE, severity, detail, hint, and context as separately accessible values.
- Added the RAII-managed `QueryResult` wrapper for `PGresult`.
- Exposed result status and status name, command tag, affected-row count, row and column counts, column names, SQL `NULL` detection, and text values.
- Added explicit SQL execution for fixed statements used by infrastructure such as transaction boundaries.
- Added parameterized statement execution through `PQexecParams`, including explicit SQL `NULL` parameters.
- Added named statement preparation through `PQprepare` and execution through `PQexecPrepared`.
- Added an RAII `Transaction` that begins on construction, supports explicit commit and rollback, and attempts rollback during destruction while a transaction remains active.
- Kept all direct `libpq` calls inside `PfdDatabase`; portable callers see standard C++ types.
- Kept SQL text, statement names, parameter values, transaction boundaries, PostgreSQL diagnostics, result metadata, and affected-row results visible to the code.
- Reused the existing single smoke executable rather than adding a test framework or multiple test cases.
- Did not create or modify any PostgreSQL schemas or tables.

### Public implementation surface

- `projects/PfdDatabase/include/pfd/database/Connection.hpp`
- `projects/PfdDatabase/include/pfd/database/DatabaseError.hpp`
- `projects/PfdDatabase/include/pfd/database/QueryResult.hpp`
- `projects/PfdDatabase/include/pfd/database/Transaction.hpp`

The implementation remains in the corresponding `projects/PfdDatabase/src` files. The Visual Studio project and filters were updated so all files appear normally in Solution Explorer.

### Focused verification performed

```powershell
& '<Visual Studio MSBuild path>\MSBuild.exe' projects/PfdTests/PfdTests.vcxproj /t:Build /p:Configuration=Debug /p:Platform=x64 /m /nologo /v:minimal
& 'out\build\Debug\x64\PfdTests.exe'
```

The one smoke executable successfully exercised:

- Connection health through a parameterized `SELECT`.
- Two text parameters and a calculated result.
- A named prepared statement.
- An explicit SQL `NULL` parameter.
- Explicit transaction commit.
- Explicit transaction rollback.
- Automatic rollback on transaction destruction.

Results:

- Focused Debug/x64 build: passed.
- Live access-layer smoke check against `pfd_dev`: passed.
- Release build and broad regression testing: intentionally not run.

### Cross-references

- `SESSION.md`, PostgreSQL access decisions and section 23 lightweight verification policy.
- `database/README.md` for the database-build boundary.

### Deferred

- Binary-valued query parameters and results; the current application interface is intentionally UTF-8 text-oriented.
- Asynchronous and pipeline-mode libpq operations.
- Connection pooling.
- Schema creation and business repositories.

## 2026-09-05 17:38:27 -04:00 — Retrofitted 2-space source indentation

### Completed

- Established spaces-only indentation with 2 spaces per code level for project-owned source code.
- Added repository-wide indentation defaults to `.editorconfig`.
- Added `.clang-format` for C++ with `UseTab: Never` and `IndentWidth: 2`.
- Applied the C++ formatter to all project-owned `.cpp`, `.hpp`, and `.h` files under `projects`.
- Mechanically converted existing 4-space indentation levels to 2-space levels in project-owned PostgreSQL SQL and Python database tooling.
- Left third-party PostgreSQL headers, binaries, and vendor notices under `external` unchanged.
- Added `.clang-format` to the Visual Studio solution Resources view.
- Recorded the rule in `SESSION.md`, section 24.
- Refreshed database-build manifest hashes for SQL files whose whitespace changed. Change `0002` required no hash update because its content already conformed.

### Focused verification performed

- `clang-format --dry-run --Werror` across C++ source: passed.
- Tab scan across project, database, tool, build, and configuration files: passed with no tabs.
- Python database-runner syntax compilation: passed.
- Bootstrap, numbered-change, and reference-data manifest checksum validation: passed.
- Focused `PfdTests` Debug/x64 build: passed.
- Existing single PostgreSQL access-layer smoke check: passed.
- Release and broad regression tests were intentionally not run.

### Database effect

No SQL was executed against `pfd_dev` as part of the formatting retrofit. No schemas or tables were created or changed.
