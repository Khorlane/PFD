# \<business name>

## PostgreSQL Database Build and Change-Control Plan

**Company abbreviation:** PFD  
**Database platform:** PostgreSQL  
**Document date:** September 4, 2026  
**Document status:** Authoritative database implementation plan  

**Governing documents:**

- `PFD_Business_Model_and_Operating_Policies.md`
- `PFD_Business_to_IT_Capability_Specification.md`
- `PFD_Information_Model_and_Record_Ownership_Specification.md`
- `PFD_Business_Process_and_Transaction_Lifecycle_Specification.md`
- `PFD_Persistent_Data_Architecture_and_Database_Standards_Specification.md`
- `PFD_Relational_Schema_and_Table_Definition_Specification.md`

---

## 1. Purpose

This plan defines how PFD's PostgreSQL database will be created, validated, changed, promoted, recovered, and documented.

PFD is a new system. There is no legacy database conversion implied by this plan. The first set of SQL files builds the database from an empty PostgreSQL database. Later files make controlled changes without rebuilding or manually editing an authoritative database.

The plan establishes:

- Repository and SQL-file organization
- Initial database build sequence
- Future database change process
- Environment and role separation
- Schema-version recording
- Reference and opening-data loading
- Constraint and index implementation order
- Testing and acceptance requirements
- Backup, recovery, and correction rules
- Continuous-simulation database handling

This is an implementation-control document. It does not yet contain executable table DDL.

---

## 2. Terminology

### 2.1 Initial build

The complete ordered execution of PFD SQL files against an empty PostgreSQL database to create a usable PFD database.

### 2.2 Database change

A numbered, source-controlled SQL file that makes one coherent change to an existing database. Examples include adding a table, adding a column, introducing a constraint, correcting reference data, or creating an index.

### 2.3 Build runner

The controlled process that:

1. Connects with the authorized database-change role.
2. Reads the database's applied-change history.
3. Verifies pending file names and checksums.
4. Executes unapplied changes in order.
5. Records successful completion.
6. Stops on the first failure.

The initial implementation may use `psql` under a controlled script or build pipeline. The SQL files remain independent of a particular commercial change-management product.

### 2.4 Authoritative environment

The continuing PFD business database whose records carry forward from one simulated day or week to the next. It is production-shaped even while the business is simulated.

### 2.5 Disposable environment

A development, automated-test, or deliberate alternate-test database that may be dropped and rebuilt without affecting authoritative business history.

---

## 3. Governing Principles

1. PostgreSQL is the sole authoritative operational data store.
2. The operational model remains normalized to at least Third Normal Form unless an approved exception exists.
3. Stable business numbers, codes, and governed composite keys are primary keys; surrogate identity keys are not used.
4. Foreign keys carry the complete natural key of the referenced record.
5. Business records continue across Simulation Sessions and contain no simulation partition key.
6. Simulation Session records are technical control records only.
7. Every database structure and reference-data change is represented by an ordered SQL file.
8. An applied SQL file is immutable. Corrections use a new change file.
9. Application releases and required database versions are explicitly paired.
10. Database constraints protect business and accounting integrity even when application validation fails.
11. Completed business history is corrected through normal business transactions, not destructive rewrites.
12. Authoritative database changes are preceded by testing, approval, backup assessment, and a recovery plan.

---

## 4. Environment Model

| Environment | Purpose | Data policy | Rebuild policy |
|---|---|---|---|
| Developer | Individual SQL and application development | Artificial data only | Freely rebuildable |
| Integration | Combined database/application testing | Controlled representative data | Rebuilt regularly |
| Automated Test | Repeatable lifecycle, constraint, and accounting tests | Deterministic fixtures | Rebuilt for each test cycle |
| Acceptance | Owner and business-process validation | Approved realistic test data | Rebuilt by release procedure |
| Authoritative Simulation | Continuing PFD business operation | Authoritative simulated business records | Never routinely reset |
| Alternate Test Copy | Deliberate stress, replay, or what-if test | Restored copy or approved baseline | Disposable and isolated |

