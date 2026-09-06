# \<business name>

## Database Repository and Core Build Specification

**Company abbreviation:** \<company abbr>
**Database platform:** PostgreSQL  
**Document date:** September 4, 2026  
**Document status:** Authoritative detailed implementation specification  

**Governing documents:**

- `Business_Model_and_Operating_Policies.md`
- `Business_to_IT_Capability_Specification.md`
- `Information_Model_and_Record_Ownership_Specification.md`
- `Business_Process_and_Transaction_Lifecycle_Specification.md`
- `Persistent_Data_Architecture_and_Database_Standards_Specification.md`
- `Relational_Schema_and_Table_Definition_Specification.md`
- `PostgreSQL_Database_Build_and_Change-Control_Plan.md`

---

## 1. Purpose

This specification defines the concrete repository structure and first PostgreSQL database build package for the business.

It establishes:

- Exact database repository folders
- Bootstrap and permanent-change boundaries
- SQL file names and execution order
- Build-runner behavior
- PostgreSQL ownership and runtime roles
- Functional schemas
- Database change-history design
- Core reference-table pattern
- Principal, Company, Unit of Measure, Approval Authority, and Number Sequence tables
- Natural-key, constraint, index, grant, and comment conventions
- Empty-build and core-build verification

This document is the final detailed specification before executable PostgreSQL SQL files are produced. It describes those files precisely but does not contain the final SQL implementation.

---

## 2. Scope

### 2.1 Included

The Core Build includes:

- Administrative bootstrap definitions
- Database ownership structure
- All approved functional schemas
- `core.database_change`
- Core reference tables
- `core.principal`
- `core.company`
- `core.unit_of_measure`
- `core.approval_authority`
- `core.number_sequence`
- Initial reference rows required by the Core Build
- Grants, comments, and verification scripts for these objects

### 2.2 Deferred

The following are defined in later build packages:

- Party, Person, Address, and Contact
- Facility, Warehouse Zone, Warehouse Location, and Calendar
- Simulation Session and scheduler controls
- Employee and HR records
- Product, Supplier, and Customer masters
- Sales, purchasing, inventory, warehouse, and transportation transactions
- Quality, customer service, finance, payroll, reporting, and audit transactions
- Opening business master and financial data

Deferred objects may be referenced conceptually but shall not create unresolved foreign keys in the completed Core Build.

---

## 3. Locked Architecture Decisions

1. PostgreSQL is the sole authoritative operational database.
2. The simulation uses one continuing business database per environment.
3. Operational data is not partitioned by Simulation Session.
4. Natural business numbers, codes, and governed composite keys are primary keys.
5. Surrogate, identity, serial, and UUID substitute primary keys are prohibited.
6. All SQL identifiers use lowercase `snake_case` without quoted identifiers.
7. Table names are singular.
8. Functional schemas define domain boundaries.
9. Permanent database changes are ordered, source-controlled, checksummed, and immutable after application.
10. The first permanent change creates and self-registers the database change-history table.
11. Administrative bootstrap is separate from ordinary database changes because it creates the database and roles needed to execute them.
12. Runtime application roles do not own database objects.
13. Initial and future builds use the same permanent change files.
14. No undocumented manual structural edits are permitted.

---

## 4. Repository Root

The database work is stored beneath the project root in:

```text
database/
```

The repository root is independent of a developer's workstation path. Scripts use paths relative to the repository root or receive explicit paths from the build runner.

---

## 5. Required Repository Structure

```text
database/
  README.md
  bootstrap/
    README.md
    00_create_cluster_roles.sql
    01_create_pfd_database.sql
    02_verify_bootstrap.sql
  changes/
    0001_create_core_change_history.sql
    0002_create_functional_schemas.sql
    0003_create_core_reference_tables.sql
    0004_create_core_principal.sql
    0005_create_core_company.sql
    0006_create_core_unit_of_measure.sql
    0007_create_core_approval_authority.sql
    0008_create_core_number_sequence.sql
    0009_seed_core_reference_data.sql
    0010_apply_core_comments_and_grants.sql
  manifests/
    core_build_manifest.json
  reference-data/
    core/
      principal_type.csv
      unit_class.csv
      business_area.csv
      transaction_type.csv
      role_code.csv
  verify/
    verify_change_history.sql
    verify_schemas.sql
    verify_core_tables.sql
    verify_core_constraints.sql
    verify_core_indexes.sql
    verify_core_reference_data.sql
    verify_core_privileges.sql
    verify_no_surrogate_keys.sql
    verify_core_build.sql
  test/
    core/
      test_natural_keys.sql
      test_foreign_keys.sql
      test_check_constraints.sql
      test_reference_inactivation.sql
      test_number_allocation.sql
      test_unauthorized_access.sql
  tools/
    README.md
    pfd_db_build
  operations/
    README.md
    create_disposable_database.sql
    drop_disposable_database.sql
  documentation/
    core_data_dictionary.md
    core_privilege_matrix.md
```

### 5.1 Repository exclusions

The repository shall not contain:

- Passwords, tokens, certificates, or connection strings containing secrets
- Database backups
- Runtime logs
- Generated query plans
- Temporary extracts
- Authoritative customer, employee, banking, payroll, or owner-sensitive data
- Local editor or operating-system files

---

## 6. Repository File Responsibilities

### 6.1 `README.md`

The database root README defines:

- Supported PostgreSQL major versions
- Required client tools
- Environment-variable names without secret values
- Bootstrap prerequisites
- Empty-build command pattern
- Existing-database update command pattern
- Verification command pattern
- Disposable-database reset procedure
- Links to the governing specifications

