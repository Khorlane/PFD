# Codex Session Handoff — \<business name>

**Project:** \<business name> (PFD)  
**Handoff date:** September 5, 2026  
**Current phase:** Design complete; executable implementation underway  
**User:** \<owner 1>  
**Primary location:** \<business address>

## 1. Resume instruction

Continue the PFD project from the approved design baseline. Do not restart discovery or redesign settled business rules. The design-document phase is complete.

The executable PostgreSQL Core Build already exists through change `0010`. Verify and preserve that package, then continue implementation with Party and Customer changes `0011`–`0022`. Do not recreate the Core Build or jump directly into application UI work.

Ask \<owner 1> only when a genuinely material or blocking business choice cannot be resolved from the approved documents or sound business practice. Otherwise proceed using good food-distribution practice, appropriate internal controls, and generally accepted accounting principles.

## 2. Current project state

### Complete

- Business model and operating policies.
- Business-to-IT capability mapping.
- Information ownership and cross-domain model.
- Business processes and transaction lifecycles.
- PostgreSQL persistence and relational standards.
- Logical relational schema design.
- Database build/change-control design.
- Core plus ten functional domain designs.
- PostgreSQL physical build specifications through change `0205`.
- Management reporting and audit design.
- Simulation execution design.
- Opening business-data baseline design.
- Integrated design validation and implementation-readiness review.
- Executable PostgreSQL Core Build SQL package through change `0010`.
- Visual Studio 2026 `.slnx` scaffold with the seven approved native `.vcxproj` boundaries.
- Buildable C++23/MSVC Debug/x64 and Release/x64 configurations with vcpkg explicitly disabled.
- Initial MFC `PfdDesktop` greeting: "Hello from the Food Distribution Simulator"

### Not yet complete

- Executable SQL changes `0011`–`0205`.
- Execution of the existing Core Build against an approved PostgreSQL test instance, unless \<owner 1> separately confirms that it has been run.
- Application services, workflows, screens, reports, integrations, and document generation.
- Actual opening master data, balances, configuration values, and approvals.
- End-to-end, performance, security, recovery, and simulation proving.
- Production operating procedures, training, cutover, and grand-opening authorization.

## 3. Non-negotiable architecture decisions

- PostgreSQL is the authoritative operational database.
- Use normalized relational design and standard relational practices.
- Use stable natural business keys as primary keys.
- Do not introduce surrogate, identity, serial, sequence-only, or UUID substitute primary keys for convenience.
- Composite natural keys are acceptable and required when business identity is contextual.
- Enforce referential integrity, candidate keys, checks, and controlled lifecycle transitions in the database.
- Do not delete history that must be retained. Inactivate master records and correct completed transactions through linked reversals or adjustments.
- Store instants as timezone-aware timestamps; PFD's operating timezone is `America/New_York`.
- Use FEFO or approved shelf-life rotation for physical product movement and FIFO for financial inventory valuation.
- Keep operational source records normalized. Reporting structures must not become independent shadow ledgers.
- Applied database changes are ordered, checksummed, immutable, and promoted unchanged between environments.

## 4. Simulation rule

Simulation must behave like the real business:

- It updates the same ordinary business tables and uses the same services, validations, constraints, postings, and reports.
- No `simulation_session`, run key, or scenario key belongs in Customer, Product, Inventory, Order, Finance, Audit, Reporting, or any other ordinary business table.
- A simulation controller may retain run identity outside the simulated business database.
- Each scenario runs in an isolated database restored from an approved baseline.
- \<owner 1> expects mainly one-day or one-week simulations, not a permanently continuous simulated company.
- A later scenario does not need the previous scenario's simulation history.
- Business history generated inside a run remains internally realistic and supports the same comparisons and books as a real business.
- Seeded randomness and a controlled simulated clock make runs reproducible.

## 5. Business snapshot

PFD is a regional broadline food-service distributor serving:

- Restaurants.
- Hospitals.
- Schools.
- Correctional institutions.
- Hotels.

Primary products include canned and dry goods, frozen goods, fresh produce, paper products, and other consumable food-service supplies.

The service territory uses PFD as the hub with spokes toward:

- Statesville, North Carolina.
- Monroe, North Carolina.
- Rock Hill, South Carolina.
- Gastonia, North Carolina.
- Customers reasonably located along the direct routes between PFD and those endpoints.

## 6. Ownership and responsibility

The selected opening baseline supplies a configurable owner roster. Effective Ownership Interests total exactly 100 percent. Owner identity, owner count, percentage, and management responsibility are data rather than fixed architecture.

General Management, Sales, Operations and Purchasing, and Finance and Administration are effective management assignments independent of ownership percentage. Reserved-matter approval thresholds are effective governance configuration validated against the active owner roster.

Delegated authority must have scope, effective dates, limits, and an audit trail. An affected owner cannot independently approve that owner's own related-party matter. Food-safety and legal obligations override commercial convenience.

## 7. Important operating decisions

- PFD owns its facility, with financing.
- PFD owns its truck fleet, with financing.
- Inbound supplier deliveries require appointments; trucks may not arrive at will.
- Split packs are supported but are undesirable and treated as exceptions.
- The warehouse cannot weigh an item, price-label it, transmit the result to the computer room, and place that variable price on the departing invoice. Do not design operations around catch-weight pricing at shipment.
- Lot and expiration information is captured when present or required.
- The warehouse records the date/time each lot or pallet enters a picking slot.
- Multiple lots may occupy one picking slot when full pallets or operating conditions require it.
- Picking procedure depletes the active lot before moving to the next, unless an authorized exception is recorded.
- Product expected to expire before reasonable customer use should not be shipped merely because it has not yet reached its expiration date.
- Exact outbound-lot tracking is required for regulated, contractual, or PFD risk-designated products.
- Other products may use an exposure-window trace method when exact outbound-lot capture is not required.
- Undisputed portions of supplier invoices are paid on time while disputes are resolved cooperatively.
- Treasury maintains enough liquidity to pay obligations promptly and take economically sound discounts.
- Owners are assumed to have startup capital and enough committed customers for a grand opening.

## 8. Opening-scale assumptions

The approved design baseline assumes approximately:

- 80 customer locations.
- 3,000 products/SKUs.
- 60 approved suppliers, about 40 used regularly.
- Six owned trucks: five normally dispatchable and one spare.
- A roughly 50,000-square-foot owned facility.
- 45–50 employees.

The opening baseline represents **12:00 PM America/New_York on the Sunday immediately preceding PFD's first Monday operating cycle**.

Opening inventory includes lots/date attributes, locations, status, quantities, and FIFO valuation. Accounts receivable and payable normally begin at zero unless explicitly loaded. Opening assets, debt, equity, cash, and inventory must balance.

## 9. Authoritative design documents

### Enterprise foundation

1. `PFD_Business_Model_and_Operating_Policies.md`
2. `PFD_Business_to_IT_Capability_Specification.md`
3. `PFD_Information_Model_and_Record_Ownership_Specification.md`
4. `PFD_Business_Process_and_Transaction_Lifecycle_Specification.md`
5. `PFD_Persistent_Data_Architecture_and_Database_Standards_Specification.md`
6. `PFD_Relational_Schema_and_Table_Definition_Specification.md`
7. `PFD_PostgreSQL_Database_Build_and_Change-Control_Plan.md`
8. `PFD_Database_Repository_and_Core_Build_Specification.md`

### Functional domains