Each environment uses separate database credentials and connection configuration. Alternate Test Copies cannot connect with write privileges to the Authoritative Simulation database.

---

## 5. Repository Structure

The recommended database repository structure is:

```text
database/
  README.md
  build/
    create_database.sql
    verify_prerequisites.sql
  changes/
    0001_core_prerequisites.sql
    0002_core_reference.sql
    ...
  repeatable/
    reporting_views.sql
    database_comments.sql
  reference-data/
    manifests/
    source/
  opening-data/
    manifests/
    source/
  test/
    fixtures/
    assertions/
    lifecycle/
    accounting/
    performance/
  operations/
    backup/
    restore/
    verify/
  documentation/
    change-records/
    data-dictionary/
```

### 5.1 Folder rules

- `changes` contains every permanent ordered database change.
- `repeatable` contains derived objects that can be recreated from authoritative tables, such as views and comments. Their definitions remain source-controlled.
- `reference-data` contains governed stable codes and their manifests.
- `opening-data` contains the approved initial PFD master and financial data, not ordinary ongoing transactions.
- `test` contains no authoritative business data.
- `operations` contains controlled administrative procedures, not application business logic.
- Generated backups, passwords, local connection files, logs, and temporary exports are not committed to source control.

---

## 6. SQL File Standards

### 6.1 Ordered filename

Permanent change files use:

```text
NNNN_short_business_description.sql
```

Example:

```text
0042_add_supplier_discount_terms.sql
```

Rules:

- The number is four digits and strictly increasing.
- A number is never reused, even if the file is abandoned after application.
- Names use lowercase `snake_case`.
- Each file represents one coherent change.
- File order, not filesystem timestamp, determines execution order.

### 6.2 Required file header

Each permanent SQL file documents:

- Change number and title
- Purpose and business requirement
- Author
- Approval reference
- Required preceding database version
- Transaction behavior
- Expected locks or service interruption
- Data-conversion or backfill behavior
- Validation queries
- Recovery method

### 6.3 SQL behavior

- Schema-qualified object names are used.
- Session settings required for correctness are declared explicitly.
- SQL files do not depend on an operator's search path, locale, or interactive state.
- Destructive operations are isolated, justified, and specially approved.
- `DROP ... CASCADE` is prohibited in ordinary permanent changes.
- Unbounded updates or deletes of authoritative data are prohibited.
- Dynamic SQL is used only when ordinary declarative SQL is inadequate.
- PostgreSQL comments document important tables, columns, constraints, and functions.

---

## 7. Database Change History

`core.database_change` records the applied build history.

| Column | Type | Rule |
|---|---|---|
| `change_number` | `text` | Primary key; four-digit governed number |
| `change_name` | `text` | Must match the SQL filename description |
| `file_name` | `text` | Unique |
| `file_checksum` | `text` | Required; calculated before execution |
| `applied_at` | `timestamptz` | Required |
| `applied_by_principal_code` | `text` | Required |
| `execution_duration_ms` | `bigint` | Required and nonnegative |
| `application_release` | `text` | Associated release when applicable |
| `notes` | `text` | Optional |

The table uses no generated identity key.

The build runner refuses to continue when:

- An applied file's checksum differs from the recorded checksum.
- Two files use the same change number.
- A sequence gap is unexplained by the release manifest.
- The database contains a later unknown change.
- A required prerequisite or PostgreSQL version is not satisfied.

---

## 8. Initial Database Build Sequence

The initial database is built in the following batches.