### 6.2 `bootstrap`

Contains cluster- and database-level setup that cannot be executed as an ordinary change inside the not-yet-created database.

### 6.3 `changes`

Contains the permanent, sequential SQL history. These files are the authoritative database definition when applied in order.

### 6.4 `manifests`

Defines the exact files, checksums, prerequisites, and verification suite for a build package.

### 6.5 `reference-data`

Contains reviewable source data used by explicit reference-data change files. CSV is an authoring/input format; the applied SQL file remains the permanent database-change record.

### 6.6 `verify`

Contains read-only assertions that fail when the resulting database differs from the specification.

### 6.7 `test`

Contains transactionally isolated or disposable-database tests of expected success and expected failure behavior.

### 6.8 `tools`

Contains the build-runner implementation and its documentation.

### 6.9 `operations`

Contains guarded procedures for disposable development/test databases. It does not contain a general-purpose command for dropping an authoritative database.

---

## 7. Bootstrap Boundary

Bootstrap creates the minimum PostgreSQL objects required before permanent changes can run.

### 7.1 Bootstrap inputs

- PostgreSQL administrative connection authorized to create roles and a database
- Environment code
- Database name
- Owner-role name
- Change-executor login name
- Encoding and locale settings
- Approved connection-security configuration

Secrets are supplied through the approved runtime secret mechanism and never as SQL literals or command-line values visible in process listings.

### 7.2 `00_create_cluster_roles.sql`

Creates or validates:

- `pfd_database_owner` as `NOLOGIN`
- `pfd_change_executor` as a controlled login or externally authenticated role
- `pfd_application` as the `NOLOGIN` application privilege role
- `pfd_app` as the credential-bearing application login and a member of `pfd_application`
- `pfd_reporting` as a controlled login or externally authenticated role
- `pfd_support_readonly` as a controlled login or externally authenticated role
- `pfd_backup_operator` according to the selected backup method

The script does not embed passwords. Existing roles must match the required security attributes or bootstrap stops.

### 7.3 `01_create_pfd_database.sql`

Creates the target database with:

- Owner `pfd_database_owner`
- UTF-8 encoding
- Approved locale settings
- Explicit connection permissions
- No reliance on broad default `PUBLIC` access

The database name is supplied as an approved bootstrap parameter. Environment naming is operational configuration, not hard-coded into table structures.

### 7.4 `02_verify_bootstrap.sql`

Confirms:

- Required roles exist
- Login and ownership attributes are correct
- Target database owner is correct
- Encoding and locale match the manifest
- Unauthorized `PUBLIC` creation privileges are absent
- Change Executor can connect
- Application and Reporting roles cannot create objects

### 7.5 Bootstrap recording

Bootstrap actions are recorded in the external release/operations record because `core.database_change` does not yet exist. Change `0001` begins the permanent in-database history.

---

## 8. Functional Schemas

Change `0002` creates these schemas:

| Schema | Purpose |
|---|---|
| `core` | Shared governance, keys, units, calendar, facility, change history |
| `party` | People, addresses, contacts, common party relationships |
| `simulation` | Technical Simulation Sessions, clock, event queue, diagnostics |
| `hr` | Employees, organization, schedule, time, payroll |
| `product` | Products, packs, storage, shelf life, price/cost foundations |
| `sales` | Customers, locations, contracts, orders |
| `credit` | Credit profiles, holds, reviews, collections |
| `purchasing` | Suppliers, recommendations, purchase orders |
| `inventory` | Lots, pallets, balances, movements, allocation, valuation |
| `warehouse` | Receiving, putaway, replenishment, picking, staging, loading |
| `transport` | Fleet, routes, stops, deliveries, returns |
| `quality` | Holds, temperature, sanitation, incidents, recalls |
| `service` | Cases, returns, inspections, dispositions, credit requests |
| `finance` | GL, AR, AP, cash, debt, equity, assets, budgets |
| `reporting` | Approved reporting objects, KPIs, report records |
| `audit` | Audit events, approvals, overrides, exceptions, recovery |
| `staging` | Temporary validated import data awaiting controlled promotion |

All schemas are owned by `pfd_database_owner`. The Change Executor receives controlled creation/alteration privileges for approved builds. Runtime roles receive only explicit usage and object privileges.

---

## 9. Permanent Change Files

### 9.1 Filename format

```text
NNNN_short_business_description.sql
```

Rules:

- `NNNN` is a unique four-digit sequence.
- The sequence is strictly increasing.
- The description uses lowercase `snake_case`.
- A file contains one coherent structural or reference-data change.
- Applied numbers and filenames are never reused.

### 9.2 Required SQL-file header

Every permanent change file begins with comments identifying:

- Change number
- Change name
- Purpose
- Governing requirement or specification section
- Required preceding change
- Expected transaction mode
- Expected locking/service impact
- Validation file or assertions
- Recovery method
- Author and reviewer placeholders

### 9.3 Applied-file immutability

Once applied to any shared environment, a permanent file's name and contents are immutable. Defects are corrected by a later numbered change.

---

## 10. Core Build Manifest

`manifests/core_build_manifest.json` defines:

- Manifest format version
- Build package name `core_build`
- Package version
- Supported PostgreSQL major versions
- Required bootstrap version
- Ordered permanent change filenames
- SHA-256 checksum for every file
- Required reference-data source checksums
- Ordered verification filenames
- Expected final change number `0010`
- Expected schema list
- Required application compatibility marker when applicable