9. `PFD_Party_and_Customer_Domain_Specification.md`
10. `PFD_Party_and_Customer_PostgreSQL_Build_Specification.md`
11. `PFD_Product_Domain_Specification.md`
12. `PFD_Product_PostgreSQL_Build_Specification.md`
13. `PFD_Supplier_and_Purchasing_Domain_Specification.md`
14. `PFD_Supplier_and_Purchasing_PostgreSQL_Build_Specification.md`
15. `PFD_Inventory_Domain_Specification.md`
16. `PFD_Inventory_PostgreSQL_Build_Specification.md`
17. `PFD_Warehouse_Operations_Domain_Specification.md`
18. `PFD_Warehouse_Operations_PostgreSQL_Build_Specification.md`
19. `PFD_Sales_and_Order_Management_Domain_Specification.md`
20. `PFD_Sales_and_Order_Management_PostgreSQL_Build_Specification.md`
21. `PFD_Transportation_and_Delivery_Domain_Specification.md`
22. `PFD_Transportation_and_Delivery_PostgreSQL_Build_Specification.md`
23. `PFD_Finance_and_Accounting_Domain_Specification.md`
24. `PFD_Finance_and_Accounting_PostgreSQL_Build_Specification.md`
25. `PFD_Workforce_and_Payroll_Domain_Specification.md`
26. `PFD_Workforce_and_Payroll_PostgreSQL_Build_Specification.md`
27. `PFD_Quality_Food_Safety_and_Recall_Domain_Specification.md`
28. `PFD_Quality_Food_Safety_and_Recall_PostgreSQL_Build_Specification.md`
29. `PFD_Management_Reporting_and_Audit_Domain_Specification.md`
30. `PFD_Management_Reporting_and_Audit_PostgreSQL_Build_Specification.md`

### Cross-cutting completion documents

31. `PFD_Simulation_Execution_and_Scenario_Control_Specification.md`
32. `PFD_Opening_Business_Data_and_Grand_Opening_Baseline_Specification.md`
33. `PFD_Integrated_Design_Validation_and_Implementation_Readiness_Specification.md`

The uploaded `Design(5).md` was earlier source material. The named PFD specifications above are now the authoritative working baseline.

## 10. Document-precedence rule

Resolve conflicts in this order:

1. An explicitly approved business decision.
2. The most specific and most recently approved domain specification.
3. Its paired PostgreSQL build specification for physical database matters.
4. Cross-domain architecture and lifecycle specifications.
5. Earlier illustrative models or source material.

Do not silently choose between inconsistent statements. Record and resolve any material conflict.

## 11. Database build sequence

| Changes | Package | Design | Executable SQL |
|---|---|---:|---:|
| `0001`–`0010` | Repository and Core | Complete | Complete |
| `0011`–`0022` | Party and Customer | Complete | Not started |
| `0023`–`0032` | Product | Complete | Not started |
| `0033`–`0044` | Supplier and Purchasing | Complete | Not started |
| `0045`–`0056` | Inventory | Complete | Not started |
| `0057`–`0068` | Warehouse | Complete | Not started |
| `0069`–`0082` | Sales and Order Management | Complete | Not started |
| `0083`–`0098` | Transportation and Delivery | Complete | Not started |
| `0099`–`0126` | Finance and Accounting | Complete | Not started |
| `0127`–`0155` | Workforce and Payroll | Complete | Not started |
| `0156`–`0186` | Quality, Food Safety, and Recall | Complete | Not started |
| `0187`–`0205` | Management Reporting and Audit | Complete | Not started |

Opening business data is versioned separately and is not an extension of the schema-change numbering.

## 12. Existing executable package

Current locations after project reorganization:

- Core database assets: `database/`
- Python database-build runner: `tools/database-build/`
- Core release notes: `database/releases/0001-0010-core/`

Contents include:

- Bootstrap scripts for PostgreSQL roles and database creation.
- Ordered SQL changes `0001`–`0010`.
- Checksummed Core Build manifest.
- Controlled Core reference-data snapshots.
- Python build runner using `psql`.
- Read-only verification scripts.
- Rollback-contained behavioral tests.
- Natural-key and no-surrogate-key verification.
- Privilege, data-dictionary, and acceptance documentation.
- Guarded disposable-test-database operations.