| Batch | Scope | Principal result |
|---:|---|---|
| 0001 | Prerequisites and ownership | Required PostgreSQL settings, owner role, schemas, change-history table |
| 0002 | Core reference data | Stable status, classification, unit, reason, and lifecycle codes |
| 0003 | Core and Party | Principal, Company, Facility, locations, calendar, Person, Address, Contact |
| 0004 | Simulation controls | Session, configuration, random stream, event queue, attempt, checkpoint |
| 0005 | HR foundation | Department, Position, Employee, assignments, qualifications, compensation |
| 0006 | Product foundation | Category, Product, Product Pack, storage, shelf life, substitution |
| 0007 | Supplier and Customer | Supplier, Customer, locations, contacts, terms, contracts, credit foundation |
| 0008 | Price and cost | Supplier cost, price lists, customer/contract price, premiums, margin controls |
| 0009 | Sales and purchasing | Sales Orders, Purchase Orders, lines, holds, changes, commitments |
| 0010 | Inventory | Lots, pallets, movements, balances, allocations, counts, valuation layers |
| 0011 | Warehouse | Appointments, receipts, putaway, replenishment, picks, staging, loading |
| 0012 | Transportation | Fleet, maintenance, routes, stops, deliveries, proof and returns |
| 0013 | Quality and service | Holds, observations, sanitation, recall, cases, returns, dispositions |
| 0014 | Finance | Chart of accounts, periods, journals, AR, AP, cash, debt, equity, assets, budgets |
| 0015 | Payroll | Scheduling, time, payroll results, payments, liabilities, accounting links |
| 0016 | Reporting and audit | Reports, KPIs, actions, approvals, overrides, audit and recovery records |
| 0017 | Cross-domain completion | Deferred foreign keys, final checks, unique constraints, indexes, views, comments |
| 0018 | Opening data controls | Reference verification and controlled opening-data load procedures |

Batch numbers define implementation order; individual files within a batch retain unique four-digit change numbers. The executable build may therefore use several files for each batch.

---

## 9. Object Creation Order Within a Batch

The normal order is:

1. Required reference tables
2. Parent tables
3. Child and relationship tables
4. Primary and unique constraints
5. Immediate foreign keys
6. Check constraints
7. Essential indexes
8. Functions required by triggers
9. Triggers
10. Views and reporting objects
11. Object comments
12. Validation assertions

Selected cross-domain foreign keys are added in Batch 0017 to resolve legitimate creation dependencies. They are deferred in build order, not omitted from the completed database.

---

## 10. Natural-Key Implementation Rules

- Customer Master primary key: `customer_number`.
- Supplier primary key: `supplier_number`.
- Product primary key: `product_number`.
- Employee primary key: `employee_number`.
- Truck primary key: `truck_number`.
- Document headers use their governed document number.
- Document lines use `(document_number, line_number)`.
- Code-defined masters and reference tables use their business code.
- Effective-dated relationships use the parent key or keys plus `effective_from`.
- Repeated activities use the owning business key plus a governed sequence.
- Infrastructure records use stable technical composite keys rather than identity columns.
- Foreign keys repeat the complete referenced natural or composite key.
- Issued primary keys are immutable and never reused.

DDL review shall reject an unexplained `serial`, `bigserial`, `GENERATED ... AS IDENTITY`, UUID surrogate, or generic `*_id` primary-key column.

---

## 11. Reference-Data Build

### 11.1 Reference-data classes

- Technical codes required for the database to function
- Business lifecycle and status codes
- Reason and classification codes
- Units of measure
- Accounting and reporting classifications

### 11.2 Loading rules

- Reference codes are explicit and stable.
- A code is never silently repurposed.
- Display-name changes do not change the primary key.
- Files contain expected row counts and checksums.
- Inserts fail on unexpected existing values rather than hiding differences.
- Updates are explicit and reviewed.
- Removal normally means inactivation or effective dating, not deletion.
- Every referenced code is loaded before dependent opening data.

### 11.3 Reconciliation

After each reference-data batch, automated checks confirm:

- Expected code count
- Required opening codes present
- No duplicate code
- Effective-date validity
- No inactive code used as a new default
- No orphan reference