The manifest contains no credentials or environment-specific server address.

The build runner refuses to execute when the manifest, file set, order, or checksum differs from the repository contents.

---

## 11. Build-Runner Contract

The repository exposes one logical build command named:

```text
pfd_db_build
```

Its implementation may be a platform-appropriate executable or script, but its external behavior is fixed by this specification.

### 11.1 Required modes

| Mode | Purpose |
|---|---|
| `status` | Show database version, applied changes, and pending changes |
| `validate` | Validate repository files, checksums, manifest, and target compatibility without changing the database |
| `build` | Apply all pending changes through the manifest target |
| `verify` | Run the complete read-only verification suite |
| `build-and-verify` | Apply pending changes and immediately verify the result |

### 11.2 Required inputs

- Target environment code
- Connection profile name or approved connection source
- Manifest path
- Optional target change number
- Requesting Principal Code
- Noninteractive confirmation token for an approved pipeline when required

Passwords are never accepted as ordinary command-line arguments.

### 11.3 Preflight sequence

Before changing the database, the runner:

1. Reads and validates the manifest.
2. Confirms all named files exist exactly once.
3. Recomputes SHA-256 checksums.
4. Connects using the Change Executor.
5. Confirms the target database and environment label.
6. Confirms supported PostgreSQL version.
7. Reads `core.database_change`, except during first change bootstrap.
8. Validates applied filenames and checksums.
9. Confirms pending files form one continuous sequence.
10. Obtains the database-build advisory lock.
11. Confirms no other build is active.
12. Confirms the target is not newer than the manifest.

### 11.4 Application sequence

For each pending change, the runner:

1. Displays or logs the change number and name.
2. Establishes required safe session settings.
3. Begins a transaction when permitted.
4. Executes the complete SQL file with stop-on-error behavior.
5. Runs the file's immediate assertions.
6. Inserts the `core.database_change` row in the same transaction.
7. Commits.
8. Confirms the recorded checksum and change number.
9. Continues only after success.

The runner stops on the first error. It never skips a failed file and applies a later file.

### 11.5 Safe session settings

The runner establishes explicit values for:

- Client encoding
- Time zone
- Statement timeout appropriate to the approved change
- Lock timeout
- Search path that does not permit accidental unqualified object creation
- Error-stop behavior
- Application name identifying the build and change number

All DDL remains schema-qualified even when a search path is set.

### 11.6 Build lock

One PostgreSQL advisory lock identified by the stable logical name `pfd_database_build` prevents concurrent change execution. The runner releases it on clean completion; PostgreSQL session termination releases it after failure.

This lock coordinates database builds only. It does not replace business transaction locks or constraints.

### 11.7 Runner output

The runner produces:

- Environment and database identity
- Starting and ending change numbers
- Each pending file and result
- Checksum verification result
- Start/end timestamps and duration
- Verification summary
- Failure file and PostgreSQL error when applicable
- Location of the retained execution log

Logs redact secrets and protected data values.

### 11.8 Exit results

The runner distinguishes at least:

- Success with no pending changes
- Success with changes applied
- Repository/manifest validation failure
- Database compatibility failure
- Checksum/history mismatch
- Lock/concurrent-build failure
- SQL execution failure
- Post-build verification failure
- Authorization or connection failure

Exact numeric process exit codes are defined with the executable implementation.

---

## 12. `core.database_change`

### 12.1 Purpose

Records the exact permanent SQL history applied to a database.

### 12.2 Columns

| Column | PostgreSQL type | Null | Rule |
|---|---|---:|---|
| `change_number` | `text` | No | Primary key; exactly four decimal digits |
| `change_name` | `text` | No | Governed descriptive name |
| `file_name` | `text` | No | Unique permanent filename |
| `file_checksum` | `text` | No | SHA-256 in normalized lowercase hexadecimal |
| `applied_at` | `timestamptz` | No | Actual completion timestamp |
| `applied_by_principal_code` | `text` | No | Responsible approved actor/process |
| `execution_duration_ms` | `bigint` | No | Nonnegative duration |
| `application_release` | `text` | Yes | Associated release when applicable |
| `manifest_name` | `text` | No | Manifest authorizing the change |
| `manifest_version` | `text` | No | Manifest version |
| `notes` | `text` | Yes | Non-secret implementation note |

### 12.3 Constraints

- PK `change_number`
- Unique `file_name`
- Check `change_number` matches exactly four digits
- Check checksum matches exactly 64 lowercase hexadecimal characters
- Check duration is nonnegative
- Required nonblank text checks

`applied_by_principal_code` cannot initially have a foreign key because change `0001` precedes `core.principal`. Change `0004` adds and validates the foreign key after the bootstrap Principal rows exist.

### 12.4 Indexes

The primary and unique constraints provide required lookup indexes. Add an `applied_at` index only if operational history queries justify it; it is not required in the opening build.

### 12.5 Change `0001` self-registration

Change `0001`:

1. Creates schema `core` owned by `pfd_database_owner`.
2. Creates `core.database_change`.
3. Creates its constraints.
4. Inserts its own change-history row with the runner-provided checksum, Principal Code, duration, manifest, and timestamp.
5. Commits atomically.

The build runner has an explicit first-change path for this bootstrap. It does not pretend that an earlier history table existed.

---

## 13. Core Reference-Table Standard

### 13.1 Standard columns

Every simple core reference table uses:

| Column pattern | PostgreSQL type | Null | Rule |
|---|---|---:|---|
| `<subject>_code` | `text` | No | Primary key; stable uppercase code |
| `display_name` | `text` | No | User-facing name |
| `description` | `text` | Yes | Business meaning |
| `sort_order` | `integer` | No | Nonnegative display/workflow order |
| `is_active` | `boolean` | No | Default true |
| `effective_from` | `date` | No | Inclusive start |
| `effective_through` | `date` | Yes | Exclusive end; null means open-ended |
| `created_at` | `timestamptz` | No | Creation timestamp |
| `created_by_principal_code` | `text` | No | Creating Principal |
| `updated_at` | `timestamptz` | No | Latest update timestamp |
| `updated_by_principal_code` | `text` | No | Latest updater |
| `row_version` | `bigint` | No | Starts at 1; positive |

### 13.2 Standard constraints

- Primary key on the subject code
- Nonblank code, display name, and required description where specified
- Uppercase code format using approved letters, digits, and underscore
- Nonnegative sort order
- `effective_through > effective_from` when present
- Positive row version
- Foreign keys to Principal added after `core.principal` exists

### 13.3 Code lifecycle

- Codes are never reused or silently repurposed.
- Referenced codes are inactivated or end-dated rather than deleted.
- Existing historical records continue to reference inactive codes.
- New transactions cannot use inactive codes unless an explicit historical-data process permits it.

### 13.4 Core reference tables in change `0003`

| Table | Primary key |
|---|---|
| `core.principal_type` | `principal_type_code` |
| `core.unit_class` | `unit_class_code` |
| `core.business_area` | `business_area_code` |
| `core.transaction_type` | `transaction_type_code` |
| `core.role_code` | `role_code` |

Facility, location, storage, calendar, and other reference tables are introduced with the later domain package that first uses them.

---

## 14. Initial Core Reference Data

Change `0009` inserts the minimum approved rows.

### 14.1 Principal types

| Code | Meaning |
|---|---|
| `PERSON` | Human user represented by an authenticated Principal |
| `SERVICE` | Application or integration service |
| `SCHEDULED_PROCESS` | Scheduled processing actor |
| `DATABASE_BUILD` | Controlled database build process |
| `RECOVERY_PROCESS` | Controlled restart or recovery actor |

### 14.2 Unit classes

| Code | Meaning |
|---|---|
| `COUNT` | Each, pack, case, or pallet quantity |
| `WEIGHT` | Fixed recorded weight unit; not catch-weight pricing |
| `VOLUME` | Volume or cube measure |
| `TIME` | Time or duration measure |
| `DISTANCE` | Routing, mileage, or travel distance |

### 14.3 Business areas

Opening codes include:

- `GENERAL_MANAGEMENT`
- `SALES`
- `CREDIT`
- `PURCHASING`
- `INVENTORY`
- `WAREHOUSE`
- `TRANSPORTATION`
- `QUALITY`
- `CUSTOMER_SERVICE`
- `FINANCE`
- `HUMAN_RESOURCES`
- `INFORMATION_TECHNOLOGY`

### 14.4 Role codes

Opening codes include:

- `GENERAL_MANAGER`
- `SALES_MANAGER`
- `OPERATIONS_PURCHASING_MANAGER`
- `FINANCE_ADMIN_MANAGER`
- `DATABASE_ADMINISTRATOR`
- `COMPUTER_OPERATOR`
- `DATABASE_BUILD_PROCESS`
- `APPLICATION_SERVICE`

### 14.5 Transaction types

Only transaction types required to define opening Approval Authority rows are loaded in the Core Build. Domain-specific transaction types are added by the owning domain's later change file.

### 14.6 Seed execution behavior

- Every inserted code and value is explicit.
- Unexpected preexisting rows cause the change to fail.
- Seed SQL verifies expected row counts.
- No `ON CONFLICT DO NOTHING` behavior conceals differences.
- A later description or status correction uses a later numbered change.

---

## 15. `core.principal`

### 15.1 Purpose

Identifies the responsible human, service, scheduled process, database build, or recovery process recorded in database audit columns.

### 15.2 Columns

| Column | PostgreSQL type | Null | Rule |
|---|---|---:|---|
| `principal_code` | `text` | No | Primary natural key |
| `principal_type_code` | `text` | No | FK to `core.principal_type` |
| `display_name` | `text` | No | Human-readable identity |
| `external_subject` | `text` | Yes | Unique nonblank authentication subject when used |
| `is_active` | `boolean` | No | Default true |
| `created_at` | `timestamptz` | No | Creation timestamp |
| `created_by_principal_code` | `text` | No | Self-FK; controlled bootstrap value allowed |
| `updated_at` | `timestamptz` | No | Latest update timestamp |
| `updated_by_principal_code` | `text` | No | Self-FK |
| `row_version` | `bigint` | No | Starts at 1; positive |

### 15.3 Constraints

- PK `principal_code`
- FK `principal_type_code`
- Self-FKs for creator and updater
- Unique nonnull `external_subject`
- Uppercase governed `principal_code`
- Required nonblank display name
- Positive row version
- Updated timestamp not before created timestamp

### 15.4 Indexes

- PK index on `principal_code`
- Unique partial index on nonnull `external_subject`
- Index `(principal_type_code, is_active)` for administration

### 15.5 Bootstrap Principals

Change `0004` creates at least:

| Principal Code | Type | Purpose |
|---|---|---|
| `DATABASE_BUILD` | `DATABASE_BUILD` | Normal database-change execution |
| `SYSTEM_SERVICE` | `SERVICE` | General application-owned system activity |
| `SCHEDULED_PROCESS` | `SCHEDULED_PROCESS` | Scheduled event execution |
| `RECOVERY_PROCESS` | `RECOVERY_PROCESS` | Controlled recovery activity |

The `DATABASE_BUILD` row self-references as creator/updater during bootstrap. After creation, change `0004` adds and validates `core.database_change.applied_by_principal_code` as an FK to `core.principal`.

Authentication credentials are not stored in `core.principal`.

---

## 16. Common Mutable-Record Columns

Mutable master/configuration tables introduced by the Core Build use:

| Column | Type | Requirement |
|---|---|---|
| `created_at` | `timestamptz` | Set once; never changed |
| `created_by_principal_code` | `text` | Required FK to Principal |
| `updated_at` | `timestamptz` | Required; not before creation |
| `updated_by_principal_code` | `text` | Required FK to Principal |
| `row_version` | `bigint` | Required; starts at 1 and increments on controlled update |

The application supplies the responsible Principal Code. Database defaults may supply timestamps but shall not invent a human identity.

---

## 17. `core.company`

### 17.1 Purpose

Stores the selected simulated company's configurable legal and operating identity.

### 17.2 Columns

| Column | PostgreSQL type | Null | Rule/opening value |
|---|---|---:|---|
| `company_code` | `text` | No | PK; stable configured natural key |
| `legal_name` | `text` | No | Configured legal name |
| `display_name` | `text` | No | Configured display name |
| `default_currency_code` | `text` | No | `USD` |
| `business_timezone` | `text` | No | `America/New_York` |
| `fiscal_year_start_month` | `smallint` | No | `1` |
| `is_active` | `boolean` | No | True |
| Common mutable-record columns | — | No | As defined above |

### 17.3 Constraints

- PK `company_code`
- Uppercase governed company code
- Nonblank legal and display names
- Currency code exactly three uppercase letters
- Fiscal start month from 1 through 12
- Business timezone must be an approved timezone value
- Positive row version
- Update timestamp not before creation

### 17.4 Opening row

The Core Build creates `core.company` but does not insert a named Company row. The explicitly selected opening dataset supplies the Company record. Later Party/Facility opening data supplies the corresponding business addresses without creating an unresolved Address foreign key during Core schema construction.

### 17.5 Indexes

No index beyond the primary key is required at opening scale.

---

## 18. `core.unit_of_measure`

### 18.1 Purpose

Defines fixed units used by Product, Inventory, Purchasing, Sales, Warehouse, Transportation, and Finance records.

### 18.2 Columns

| Column | PostgreSQL type | Null | Rule |
|---|---|---:|---|
| `unit_code` | `text` | No | Primary natural key |
| `unit_name` | `text` | No | Display name |
| `unit_class_code` | `text` | No | FK to `core.unit_class` |
| `decimal_scale` | `smallint` | No | 0 through 4 |
| `is_active` | `boolean` | No | Default true |
| Common mutable-record columns | — | No | Required |

### 18.3 Opening units

| Unit Code | Class | Decimal scale | Meaning |
|---|---|---:|---|
| `EACH` | `COUNT` | 0 | Single item |
| `PACK` | `COUNT` | 0 | Fixed pack |
| `CASE` | `COUNT` | 0 | Fixed case |
| `PALLET` | `COUNT` | 0 | Pallet quantity |
| `POUND` | `WEIGHT` | 4 | Fixed recorded pounds |
| `OUNCE` | `WEIGHT` | 4 | Fixed recorded ounces |
| `CUBIC_FOOT` | `VOLUME` | 6 | Cube/capacity |
| `MILE` | `DISTANCE` | 4 | Route distance |
| `HOUR` | `TIME` | 4 | Labor or duration |

These units do not introduce catch-weight products or variable-weight pricing.

### 18.4 Constraints and indexes

- PK `unit_code`
- FK `unit_class_code`
- Uppercase governed unit code
- Decimal scale from 0 through 6; opening count-unit scale is 0
- Nonblank name
- Index `(unit_class_code, is_active)`

---

## 19. `core.approval_authority`

### 19.1 Purpose

Defines which governed business role may approve a transaction class and amount range during an effective period.

### 19.2 Primary key

```text
(authority_code, effective_from)
```

### 19.3 Columns

| Column | PostgreSQL type | Null | Rule |
|---|---|---:|---|
| `authority_code` | `text` | No | Governed authority identity |
| `effective_from` | `timestamptz` | No | Inclusive start; PK component |
| `effective_through` | `timestamptz` | Yes | Exclusive end |
| `business_area_code` | `text` | No | FK to Business Area |
| `transaction_type_code` | `text` | No | FK to Transaction Type |
| `role_code` | `text` | No | FK to Role Code |
| `minimum_amount` | `numeric(19,4)` | Yes | Inclusive minimum |
| `maximum_amount` | `numeric(19,4)` | Yes | Inclusive maximum |
| `required_approval_count` | `smallint` | No | At least 1 |
| `is_active` | `boolean` | No | Default true |
| Common mutable-record columns | — | No | Required |

### 19.4 Constraints

- Composite PK `(authority_code, effective_from)`
- Effective end after start
- Nonnegative amount bounds
- Maximum not below minimum
- Required approval count at least 1 and no more than 4 in the opening owner model
- No overlapping active periods for equivalent authority scope
- Valid Business Area, Transaction Type, and Role Code

### 19.5 Indexes