Package requirements currently state PostgreSQL 15+ on a vendor-supported release, `psql`, and Python 3.11+.

Do not place passwords, connection strings, or production data in the package. Use approved PostgreSQL service configuration, OS authentication, certificates, or a secret provider.

## 13. Immediate next work

1. Reconcile the existing Core SQL package against the final approved design documents. Preserve changes `0001`–`0010` unless a genuine defect requires a governed forward correction.
2. Run Core validation, build, verification, and tests on an approved disposable PostgreSQL environment when one is available.
3. Implement the Party and Customer SQL package for changes `0011`–`0022`.
4. Extend the cumulative manifest, verification, test coverage, data dictionary, and privilege matrix.
5. Continue domain-by-domain in the approved sequence through `0205`.
6. Assemble the separately versioned opening dataset.
7. Build application services and integrations around the approved transaction lifecycles.
8. Prove end-to-end operation, reconciliation, security, recovery, performance, and one-day/one-week simulation.

The next concrete deliverable should be the **PFD Party and Customer Executable PostgreSQL Build Package**, integrated with the existing Core Build rather than created as an unrelated standalone database.

## 14. Implementation acceptance principles

- A clean empty database builds continuously through the implemented final change.
- An incremental build from the preceding supported version produces the same structure.
- Re-running with no unapplied changes is a safe no-op.
- Applied-change checksums match the manifest.
- Natural-key and no-surrogate checks pass.
- Foreign keys, uniqueness, lifecycle checks, grants, and audit controls pass.
- Behavioral tests use disposable databases or rollback-contained transactions.
- Financial postings balance and operational subledgers reconcile.
- Implementation is not accepted merely because SQL executes; objective business behavior must pass.

## 15. Required end-to-end proving

Eventually test at least:

- Customer setup through order, pick, delivery, invoice, receipt, and ledger reconciliation.
- Supplier setup through purchase order, appointment, receipt, lot, invoice, partial dispute, undisputed payment, and reconciliation.
- Multiple lots in one picking slot with active-lot depletion and exception control.
- Near-expiration review and controlled disposition.
- Short pick, substitution, rejected delivery, return, credit, and inventory disposition.
- Temperature or quality failure through hold, investigation, disposition, corrective action, and financial effect.
- Supplier-lot trace and recall through customer notification, product accounting, effectiveness checks, and closure.
- Route execution, proof of delivery, truck return, and custody reconciliation.
- Time capture through payroll and accounting.
- Month-end reconciliations, financial statements, scorecards, audit evidence, and close.
- Deterministic one-day and one-week simulations restored from the approved baseline.

## 16. Controlled configuration still required

These are implementation/configuration tasks, not structural design gaps:

- Actual customer, product, and supplier rosters.
- Opening prices, costs, credit limits, purchasing terms, and approval limits.
- Route schedules, service calendars, warehouse capacities, and staffing.
- Pay rates, benefits, taxes, registrations, and user assignments.
- Opening cash, equity, loan terms, assets, inventory, and other balances.
- Insurance, food-safety thresholds, temperature tolerances, and shelf-life rules.
- Report schedules, retention periods, alert thresholds, and access assignments.

All production-required values need an owner, effective date, source, validation, and approval.

## 17. Working conventions for the next Codex session

- Stay aligned with approved design; do not casually reopen settled decisions.
- Use best judgment and proceed autonomously when standard practice supplies the answer.
- Keep chat responses brief and practical.
- Track resolved decisions and remaining work internally.
- Ask one focused question only when the answer materially changes the solution.
- When updating a deliverable, retain its exact filename so \<owner 1>'s downloaded copy replaces the prior one.
- Preserve unrelated files and user changes.
- Use `rg` for searching and `apply_patch` for file edits.
- Validate generated SQL, manifests, documentation, and tests before delivery.
- Keep user-facing deliverables downloadable and persistent.