---

## 12. Opening Business-Data Load

Opening data is loaded only after the structural build and reference validation succeed.

### 12.1 Load order

1. Company and facility
2. Warehouse zones and locations
3. Operating calendar, shifts, and approval authorities
4. People, owners, departments, positions, and employees
5. Products, categories, units, packs, and storage rules
6. Suppliers, supplier products, costs, terms, and contacts
7. Customers, locations, contacts, contracts, credit profiles, and prices
8. Trucks, compartments, route patterns, and assignments
9. Chart of accounts and accounting periods
10. Owner capital, debt, fixed assets, cash, and bank opening records
11. Beginning inventory lots, pallets, balances, and FIFO valuation layers
12. Balanced opening Journal Entries and subsidiary reconciliations

### 12.2 Required controls

- Input manifest, checksum, record count, and control totals
- Staging before promotion to authoritative tables
- Complete validation and reject reporting
- One controlled promotion transaction per coherent load group
- Referential-integrity validation
- Inventory quantity and value reconciliation
- Cash, debt, equity, fixed-asset, AR, AP, payroll, and GL reconciliation
- Owner approval of the final opening balance sheet

There are no inherited AR or AP balances unless expressly approved in the opening business data.

---

## 13. Transaction and Locking Rules

- A database change runs in one transaction whenever PostgreSQL permits.
- Failure rolls back the entire change before its history row is recorded.
- Nontransactional operations, when unavoidable, use a dedicated file and explicit recovery procedure.
- Lock level and expected duration are evaluated before approval.
- Long data backfills are separated from final constraint enforcement when necessary.
- Authoritative operation is paused when a change cannot be proven safe under normal workload.
- Business users are not allowed to continue through an unknown partially applied structural change.

---

## 14. Constraint Introduction

New constraints on existing data follow this sequence when a table is already populated:

1. Assess existing data.
2. Correct invalid data through an approved business or database correction.
3. Add the constraint using the least disruptive safe PostgreSQL method.
4. Validate the constraint.
5. Confirm dependent application behavior.
6. Record evidence in the change record.

Constraints are not permanently left disabled merely to complete a release.

Mandatory constraint families include:

- Natural and composite primary-key uniqueness
- Foreign-key completeness
- Positive or properly signed quantities and amounts
- Lifecycle timestamp order
- Effective-date validity and non-overlap
- Inventory allocation and balance limits
- Receipt, load, delivery, and payment reconciliation
- One-sided Journal Lines and balanced Journal Entries
- Closed-period posting prohibition
- Unique source-event and idempotency keys

---

## 15. Index Introduction

- Primary and unique constraints create their required indexes.
- Foreign-key and work-queue access paths are individually reviewed.
- Status/date indexes support active operational work.
- Partial indexes are preferred for selective open, available, overdue, pending, or failed populations.
- Large indexes on populated authoritative tables use the safest supported build method for the required availability.
- Redundant and unused indexes are not retained.
- Partitioning is not part of the opening design and requires measured justification.

---

## 16. Repeatable Derived Objects

Views, materialized-view definitions, reporting functions, and database comments may be maintained as repeatable source files when their complete current definition is easier to review than a sequence of small alterations.

Repeatable objects must:

- Depend only on already-applied permanent changes
- Produce the same definition when reapplied
- Carry a recorded checksum
- Avoid changing authoritative business data
- Pass dependency and permission tests

Tables, permanent reference codes, and business-data corrections are never handled as repeatable objects.

---

## 17. Role and Privilege Model

| Role | Login | Purpose |
|---|---:|---|
| `pfd_database_owner` | No | Owns schemas and database objects |
| `pfd_change_executor` | Controlled | Applies approved database changes |
| `pfd_application` | No | Holds approved operational application privileges |
| `pfd_app` | Controlled | Credential-bearing login; member of `pfd_application` |
| `pfd_reporting` | Controlled | Reads approved reporting views |
| `pfd_support_readonly` | Controlled | Diagnostic read access under authorization |
| `pfd_backup_operator` | Controlled | Performs approved backup and restore operations |