- PK index
- Lookup index `(business_area_code, transaction_type_code, role_code, effective_from)`
- Partial index for active/open-ended authorities when justified by query shape

Owner supermajority and unanimous matters remain governed by the business policy and later approval records; this table defines authorization, not the approval vote itself.

---

## 20. `core.number_sequence`

### 20.1 Purpose

Allocates permanent business numbers without using surrogate table identities.

### 20.2 Columns

| Column | PostgreSQL type | Null | Rule |
|---|---|---:|---|
| `sequence_code` | `text` | No | Primary natural key |
| `prefix` | `text` | Yes | Governed display/storage prefix |
| `next_value` | `bigint` | No | Positive next numeric portion |
| `display_width` | `smallint` | No | Numeric zero-padding width |
| `last_allocated_at` | `timestamptz` | Yes | Diagnostic/control timestamp |
| `last_allocated_by_principal_code` | `text` | Yes | FK to Principal |
| `updated_at` | `timestamptz` | No | Latest update |
| `updated_by_principal_code` | `text` | No | FK to Principal |
| `row_version` | `bigint` | No | Positive concurrency version |

### 20.3 Constraints

- PK `sequence_code`
- Uppercase governed sequence code
- Prefix contains only approved uppercase letters, digits, or hyphen
- `next_value > 0`
- Display width from 1 through 18
- Last-allocated Principal and timestamp are either both null or both present
- Positive row version

### 20.4 Allocation behavior

Number allocation is performed by the required database function `core.allocate_business_number(sequence_code, principal_code)`. It returns one formatted business number and updates the governing row atomically.

The function is owned by `pfd_database_owner`, executes with tightly controlled definer rights, sets a safe search path internally, validates both input codes, and exposes `EXECUTE` only to approved application and change roles. Application roles do not receive direct update permission on `core.number_sequence`.

The function:

1. Begins a database transaction.
2. Locks the one `core.number_sequence` row for the requested sequence.
3. Reads and validates `next_value`.
4. Constructs the permanent business number from prefix and width.
5. Advances `next_value` exactly once.
6. Records allocator and timestamp.
7. Uses the allocated number in the business transaction before commit.
8. Commits the allocation with the business record when they are part of the same command.

Numbers are never assigned using `MAX(...) + 1`. A rolled-back transaction may reuse an uncommitted allocation. A committed allocation is never reassigned, even when the business document is later cancelled.

### 20.5 Opening sequence rows

The Core Build creates only sequences required by bootstrap/core operation. Domain business sequences are introduced by their owning build package.

Opening examples:

- `DATABASE_CHANGE` is not allocated from this table; its governed number is the SQL filename sequence.
- `DOCUMENT` may be deferred until Document Metadata is implemented.
- `SIMULATION_SESSION` is deferred to the Simulation package.

---

## 21. Constraint Naming

### 21.1 Pattern

| Constraint | Pattern | Example |
|---|---|---|
| Primary key | `pk_<table>` | `pk_customer` |
| Foreign key | `fk_<table>_<parent>` | `fk_company_principal_created_by` |
| Unique | `uq_<table>_<purpose>` | `uq_principal_external_subject` |
| Check | `ck_<table>_<purpose>` | `ck_company_fiscal_start_month` |
| Exclusion | `ex_<table>_<purpose>` | `ex_approval_authority_no_overlap` |

Names identify business purpose rather than listing every long composite-key column.

### 21.2 Natural-key requirements

- Every table has an explicitly named primary-key constraint.
- No table receives an implicit identity column.
- Composite foreign-key names identify the parent relationship.
- Foreign-key column order exactly matches the referenced primary or unique key.
- Primary-key columns are `NOT NULL` by definition.
- Natural-key immutability is enforced by application authorization and audit; cascading key updates are not used.

---

## 22. Index Naming

Indexes use:

```text
ix_<table>_<purpose>
```

Examples:

- `ix_principal_type_active`
- `ix_unit_of_measure_class_active`
- `ix_approval_authority_lookup`

Rules:

- Do not create a duplicate of a primary-key or unique-constraint index.
- Index foreign keys when needed for joins or parent-change checks.
- Use partial indexes for genuinely selective active/open rows.
- Include columns only after a proven query need.
- Record the business/query purpose in a PostgreSQL comment or design note.

---

## 23. Database Comments

Change `0010` adds comments for:

- Every schema
- Every Core Build table
- Every table's business owner and purpose
- Every primary/business key
- Sensitive or controlled columns
- Non-obvious checks and effective-date rules
- `core.database_change` immutability
- `core.number_sequence` allocation requirements
- The fact that Simulation Session does not scope operational business data

Comments explain meaning and control. They do not duplicate obvious SQL syntax.

---

## 24. Privilege Specification

### 24.1 Ownership

- Database: `pfd_database_owner`
- Schemas: `pfd_database_owner`
- Tables, sequences if ever approved, views, functions, and constraints: `pfd_database_owner`
- Change Executor applies changes using controlled membership or `SET ROLE` without becoming permanent object owner.

### 24.2 Schema privileges

| Role | Core usage | Core create | Direct table write | Read |
|---|---:|---:|---:|---:|
| `pfd_database_owner` | Yes | Yes | Yes | Yes |
| `pfd_change_executor` | Yes | During approved build | During approved build | Yes |
| `pfd_application` | Yes | No | Only explicitly granted application operations | Required operational tables |
| `pfd_app` | Through `pfd_application` | No | Through `pfd_application` | Through `pfd_application` |
| `pfd_reporting` | Yes | No | No | Approved views/tables only |
| `pfd_support_readonly` | Yes | No | No | Approved diagnostic objects |
| `PUBLIC` | No by default | No | No | No |