## 18. Definition of project completion

PFD is not complete when the design or database alone is finished. Completion requires:

- Executable PostgreSQL changes through `0205`.
- Approved applications, reports, integrations, and operating documents.
- Reconciled and approved opening data.
- Passing security, recovery, performance, accounting, food-safety, and end-to-end tests.
- Passing deterministic one-day and one-week simulations.
- Trained users, approved procedures, cutover readiness, and owner authorization for grand opening.

## 19. Last known handoff point

The final six design documents were completed and saved:

- Quality, Food Safety, and Recall PostgreSQL Build Specification.
- Management Reporting and Audit Domain Specification.
- Management Reporting and Audit PostgreSQL Build Specification.
- Simulation Execution and Scenario-Control Specification.
- Opening Business Data and Grand-Opening Baseline Specification.
- Integrated Design Validation and Implementation Readiness Specification.

The next session should begin with the existing Core executable package and proceed to Party and Customer implementation.

## 20. Fixed application implementation baseline

Treat the following implementation decisions as fixed unless \<owner 1> explicitly changes them. Apply them to all future PFD application architecture, project structures, source code, and implementation documents.

### Development environment

- Visual Studio 2026 Community Edition.
- Microsoft Visual C++ compiler.
- C++23.
- 64-bit Windows target.
- Visual Studio `.slnx` solution.
- Native `.vcxproj` projects.
- MSBuild.
- Do not use CMake.
- Do not use vcpkg or another package manager.
- Do not use an ORM.

### Application model

PFD is a private, single-user application. \<owner 1> is the only interactive user.

- Build a Windows desktop application.
- Use MFC for the user interface.
- Do not create a distributed workstation deployment model.
- Do not create a Windows application service or API layer merely to isolate PostgreSQL.
- The desktop application may connect directly to PostgreSQL through the PFD database-access library.
- Do not create an installer or deployment package unless \<owner 1> requests one later.
- Never hardcode database passwords or connection strings in source code.

### PostgreSQL access

- PostgreSQL 15 or later is the authoritative database.
- Use PostgreSQL's official `libpq` client library directly.
- Include `libpq-fe.h`.
- Link against `libpq.lib`.
- Keep `libpq.dll` and its required runtime dependencies with the application.
- Keep approved PostgreSQL client files in a clearly versioned external-dependency directory.
- Configure PostgreSQL include paths, library paths, and linker settings through a shared Visual Studio `.props` file.
- Do not use `libpqxx`.
- Use explicit parameterized SQL, prepared statements, and controlled transactions.

Create a small PFD-owned C++ RAII layer around `libpq` for:

- Connections.
- Query results.
- Prepared and parameterized statement execution.
- Transactions.
- Commit and rollback.
- PostgreSQL error handling.
- Connection health checks.

Keep SQL, transaction boundaries, PostgreSQL errors, and affected-row results visible. Do not hide database behavior behind a large abstraction framework.

### Portability objective and project boundaries

The Windows user interface may be Windows-specific, but the remainder of the application should be portable C++ wherever practical. Target approximately 85–90 percent portable source code.

Use these project boundaries:

- `PfdDesktop` — Windows-only MFC executable.
- `PfdDomain` — portable business entities, rules, and transaction logic.
- `PfdDatabase` — portable C++ RAII wrapper around `libpq`.
- `PfdSimulation` — portable simulation engine.
- `PfdReporting` — portable reporting and calculation logic.
- `PfdPlatform` — small interfaces and implementations for operating-system-specific functions.
- `PfdTests` — tests for portable and Windows-specific components.

### Portability rules