Rules:

- Application runtime roles do not own objects.
- Application runtime roles are not superusers.
- Ordinary users do not receive direct table-update privileges.
- Business permissions remain in the application; database privileges provide a second boundary.
- Secrets remain outside source-controlled SQL.
- Privilege tests are part of every release.

---

## 18. Future Database Change Lifecycle

Every proposed change follows this lifecycle:

```text
Requested
  -> Analyzed
  -> Designed
  -> SQL Written
  -> Peer Reviewed
  -> Automated Tests Passed
  -> Business/Owner Approval When Required
  -> Acceptance Applied
  -> Release Approved
  -> Authoritative Database Applied
  -> Verified
  -> Closed
```

### 18.1 Change request contents

- Business reason and affected process
- Affected schemas, tables, reports, and applications
- Compatibility and downtime assessment
- Data backfill or correction requirements
- Security, audit, accounting, and retention impact
- Test evidence
- Backup and recovery plan
- Release owner and approvals

### 18.2 Approval level

Routine additive, low-risk changes require technical review and the responsible business owner. Changes affecting accounting logic, security, owner information, payroll, inventory valuation, retention, or destructive data handling require Finance/General Management approval as applicable.

---

## 19. Applied-File Immutability

After a change is applied to any shared environment:

- Its number, filename, and contents are frozen.
- It is not edited to make a later build pass.
- A defect is corrected in a new higher-numbered file.
- Checksum mismatch is treated as a release-control failure.
- Source-control history does not replace the database's applied-change record.

Disposable developer databases may be rebuilt, but shared history remains immutable.

---

## 20. Correction and Recovery Strategy

### 20.1 Forward correction

The normal response to a successfully applied but defective structural change is a new forward change that restores the intended design while preserving data.

### 20.2 Transaction rollback

If a change fails within its transaction, PostgreSQL rolls it back and the build stops. No successful history row is recorded.

### 20.3 Backup restoration

Restoration is used when:

- A change caused material authoritative corruption.
- Safe forward correction cannot be completed within the approved recovery period.
- A nontransactional operation failed in an unrecoverable state.
- Management explicitly chooses to abandon all business activity after the protected recovery point.

Restoration of the Authoritative Simulation database requires reconciliation of any business activity performed after the restored backup.

### 20.4 Down scripts

Automatic down scripts are not the primary recovery method. Reversing structural changes after business use can silently discard data or invalidate accounting history. Any reversal script is separately reviewed and never executed automatically in an authoritative environment.

---

## 21. Application Compatibility

Each application release declares:

- Minimum supported database change number
- Maximum tested database change number when applicable
- Required reference-data version
- Whether the database change must precede, accompany, or follow application deployment

Changes should be backward-compatible across the deployment window when practical. Breaking renames and removals use staged changes:

1. Add the new structure.
2. Deploy code that supports it.
3. Backfill and validate.
4. Stop use of the old structure.
5. Remove the old structure in a later approved release.

---

## 22. Continuous-Simulation Controls

- Normal database changes never create a new business-data partition for a Simulation Session.
- Customer, Product, Supplier, Employee, Inventory, Sales, Purchasing, Delivery, AR, AP, Payroll, and GL history remains continuous.
- A session may be paused for an approved database change and resumed after verification.
- Scheduled events and incomplete technical work are reconciled before and after the change.
- A database backup or named recovery point is taken before high-risk changes.
- Alternate tests use a separate restored database with separate credentials and an unmistakable environment label.
- Results from an Alternate Test Copy are not merged automatically into the Authoritative Simulation database.

---

## 23. Automated Database Tests

### 23.1 Empty-build test