### 24.3 Core table access

- `core.database_change`: application/reporting read only if required; writes only by Change Executor.
- `core.principal`: application controlled read; controlled administration write; reporting only when approved.
- `core.company`: application read; controlled administration write.
- Reference tables and Unit of Measure: application read; controlled administration write.
- Approval Authority: application read; authorized governance administration write.
- Number Sequence: application accesses through the approved allocation operation; unrestricted direct update is prohibited.

### 24.4 Default privileges

Default privileges are explicitly set for each schema so future objects do not inherit broad access accidentally. Adding a table does not automatically grant application write access.

---

## 25. Change-by-Change Definition

### 25.1 Change `0001`

**File:** `0001_create_core_change_history.sql`

Creates:

- `core` schema
- `core.database_change`
- Required constraints
- Change `0001` history row

### 25.2 Change `0002`

**File:** `0002_create_functional_schemas.sql`

Creates every approved functional schema, ownership, base usage restrictions, and schema comments.

### 25.3 Change `0003`

**File:** `0003_create_core_reference_tables.sql`

Creates:

- `core.principal_type`
- `core.unit_class`
- `core.business_area`
- `core.transaction_type`
- `core.role_code`

Creator/updater Principal foreign keys are added in change `0004`.

### 25.4 Change `0004`

**File:** `0004_create_core_principal.sql`

Creates `core.principal`, inserts bootstrap Principals, adds self-references, and adds Principal foreign keys to already-created Core tables including `core.database_change`.

### 25.5 Change `0005`

**File:** `0005_create_core_company.sql`

Creates `core.company`. Company identity is supplied later by the selected opening dataset.

### 25.6 Change `0006`

**File:** `0006_create_core_unit_of_measure.sql`

Creates `core.unit_of_measure` and its opening fixed units.

### 25.7 Change `0007`

**File:** `0007_create_core_approval_authority.sql`

Creates `core.approval_authority`, including effective-date and overlap controls.

### 25.8 Change `0008`

**File:** `0008_create_core_number_sequence.sql`

Creates `core.number_sequence` and the controlled `core.allocate_business_number(sequence_code, principal_code)` database function.

### 25.9 Change `0009`

**File:** `0009_seed_core_reference_data.sql`

Loads and validates the approved opening Core reference rows. Rows needed earlier for bootstrap are inserted initially by their structural change and verified here against the authoritative seed set.

### 25.10 Change `0010`

**File:** `0010_apply_core_comments_and_grants.sql`

Applies final Core Build comments, role grants, default privileges, and revocations.

---

## 26. Handling the Bootstrap Data Dependency

Principal audit columns create a deliberate bootstrap dependency: reference rows need a creator, but the Principal table depends on Principal Type.

The approved solution is:

1. Change `0003` creates reference structures with audit columns but defers audit-column Principal foreign keys.
2. Change `0003` inserts the minimum `DATABASE_BUILD` Principal Type row required by change `0004`.
3. Change `0004` creates Principal and inserts `DATABASE_BUILD` using self-referencing audit values.
4. Change `0004` adds and validates all deferred Principal foreign keys.
5. Change `0009` reconciles the complete reference data to the approved source files.

No null audit actor, zero identifier, or surrogate bootstrap key is introduced.

---

## 27. Verification Framework

Every verification file is read-only and terminates with failure when an assertion is not satisfied.

### 27.1 `verify_change_history.sql`

Confirms:

- Changes `0001` through `0010` exist exactly once
- Filenames and checksums match the manifest
- Applied timestamps are ordered consistently
- Required Principal Codes exist
- No unknown change exists

### 27.2 `verify_schemas.sql`

Confirms the exact approved schema set, owners, and absence of unexpected broad creation privileges.

### 27.3 `verify_core_tables.sql`

Confirms required tables and columns with expected PostgreSQL data types and nullability.

### 27.4 `verify_core_constraints.sql`

Confirms:

- Natural and composite primary keys
- Foreign keys
- Unique constraints
- Check constraints
- Effective-date overlap protection
- All constraints are validated

### 27.5 `verify_core_indexes.sql`

Confirms required nonredundant indexes and their leading columns/predicates.

### 27.6 `verify_core_reference_data.sql`

Confirms exact required codes, expected counts, active status, effective dates, and source checksums/control totals.

### 27.7 `verify_core_privileges.sql`

Confirms ownership, schema usage, table permissions, default privileges, and absence of unauthorized `PUBLIC` or runtime-role DDL privileges.

### 27.8 `verify_no_surrogate_keys.sql`

Fails when the schemas contain:

- An identity column
- A `serial`-owned sequence pattern
- A primary key named generically with `_id`
- A UUID primary key standing in for an available business number/code
- An unexplained single numeric primary key on a business table

### 27.9 `verify_core_build.sql`

Runs the complete verification suite in required order and returns one overall result suitable for automation.

---

## 28. Core Test Specification

### 28.1 Natural-key tests

- Duplicate Company Code fails.
- Duplicate Principal Code fails.
- Duplicate Unit Code fails.
- Duplicate Sequence Code fails.
- Duplicate Approval Authority/effective start fails.
- Attempted null primary-key component fails.
- Attempted change of an issued key through ordinary application privileges fails.

### 28.2 Foreign-key tests