- MFC, Windows handles, Windows messages, `CString`, registry access, and Windows-specific types must remain inside `PfdDesktop` or an explicit Windows implementation within `PfdPlatform`.
- Do not expose Windows or MFC types through portable project interfaces.
- Use standard C++ types in domain, database, reporting, and simulation interfaces.
- Use UTF-8 internally.
- Convert between UTF-8 and MFC or Windows text only at the Windows boundary.
- Use the C++ standard library for files, time, threading, containers, algorithms, and other general facilities.
- Isolate all direct `libpq` calls inside `PfdDatabase`.
- Put credential storage and unavoidable operating-system behavior behind narrow platform interfaces.
- Do not store ordinary configuration in the Windows Registry.
- Avoid MSVC-specific language extensions in portable projects.
- Keep portable source code independent of `.vcxproj` property settings.
- Continue using MSBuild and Visual Studio for the current Windows build.
- Do not add a second build system now. A non-Windows build definition may be added later without restructuring the portable source code.

### Python

The existing Python database-build runner may remain for schema builds, validation, and administrative tooling. Python is not part of the interactive production application and is not required on \<owner 1>'s Windows workstation merely to run `PfdDesktop`.

### Continuing PFD database rules

- Use normalized relational design.
- Use natural business primary keys.
- Do not introduce surrogate, identity, serial, sequence-only, or UUID substitute primary keys.
- Preserve database-enforced referential integrity and business constraints.
- Treat PostgreSQL as the authoritative system of record.
- Use effective-dated configuration where required.
- Make historical corrections through controlled reversals or adjustments.
- Use FEFO or approved shelf-life rotation for physical inventory.
- Use FIFO financial inventory valuation.
- Use parameterized SQL rather than constructed SQL text.
- Simulation must use the same ordinary business tables and transaction rules as real operation.
- Do not place simulation-run identifiers in ordinary business tables.

## 21. Public sample and private configuration decision

- The public repository contains a complete fictional sample-company baseline and no real personal or private business identity data.
- A private local baseline may contain approved real names, addresses, and operating data but remains outside the repository.
- Public and private baselines use identical formats, loaders, validation, relational structures, and business rules.
- Baseline selection is explicit; sample and private records are never silently combined.
- Business identity, facilities, owner roster, ownership percentages, and management assignments are opening data rather than schema constants.
- The active owner roster contains one or more Owners, and effective Ownership Interests total exactly 100 percent.
- Schema changes create `core.company` but do not supply a named Company row; the selected opening dataset supplies business identity.
- Credentials, generated reports, exports, logs, backups, and database dumps containing private data remain outside the public repository.
- The approved decision record is `docs/decisions/PFD_Public_Sample_and_Private_Configuration_Decision.md`.
- This was a design-only correction. Executable SQL, CSV, manifests, Python tools, Git configuration, and C++ artifacts were not aligned or created as part of this correction and remain future implementation work.

## 22. Local PostgreSQL development bootstrap

- PostgreSQL 16 is used for local development at `127.0.0.1:5432` with UTF-8 encoding.
- The local development database is `pfd_dev`.
- `pfd_application` is a `NOLOGIN` privilege role.
- `pfd_app` is the credential-bearing application login and inherits `pfd_application`.
- Local connections use `sslmode=prefer`.
- Private connection configuration belongs under `%LOCALAPPDATA%\PFD\config` and remains outside source control.
- PFD documentation and runtime configuration use PFD-specific locations and remain independent of unrelated product or organization directories.
- Creating the local database and roles does not authorize creation of PFD schemas, tables, reference data, or opening data.

## 23. Lightweight verification policy

- PFD is an exploratory simulation project rather than a production application.
- Prioritize application implementation over extensive test infrastructure or coverage targets.
- Add only small, high-value checks when a risky foundation or observed defect justifies them.
- Avoid elaborate mocks, repetitive unit tests, and large fixture systems unless a concrete need develops.
- By default, perform one focused Debug/x64 build and the directly relevant smoke check after a change.
- Do not routinely spend compute on the complete test suite, every build configuration, or broad regression runs.
- The user will perform routine builds, interactive testing, and additional verification as desired.
- Record exactly what automated verification was performed in the project log.