Every proposed release builds a new database from empty using all ordered files. This proves that a new PFD environment can be recreated without undocumented manual actions.

### 23.2 Sequential-upgrade test

The release is applied to a database at the immediately preceding supported version containing representative business history. Existing data and relationships must remain valid.

### 23.3 Structural tests

- Required schemas, tables, columns, constraints, indexes, views, and comments exist.
- No unauthorized object exists.
- No surrogate identity or generic `*_id` primary key has been introduced.
- Every natural and composite key matches the relational specification.
- Every expected foreign key is present and valid.

### 23.4 Business-integrity tests

- Customer and Supplier master uniqueness
- Order, Purchase Order, Receipt, Delivery, Invoice, Payment, and Journal numbering
- FEFO physical selection and FIFO financial valuation
- Inventory movement/balance agreement
- Allocation limits
- Receipt, load, delivery, return, and payment reconciliation
- Invoice pending-delivery and final posting behavior
- AR/AP subsidiary-to-GL agreement
- Balanced Journal Entries and closed-period protection
- Payroll result, payment, liability, and GL agreement

### 23.5 Restart and idempotency tests

- Failed event processing restarts without duplicate business effect.
- Repeated commands with the same idempotency key do not duplicate documents or postings.
- A database change cannot be applied twice.
- An interrupted build stops safely and reports its exact state.

### 23.6 Security tests

- Runtime roles cannot change structure.
- Reporting roles cannot modify business data.
- Unauthorized roles cannot read protected payroll, employee, banking, credit, or owner data.
- Change execution is attributable to an approved Principal.

### 23.7 Performance tests

The opening build is tested at no less than ten times expected opening master and representative annual transaction volume. Tests focus on active orders, available inventory, picking, receiving, routes, AR/AP aging, journals, event queues, and weekly/monthly reporting.

---

## 24. Release Manifest

Every database release includes a manifest containing:

- Release number and date
- Included change files in execution order
- Expected pre-release and post-release change numbers
- File checksums
- Required PostgreSQL and application versions
- Reference-data versions
- Expected service interruption
- Backup/recovery point requirement
- Validation scripts and expected results
- Responsible implementer, verifier, and approver
- Known limitations or deferred work

The manifest is retained with the release evidence.

---

## 25. Authoritative Release Procedure

1. Confirm approved release manifest.
2. Confirm current database version and applied checksums.
3. Confirm application compatibility.
4. Confirm successful empty-build, upgrade, lifecycle, accounting, security, and performance tests.
5. Reconcile current Inventory, AR, AP, cash, Payroll, and GL.
6. Pause business-clock advancement and application writes when required.
7. Confirm backup and recovery point.
8. Apply pending database changes in order.
9. Run structural and data validation.
10. Deploy or enable the compatible application release.
11. Run application smoke tests.
12. Reconcile scheduled events and incomplete work.
13. Resume controlled business operation.
14. Monitor and verify the first post-change cycle.
15. Record implementation evidence and close the change.

If any required validation fails, normal operation does not resume until the approved recovery or forward-correction decision is completed.

---

## 26. Required Post-Build Reconciliations

The completed initial build is not accepted until all of the following pass:

- Opening Inventory quantity equals inventory movement/balance evidence.
- FIFO valuation layers equal beginning Inventory value.
- AR and AP opening details equal their control accounts.
- Bank and cash records equal GL cash.
- Fixed-asset cost and accumulated depreciation equal GL.
- Debt principal equals the debt control accounts.
- Owner capital totals and ownership percentages agree with approved records.
- Payroll opening liabilities, if any, equal GL.
- Trial balance debits equal credits.
- Opening Balance Sheet balances.
- No orphan foreign key, invalid reference code, or unresolved load rejection remains.

---

## 27. Documentation Produced by the Build

The build process shall produce or make reproducible:

- Applied database-change list and checksums
- Database object inventory
- Primary/foreign/unique/check constraint inventory
- Index inventory
- Role and privilege report
- Reference-data inventory
- Table and column comments
- Opening-data load and reject reports
- Reconciliation reports
- Test results
- Release manifest and implementation record

---

## 28. Responsibilities

| Responsibility | Accountable PFD role |
|---|---|
| Business requirement and acceptance | Relevant functional owner |
| Overall database design approval | General Management and IT design authority |
| Accounting integrity | Finance/Admin |
| Product, supplier, warehouse, and inventory integrity | Operations/Purchasing |
| Customer, order, contract, and pricing integrity | Sales |
| SQL preparation and technical review | Database/Application Development |
| Release execution | Authorized Computer Operations/Database Administrator |
| Backup and recovery readiness | IT Infrastructure/Database Administration |
| Post-release verification | Technical implementer plus functional owner |

No person approves and independently verifies their own high-risk authoritative change when practical separation is available.

---

## 29. Initial Implementation Work Packages

The database should be implemented in these controlled work packages:

1. Repository, build runner, change history, roles, and schemas
2. Core reference and governance foundation
3. Party, HR, Product, Supplier, and Customer masters
4. Sales, Purchasing, Inventory, and Warehouse transactions
5. Transportation, Quality, Service, and Returns
6. Finance, Payroll, Reporting, and Audit
7. Cross-domain constraints, indexes, comments, and verification
8. Opening business-data load and reconciliation
9. Full simulated-day acceptance test
10. Multi-day and simulated-week acceptance test

Each work package must build cleanly from empty and upgrade successfully from the preceding accepted package.

---

## 30. Acceptance Criteria

This plan is successfully implemented when:

1. A new PFD database can be built from empty without manual structural edits.
2. Every applied change is recorded with its exact checksum.
3. Natural and composite primary keys match the approved relational specification.
4. All expected foreign keys, checks, unique constraints, and essential indexes are valid.
5. Reference and opening data load through controlled, reconciled procedures.
6. Application roles have only approved privileges.
7. A prior accepted database upgrades without losing or misclassifying business history.
8. Inventory, AR, AP, cash, assets, debt, payroll, and GL reconcile.
9. Backup restoration and post-restore validation succeed.
10. A full simulated business day and week complete using the same continuing operational database.

---

## 31. Decisions Locked by This Plan

1. The project uses the term **database build and change control**, not legacy database migration.
2. The database is built and changed through ordered, source-controlled SQL files.
3. Applied permanent SQL files are immutable.
4. `core.database_change` records applied files and checksums using `change_number` as its natural primary key.
5. Surrogate primary keys are prohibited.
6. Business data remains continuous across Simulation Sessions.
7. Disposable alternate tests are isolated as separate databases.
8. Authoritative corrections normally move forward through a new change file.
9. Automatic down scripts are not used as the routine recovery method.
10. Empty-build and sequential-upgrade tests are both mandatory.
11. Database and application release compatibility is explicit.
12. Opening data is staged, validated, promoted, and financially reconciled.
13. High-risk changes require a protected recovery point and documented recovery decision.
14. The initial build follows the domain order established by the relational specification.

---

## 32. Recommended Next Deliverable

The next deliverable should be the **PFD Database Repository and Core Build Specification**.

It should define the concrete repository files and the first executable PostgreSQL work package:

- Database and schema creation scripts
- Database roles and grants
- `core.database_change`
- Core reference-table template
- Principal and Company tables
- Natural-key constraint naming
- Build-runner behavior
- Empty-build verification tests

After that specification is approved, the first executable PostgreSQL SQL files can be produced.

---

## 33. Completion Status

This document completes the implementation plan for creating and controlling PFD's PostgreSQL database as of September 4, 2026.

It converts the approved business, information, process, persistence, and relational designs into a controlled build sequence without introducing legacy-conversion assumptions, surrogate keys, or Simulation Session partitions in operational business data.