- Unknown Principal Type fails.
- Unknown Unit Class fails.
- Unknown creator/updater Principal fails after deferred constraints are installed.
- Unknown Business Area, Transaction Type, or Role Code fails for Approval Authority.

### 28.3 Check-constraint tests

- Invalid fiscal month fails.
- Invalid currency code fails.
- Negative or excessive decimal scale fails.
- Invalid effective interval fails.
- Negative amount boundary fails.
- Maximum approval amount below minimum fails.
- Zero approval count fails.
- Nonpositive number-sequence next value fails.
- Invalid checksum/change-number format fails.

### 28.4 Lifecycle tests

- An inactive reference row remains referentially valid for existing records.
- A code cannot be silently replaced with different meaning.
- Effective periods cannot overlap where prohibited.
- Audit timestamps and row versions advance correctly.

### 28.5 Number-allocation tests

- Concurrent allocations return distinct permanent numbers.
- Committed numbers are never reused.
- A rolled-back allocation does not advance the committed sequence.
- Prefix and width formatting is correct.
- `MAX + 1` is not used.
- Unauthorized direct sequence update fails.

### 28.6 Privilege tests

- Application cannot create, alter, or drop objects.
- Reporting cannot modify Core tables.
- Support Readonly cannot modify data.
- Application cannot update `core.database_change`.
- Application can perform only approved number allocation.
- `PUBLIC` cannot create in the schemas.

---

## 29. Empty-Build Procedure

The accepted empty-build procedure is:

1. Provision an empty supported PostgreSQL instance or approved cluster location.
2. Execute bootstrap roles and database creation with authorized administration.
3. Run bootstrap verification.
4. Run `pfd_db_build validate` against the Core Build manifest.
5. Run `pfd_db_build build-and-verify`.
6. Run Core tests against the disposable database.
7. Confirm ending database change `0010`.
8. Produce the build evidence package.

No interactive SQL edits are permitted between steps.

---

## 30. Existing-Database Update Procedure

For a database already below Core Build version `0010`:

1. Confirm target environment and authoritative/disposable classification.
2. Read current change status.
3. Validate all previously applied checksums.
4. Confirm a continuous pending change sequence.
5. Confirm backup/recovery requirement.
6. Pause writes if required by the release manifest.
7. Apply pending changes.
8. Run complete Core verification.
9. Run application smoke tests when an application exists.
10. Record evidence and resume operation.

If the database contains an unknown change or checksum mismatch, execution stops for investigation. The runner never repairs history automatically.

---

## 31. Failure and Recovery Rules

- Transactional change failure rolls back the full change.
- No successful history row is recorded for a rolled-back change.
- The build stops at the failed change.
- The SQL file is corrected before shared application only if it has never succeeded in any shared environment.
- Once applied in a shared environment, correction uses a new change number.
- No later change is applied over an unresolved earlier failure.
- Authoritative restoration requires approved recovery procedures and post-restore business reconciliation.
- Disposable databases may be dropped and rebuilt through guarded operations scripts.

---

## 32. Build Evidence Package

Every shared-environment Core Build retains:

- Build manifest
- File checksums
- Bootstrap verification result
- Build-runner log
- Starting and ending change status
- Core verification results
- Test results
- Role/privilege report
- PostgreSQL version and environment identity
- Implementer and verifier
- Start/end timestamps
- Exceptions, approvals, and recovery actions if any

The evidence package contains no passwords or protected business data.

---

## 33. Core Build Acceptance Criteria

The Core Build is accepted only when:

1. A new database builds from empty without manual structural edits.
2. Changes `0001` through `0010` apply in exact order.
3. Every applied checksum matches the manifest.
4. All functional schemas exist with correct ownership.
5. All Core tables use approved natural or composite primary keys.
6. No surrogate/identity primary key exists.
7. All required constraints are present and validated.
8. Reference data matches the approved sources and control totals.
9. `core.company` has the approved structure and constraints; baseline verification separately proves that the selected opening dataset supplies a valid Company row.
10. Required bootstrap Principals and Units exist.
11. Number allocation passes concurrency and rollback tests.
12. Runtime and reporting privileges match the approved matrix.
13. Complete verification and Core tests pass.
14. Reapplying the build reports no pending change and makes no database change.
15. The evidence package is complete.

---

## 34. Required Implementation Outputs

Implementation of this specification produces:

- Repository folders and READMEs
- Three bootstrap SQL files
- Ten permanent change SQL files
- Core Build manifest
- Five Core reference-data source files
- Nine verification SQL files
- Six Core test SQL files
- Build-runner implementation and documentation
- Disposable-database operation scripts
- Core data dictionary
- Core privilege matrix

File counts may increase only when a coherent change or test must be split for safety. Existing specified filenames and responsibilities remain stable unless this specification is formally revised before implementation.

---

## 35. Recommended Next Deliverable

The next deliverable should be the **PostgreSQL Core Build SQL Package**.

That deliverable will create the actual repository structure and executable files defined here, beginning with:

- Bootstrap role and database scripts
- `0001_create_core_change_history.sql`
- `0002_create_functional_schemas.sql`
- Core Build manifest
- Initial build-runner contract implementation
- Empty-build verification

The package should be implemented incrementally and executed against a disposable PostgreSQL database before later domain tables are added.

---

## 36. Completion Status

This document completes the detailed repository and Core Build specification for the business as of September 4, 2026.

It provides the exact implementation boundary between approved database design and the first executable PostgreSQL build package while preserving natural primary keys, normalized relational structure, controlled change history, and continuous business data across Simulation Sessions.
