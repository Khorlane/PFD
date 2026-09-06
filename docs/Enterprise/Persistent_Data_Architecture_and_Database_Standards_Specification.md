# Persistent Data Architecture and Database Standards Specification

**Document date:** September 4, 2026  
**Document status:** Authoritative persistence architecture and database-standards specification  
**Governing documents:**

- `Business_Model_and_Operating_Policies.md`
- `Business_to_IT_Capability_Specification.md`
- `Information_Model_and_Record_Ownership_Specification.md`
- `Business_Process_and_Transaction_Lifecycle_Specification.md`

---

## 1. Purpose

This document translates approved logical information model and transaction lifecycles into a relational persistence architecture based on PostgreSQL.

It establishes standards for:

- Relational modeling and normalization
- Database and schema organization
- Table, column, key, and constraint design
- Transaction integrity and concurrency
- Temporal, audit, and historical information
- Simulation-run isolation and reproducibility
- Operational-to-accounting consistency
- Indexing, partitioning, and performance
- Schema migrations and reference data
- Import, export, backup, archive, and recovery files
- Security, access, maintenance, and testing

This document establishes common database rules before detailed table definitions and implementation code are produced.

---

## 2. Superseding Architecture Decision

PostgreSQL is the selected persistent data platform for the simulation.

This decision supersedes the original design direction that specified:

- Binary master files as the primary business data store
- Separate master-file index files
- File-offset-based record lookup
- Rebuildable application-managed indexes
- A no-relational-database constraint

The business requirements behind those earlier decisions remain valid where applicable:

- Permanent unique business keys
- Efficient keyed and sequential access
- Persistent history
- Inactivation rather than destructive master deletion
- Index validation and recoverability
- Reproducible simulation

PostgreSQL now provides the physical mechanisms supporting those requirements through normalized tables, primary and foreign keys, unique constraints, indexes, transactions, logs, backups, and recovery facilities.

---

## 3. Architectural Goals

The persistent data architecture shall:

1. Represent the approved business model faithfully.
2. Use normalized relational structures as the operational default.
3. Protect referential and financial integrity in the database.
4. Preserve historical evidence and effective-dated facts.
5. Support continuous simulated business operation in the same production-shaped data model.
6. Make operational and accounting consequences traceable.
7. Permit safe restart without duplicate business effects.
8. Support the opening scale and substantial reasonable growth.
9. Avoid premature complexity and unnecessary denormalization.
10. Remain understandable to developers, database administrators, auditors, and business analysts.

---

## 4. PostgreSQL Platform Standard

### 4.1 Product selection

- PostgreSQL is the sole authoritative operational relational database.
- Implementation shall use a PostgreSQL major release that is supported at deployment time.
- PostgreSQL extensions shall be minimized and individually justified.
- Application correctness shall not depend on undocumented PostgreSQL behavior.

### 4.2 Deployment principle

The simulation one logical application database per environment:

- Development
- Automated test
- Integration/test
- Production or authoritative simulation environment

Environments shall not share schemas, roles, sequences, or mutable business data.

### 4.3 Character encoding and locale

- Database encoding: UTF-8
- Application text normalization: Unicode-aware
- Default business language: English
- Currency: United States dollar unless a future requirement explicitly adds another currency
- Business timezone: `America/New_York`
- Timestamps representing an instant: PostgreSQL `timestamptz`

---

## 5. Database Schema Organization

The business shall organize database objects into functional schemas.

| Schema | Primary responsibility |
|---|---|
| `core` | Company, facility, calendar, location, units, number control, shared reference data |
| `party` | People, contacts, addresses, common party relationships |
| `sales` | Customers, customer locations, contracts, pricing, orders, substitutions |
| `credit` | Credit profiles, limits, holds, reviews, collections, disputes |
| `product` | Products, categories, packs, storage rules, shelf-life rules, supplier products |
| `purchasing` | Suppliers, purchase recommendations, purchase orders, acknowledgements, commitments |
| `inventory` | Lots, pallets, balances, movements, allocations, counts, adjustments, dispositions |
| `warehouse` | Appointments, receipts, inspections, putaway, replenishment, picks, staging, loads |
| `transport` | Trucks, maintenance, route patterns, daily routes, stops, deliveries, POD |
| `quality` | Holds, sanitation, temperature, incidents, recalls, corrective actions |
| `finance` | AR, AP, cash, banking, debt, equity, fixed assets, general ledger, budgets |
| `hr` | Employees, positions, assignments, schedules, time, leave, qualifications, payroll |
| `service` | Customer-service cases, returns, inspections, dispositions, credit requests |
| `reporting` | Approved views, materialized views, report definitions, KPI results, snapshots |
| `audit` | Audit events, overrides, approval history, recovery events |
| `simulation` | Simulation sessions, business clock, random streams, event queue, and technical execution status |
| `staging` | Controlled temporary import data awaiting validation and promotion |

### 5.1 Schema boundaries

- Schemas organize ownership and names; they are not independent databases.
- Cross-schema foreign keys are expected where business relationships require them.
- A schema shall not copy another schema's authoritative master data merely for convenience.
- Reporting objects may combine schemas through views without becoming competing operational sources.
- `staging` data is never authoritative business data.

---

## 6. Relational Modeling and Normalization

### 6.1 Normal form standard

Operational tables shall be designed to at least Third Normal Form (3NF).

- First Normal Form: every column contains one atomic value for its defined business meaning; repeating groups are separate child tables.
- Second Normal Form: every non-key attribute depends on the complete key.
- Third Normal Form: non-key attributes depend on the key, the whole key, and nothing but the key.
- Boyce-Codd Normal Form should be used when it improves integrity without making the model impractical.

### 6.2 Normalization rules

- Customer locations are separate from customers.
- Contacts are separate repeatable records.
- Order lines are separate from order headers.
- Product packs and units are separate from products.
- Supplier-product relationships are separate from suppliers and products.
- Prices and costs are effective-dated relationship records.
- Inventory lot, location, status, and movement are separate concepts.
- Invoice and journal lines are separate from their headers.
- Many-to-many relationships use explicit junction tables.
- Status history is separate from current status when history is required.

### 6.3 Controlled denormalization

Denormalization is permitted only when all of the following are documented:

1. A measured query or processing need exists.
2. The authoritative normalized source is identified.
3. Refresh or transactional maintenance rules are defined.
4. Reconciliation is possible.
5. Failure cannot silently create authoritative conflicting facts.

Preferred denormalization mechanisms are:

- Views
- Materialized views
- Transactionally maintained balance tables
- Published report snapshots

Uncontrolled duplication of names, terms, statuses, prices, or balances across operational tables is prohibited.

### 6.4 Transaction snapshots are not improper denormalization

Completed transactions may preserve historical snapshots such as customer name/address, product description, applied price, terms, or document text. A snapshot explains the historical transaction and does not replace the current master record.

---

## 7. Table and Column Naming Standards

### 7.1 General naming

- Identifiers use lowercase `snake_case`.
- SQL identifiers shall not require double quoting.
- Names shall use business terms from the information model.
- Abbreviations are avoided unless established and unambiguous, such as `ar`, `ap`, `gl`, `sku`, or `kpi`.
- Reserved PostgreSQL or SQL words are not used as object names.

### 7.2 Object conventions

| Object | Convention | Example |
|---|---|---|
| Schema | Singular functional name | `inventory` |
| Table | Singular business noun | `sales.sales_order` |
| Primary key | Stable business key name | `customer_number`, `sales_order_number` |
| Foreign key | Referenced business-key name | `customer_number` |
| Composite line key | Header business key plus line number | `(sales_order_number, line_number)` |
| Status | `<entity>_status_code` or `status_code` when unambiguous | `order_status_code` |
| Effective dates | `effective_from`, `effective_through` | — |
| Business date | Specific meaning | `order_date`, `delivery_date` |
| Instant timestamp | Verb plus `_at` | `departed_at` |
| Boolean | Positive predicate | `is_active`, `requires_lot_control` |
| Check constraint | `ck_<table>_<purpose>` | `ck_order_line_quantity_positive` |
| Unique constraint | `uq_<table>_<columns/purpose>` | `uq_customer_customer_number` |
| Foreign key | `fk_<table>_<referenced_table>` | `fk_sales_order_customer` |
| Index | `ix_<table>_<purpose>` | `ix_sales_order_delivery_date` |
| View | `v_<business_name>` | `reporting.v_ar_aging` |
| Materialized view | `mv_<business_name>` | `reporting.mv_customer_profitability` |

### 7.3 Singular tables

Table names are singular because one row represents one instance of the named business record. Junction tables use both related singular nouns, such as `customer_product_preference`.

---

## 8. Keys and Business Numbers

### 8.1 Natural primary keys

- Durable entities and controlled transactions use stable, meaningful business keys as primary keys.
- Customer, Supplier, Product, Employee, Order, Purchase Order, Receipt, Invoice, Payment, Truck, Route, Journal, Payroll, and Asset numbers are their records' primary keys.
- A primary business number is permanent after issue, is never reused, and is not changed merely because descriptive attributes or status change.
- Display prefixes such as `C`, `SO`, `PO`, and `INV` are part of the governed business-number format when stored in the key.
- Cancellation may create a documented gap, but a number cannot be reassigned.

### 8.2 Composite primary keys

Dependent records without an independent business number use the smallest stable composite business key. Examples include:

- `(sales_order_number, line_number)`
- `(purchase_order_number, line_number)`
- `(invoice_number, line_number)`
- `(customer_number, customer_location_number)`
- `(supplier_number, product_number, purchasing_unit_code)`
- `(journal_number, line_number)`

Composite keys shall not include mutable descriptions, status, monetary amounts, quantities, or timestamps unless the timestamp is itself the governed event identity.

### 8.3 Foreign keys

- Foreign keys carry the referenced natural business key or complete composite key.
- PostgreSQL enforces all ordinary business relationships through foreign-key constraints.
- A child key uses the same data type, validation rule, and collation as the referenced key.
- Cascading primary-key updates are not used because issued business keys are immutable.

### 8.4 Technical keys

Surrogate keys are not used. Infrastructure records use stable technical natural or composite keys, such as `(scheduled_at, event_sequence)` and `(scheduled_at, event_sequence, attempt_number)`. A technical key never replaces an available business key and is never copied into operational records merely to partition simulation activity.

---

## 9. Data-Type Standards

| Business value | PostgreSQL type | Standard |
|---|---|---|
| Business key/number | `text` or exact integer type | Governed, permanent, validated, and never reused |
| Short code | `text` or constrained `varchar` | Length based on business rule, not habit |
| Description/name | `text` | Explicit validation where maximum matters |
| Quantity | `numeric(18,4)` | Always accompanied by unit |
| Money | `numeric(19,4)` | Never floating point |
| Percentage/rate | `numeric(12,8)` | Stored as decimal fraction unless explicitly named otherwise |
| Calendar date | `date` | No timezone |
| Time of day | `time` | Used only with a governing date/timezone rule |
| Actual instant | `timestamptz` | Stored/compared as an instant; presented in business timezone |
| Local planned timestamp | `timestamp` only when truly timezone-free | Avoid for actual events |
| Duration | `interval` or numeric unit | Meaning explicitly defined |
| Boolean | `boolean` | Nullable only when unknown is a real third state |
| Flexible external payload | `jsonb` | Not a substitute for relational columns |
| Document checksum | `bytea` or normalized text encoding | Algorithm recorded |

### 9.1 Prohibited data choices

- `real` and `double precision` for money, quantity billed, inventory, tax, or accounting values
- Generic string columns holding several unrelated meanings
- Comma-separated lists in a column
- Sentinel dates such as `9999-12-31` when `NULL` correctly means open-ended
- Boolean columns representing multi-state lifecycles
- JSON documents containing core relational facts merely to avoid table design

### 9.2 Money and rounding

- Stored transactional unit price and extended amounts use controlled decimal precision.
- Currency is explicit even while the business operates solely in USD.
- Rounding occurs at documented business boundaries, normally the transaction line and document total.
- Posted debits and credits balance exactly in stored currency units.

---

## 10. Nullability and Default Standards

- Required business facts are `NOT NULL`.
- `NULL` means unknown, not applicable, or not yet established according to the column definition.
- Blank text does not substitute for `NULL`.
- Zero does not mean unknown.
- Defaults are used only when the value is universally correct for newly created rows.
- Status, amount, quantity, user identity, and business dates shall not receive misleading convenience defaults.
- `created_at` may default to the transaction timestamp; business-effective time remains explicitly supplied when different.

---

## 11. Primary, Foreign, Unique, and Check Constraints

### 11.1 Database-enforced integrity

Rules expressible as stable row or relationship constraints shall be enforced by PostgreSQL, not solely by application code.

Every operational table shall have:

- Primary key
- Required `NOT NULL` constraints
- Foreign keys for authoritative relationships
- Unique constraints for business uniqueness
- Check constraints for stable domain rules

### 11.2 Foreign-key actions

The default action is `ON DELETE RESTRICT` or `NO ACTION`.

`ON DELETE CASCADE` is allowed only for truly dependent data whose independent existence has no business meaning, such as an unposted draft line removed with its draft header. It is prohibited for posted transactions, historical events, audit records, payments, inventory movements, and journal entries.

`ON DELETE SET NULL` is used sparingly when the relationship is genuinely optional and historical meaning remains clear.

### 11.3 Check-constraint examples

- Ordered quantity is greater than zero unless a documented correction table permits signed values.
- Accepted + rejected + held quantity reconciles to presented quantity.
- Effective-through date is not before effective-from date.
- Ownership interests total 100 percent within an approved effective period through controlled processing.
- Debit and credit on one journal line are not both positive.
- Inventory status code is an allowed value.
- Split-pack quantity does not exceed or equal a full case unless represented as full cases.

### 11.4 Multi-row rules

Rules spanning multiple rows or tables use a combination of:

- Transactional service logic
- Deferred constraint triggers where database enforcement is required
- Controlled stored procedures/functions for high-risk operations
- Reconciliation queries

Multi-row triggers shall be limited, documented, tested, and never used to hide major business workflow.

---

## 12. Reference Data and Status Codes

### 12.1 Reference tables

Reusable business classifications belong in normalized reference tables, including:

- Customer segment
- Product category
- Unit of measure
- Storage class
- Inventory status
- Order type and status
- Delivery exception type
- Return reason and disposition
- Credit-hold reason
- Supplier approval status
- GL account classification
- Employee and payroll classifications

### 12.2 PostgreSQL enum policy

PostgreSQL enum types shall not be the default for business statuses because business classifications evolve and require metadata, ordering, effective dates, and reporting descriptions. Lookup tables with foreign keys are preferred.

Database enums may be used only for small technical sets that are genuinely closed and stable.

### 12.3 Reference-data change control

- Codes are stable and not repurposed.
- Descriptions may change with history where material.
- Inactive codes remain resolvable by historical transactions.
- Seeded reference data is version-controlled and deployed through migrations.

---

## 13. Temporal and Historical Data

### 13.1 Timestamp columns

Mutable master and relationship tables normally include:

- `created_at`
- `created_by`
- `updated_at`
- `updated_by`
- A concurrency version where optimistic control is used

These fields supplement rather than replace the Audit Event.

### 13.2 Effective-dated relationships

Effective-dated tables use:

- `effective_from` — inclusive
- `effective_through` — exclusive or null for open-ended

The boundary convention is consistent across the database. Overlapping active periods for the same business relationship are prevented with unique/exclusion constraints or controlled transactional validation.

### 13.3 Status history

Entities with important lifecycles store:

- Current status on the master/transaction header for efficient control
- Append-only status-event rows for full history

### 13.4 Historical snapshots

Transaction document tables preserve the applied historical facts needed to reproduce:

- Customer invoice
- Purchase order
- Route manifest
- Payroll result
- Journal entry
- Formal financial or management report

---

## 14. Deletion, Inactivation, and Correction

### 14.1 Master data

- Referenced Customer, Supplier, Product, Employee, Truck, Account, and Fixed Asset rows are not physically deleted.
- They transition to inactive, suspended, discontinued, terminated, retired, or closed status.
- Unreferenced setup mistakes may be physically deleted only through controlled administrative procedures before business use.

### 14.2 Transactions

- Posted or completed transactions are never physically deleted through ordinary application functions.
- Draft transactions may be cancelled or deleted only when no downstream business effect exists and audit policy permits.
- Financial corrections use reversal or adjusting entries.
- Customer corrections use credit/debit/supplemental documents.
- Inventory corrections use Inventory Adjustment and movement history.

### 14.3 Database cascading

Cascade deletion is never used to erase a completed business chain.

---

## 15. Continuous Simulation Data Architecture

### 15.1 One continuing business state

The business' simulation operates one persistent business database in the same manner as a production application. A session may advance a day, a week, or another controlled interval, but the next session continues from the preceding period's ending inventory, cash, receivables, payables, orders, commitments, payroll, assets, debt, and general ledger.

Operational tables do not contain `simulation_run_id` or any other simulation partition key. Customers, Products, Suppliers, Employees, Trucks, Orders, Inventory, Deliveries, AR, AP, Payroll, and General Ledger records are the authoritative business records.

### 15.2 Simulation Session

`simulation.simulation_session` is a technical control record, not the owner of business data. It stores:

- Permanent session number
- Business-clock start and end
- Actual start, pause, completion, and failure timestamps
- Configuration version and random seed when applicable
- Responsible Principal
- Application and schema versions
- Status and diagnostic summary

Business transactions may record the creating Principal and ordinary business timestamp. They do not require a Simulation Session foreign key. Technical events and diagnostics may reference the Session Number when needed for restart or troubleshooting.

### 15.3 Business history and period comparison

- Completed activity remains in normal dated business and accounting tables.
- Daily and weekly comparison uses Order, Invoice, Delivery, Inventory Movement, Cash, Payroll, and Journal history.
- Monthly and annual comparison uses Accounting Period and published financial/reporting records.
- The close process, retention rules, corrections, reversals, and audit controls are identical to those expected in a real business system.
- Finishing a simulation session does not reset or archive the business state.

### 15.4 Randomness and reproducibility

- A session may use independent named random streams for orders, absence, supplier performance, payments, damage, breakdowns, and other stochastic events.
- Stream name, seed derivation, and draw sequence are deterministic when controlled reproduction is required.
- Material random draws may be retained in technical diagnostics.
- Routine continuing operation does not promise that an earlier week can be rerun inside the same authoritative database.
- A deliberate alternate or reproducibility test uses a separately restored database copy initialized from the selected backup or opening baseline.

### 15.5 Persistent event queue

The persistent event queue includes scheduled timestamp, deterministic equal-time sequence, event type, related business key, payload version or normalized detail, lifecycle status, attempt information, and failure information. Queue entries belong to the continuing environment; a Session Number may be recorded for technical traceability but does not scope the resulting business record.

### 15.6 Restart and test isolation

- Safe restart resumes incomplete technical work without duplicating completed business effects.
- Idempotency is based on stable business document numbers and source-event keys.
- Ordinary operation never deletes or resets the preceding period merely because a session ended.
- Alternate testing occurs only in an explicitly separate restored database copy.
- Test copies cannot post into or overwrite the authoritative continuing database.

---

## 16. Core Relational Domain Map

The following table identifies principal normalized tables. Detailed column definitions belong in subsequent schema specifications.

| Schema | Principal tables |
|---|---|
| `core` | `company`, `facility`, `warehouse_zone`, `warehouse_location`, `operating_calendar`, `calendar_exception`, `shift_definition`, `fulfillment_cycle`, `unit_of_measure`, `approval_authority`, `number_sequence` |
| `party` | `person`, `address`, `contact_method`, `party_address`, `party_contact` |
| `sales` | `customer`, `customer_location`, `customer_contact`, `customer_sales_assignment`, `customer_delivery_schedule`, `customer_preference`, `customer_contract`, `sales_order`, `sales_order_line`, `order_change`, `order_hold`, `backorder`, `substitution_decision` |
| `credit` | `credit_profile`, `credit_review`, `credit_hold`, `credit_exception`, `collection_case`, `collection_activity`, `promise_to_pay`, `customer_dispute`, `credit_loss_assessment` |
| `product` | `product`, `product_category`, `product_pack`, `storage_requirement`, `shelf_life_rule`, `product_substitute`, `supplier_product`, `supplier_cost`, `price_list`, `product_price`, `customer_price`, `contract_price`, `margin_rule`, `price_override` |
| `purchasing` | `supplier`, `supplier_location`, `supplier_contact`, `supplier_approval`, `supplier_terms`, `supplier_performance`, `supplier_claim`, `purchase_recommendation`, `purchase_recommendation_decision`, `purchase_order`, `purchase_order_line`, `supplier_acknowledgement`, `purchase_order_change`, `purchase_commitment` |
| `inventory` | `inventory_lot`, `pallet`, `inventory_balance`, `inventory_movement`, `inventory_status_event`, `inventory_allocation`, `pick_slot_placement`, `inventory_count`, `inventory_count_line`, `inventory_recount`, `inventory_adjustment`, `inventory_disposition`, `fifo_valuation_layer` |
| `warehouse` | `receiving_appointment`, `inbound_shipment`, `receipt`, `receipt_line`, `receipt_inspection`, `receiving_discrepancy`, `putaway_work`, `replenishment_work`, `warehouse_work_batch`, `warehouse_work_task`, `pick_work`, `pick_result`, `stage_assignment`, `load_plan`, `load_line`, `load_reconciliation` |
| `transport` | `truck`, `truck_compartment`, `vehicle_inspection`, `maintenance_plan`, `maintenance_event`, `route_pattern`, `daily_route`, `route_stop`, `dispatch_record`, `delivery`, `delivery_line`, `proof_of_delivery`, `delivery_exception`, `driver_return`, `route_cost` |
| `quality` | `quality_hold`, `temperature_observation`, `food_safety_responsibility`, `sanitation_task`, `sanitation_completion`, `pest_control_activity`, `food_safety_incident`, `corrective_action`, `product_recall`, `recall_exposure`, `recall_communication`, `recall_effectiveness_review` |
| `service` | `customer_service_case`, `case_activity`, `return_authorization`, `return_receipt`, `return_inspection`, `return_disposition`, `customer_credit_request`, `credit_approval`, `root_cause_assignment` |
| `finance` | `customer_invoice`, `customer_invoice_line`, `credit_memo`, `credit_memo_line`, `debit_memo`, `ar_open_item`, `customer_receipt`, `receipt_application`, `supplier_invoice`, `supplier_invoice_line`, `match_result`, `match_exception`, `supplier_dispute`, `ap_open_item`, `payment_proposal`, `supplier_payment`, `supplier_payment_application`, `supplier_remittance`, `gl_account`, `journal_entry`, `journal_line`, `posting_batch`, `accounting_period`, `reconciliation`, `bank_account`, `bank_transaction`, `cash_forecast`, `debt_instrument`, `debt_schedule`, `credit_line_draw`, `equity_account`, `owner_capital_transaction`, `fixed_asset`, `asset_component`, `depreciation_schedule`, `depreciation_entry`, `asset_transfer`, `asset_disposal`, `budget`, `budget_line`, `forecast` |
| `hr` | `employee`, `department`, `position`, `employee_assignment`, `compensation_rate`, `work_schedule`, `attendance_event`, `time_entry`, `leave_balance`, `qualification`, `employee_qualification`, `payroll_run`, `payroll_employee_result`, `payroll_payment`, `payroll_liability` |
| `reporting` | `report_definition`, `report_run`, `formal_report_snapshot`, `kpi_definition`, `kpi_result`, `management_action` |
| `audit` | `business_exception`, `hold`, `approval_request`, `approval_decision`, `override`, `audit_event`, `recovery_event` |
| `simulation` | `simulation_session`, `simulation_configuration`, `random_stream`, `random_draw`, `scheduled_event`, `event_attempt`, `session_checkpoint` |

---

## 17. Header-and-Line Transaction Standard

Documents with repeatable detail use normalized header and line tables.

Examples:

- Sales Order / Sales Order Line
- Purchase Order / Purchase Order Line
- Receipt / Receipt Line
- Load Plan / Load Line
- Delivery / Delivery Line
- Customer Invoice / Customer Invoice Line
- Supplier Invoice / Supplier Invoice Line
- Journal Entry / Journal Line

### 17.1 Header responsibilities

Header tables contain facts applying to the whole transaction:

- Business number
- Counterparty
- Location
- Dates and times
- Status
- Currency
- Terms
- Owner/custodian
- Totals and control status

### 17.2 Line responsibilities

Line tables contain:

- Stable line number within header
- Product/account/item
- Unit
- Quantity
- Unit price/cost
- Extended amount
- Line status
- Source and downstream relationship

### 17.3 Totals

- Authoritative totals are calculated from lines and charges.
- Stored totals are allowed for document immutability and performance only when maintained transactionally and reconciled.
- Header total and line/charge total differences are prohibited at finalization.

---

## 18. Inventory Persistence Model

### 18.1 Inventory ledger

`inventory.inventory_movement` is the authoritative history of quantity movement and status change. It is append-only after posting.

Each movement identifies:

- Business date and technical Session Number when needed for diagnostics
- Product and Unit
- Lot/Pallet where applicable
- Source and destination Facility/Location
- Source and destination status
- Quantity
- Actual timestamp and business date
- Source transaction type and ID
- Reason
- Responsible user/process

### 18.2 Current balance

`inventory.inventory_balance` is a transactionally maintained current-state table for efficient availability and location inquiries.

- Balance changes only in the same database transaction that posts the related Inventory Movement.
- Negative available inventory is prohibited unless a specifically approved business exception exists.
- A unique constraint prevents duplicate balance rows for the same run/product/unit/location/lot/status identity.
- Periodic reconciliation rebuilds expected balances from posted movements and compares them to stored current balances.

### 18.3 Allocation

Inventory Allocation is separate from physical movement.

- Allocation reserves eligible quantity for an Order Line.
- Allocation does not change physical location.
- Available-to-promise is derived from eligible on-hand minus active allocations and other commitments.
- Allocation release is explicit when an Order is cancelled, reduced, or fulfilled.

### 18.4 FEFO and FIFO

- Physical selection uses expiration date then pick-slot placement timestamp.
- Accounting valuation uses FIFO acquisition layers.
- FEFO and FIFO may select different conceptual ordering; both relationships remain explainable.
- Below-minimum-shelf-life, expired, recalled, held, quarantined, damaged, and returned statuses are excluded from normal allocation.

### 18.5 Lot-to-customer boundary

The business stores Inventory Lot through receiving, location, and placement history but does not store exact Lot on customer shipment lines. The relational model shall not imply precision the business does not operationally capture. Recall exposure uses product, time-window, movement, and remaining-balance analysis and is labeled estimated.

---

## 19. Financial Persistence Model

### 19.1 Double-entry structure

- `finance.journal_entry` stores the posting header.
- `finance.journal_line` stores debits and credits.
- Each posted entry is balanced.
- Each line references one GL Account and appropriate business dimensions.
- Operationally generated entries reference the source business transaction.

### 19.2 Posting control

Posting a business event and marking its accounting handoff complete occur in one controlled transaction or through an idempotent outbox/consumer pattern with visible pending status.

A source transaction cannot generate the same accounting event more than once. A unique source-event key protects this rule.

### 19.3 Subsidiary ledgers

AR, AP, inventory valuation, payroll liability, fixed asset, debt, and cash records are normalized subsidiaries. Each has a designated GL control account and period reconciliation.

### 19.4 Invoice timing

- Customer Invoice is created and printed before Truck departure.
- It remains `PENDING_DELIVERY` and unposted.
- Accepted Delivery finalizes quantities and creates AR, revenue, COGS, and inventory consequences.
- Refused or undelivered quantities are not recognized as revenue.
- Postdeparture differences use linked Credit/Debit/Supplemental records.

### 19.5 Accounting periods

- Period status is `OPEN`, `CLOSING`, or `CLOSED`.
- Ordinary posting to a closed period is blocked.
- Period reopening is privileged, documented, and approved.
- Posted rows retain both business transaction date and accounting date.

### 19.6 Balance verification

- Journal entries balance at posting.
- Trial balance verifies account-level debits and credits.
- Assets equal liabilities plus equity.
- Subsidiary-to-control-account reconciliations retain evidence and unresolved differences.

---

## 20. Transaction Boundaries and ACID Standards

### 20.1 Atomic business transactions

One database transaction shall contain all inseparable effects of a business action. Examples:

- Order release and initial allocation
- Accepted receipt, inventory movement, balance update, Lot creation, and PO received quantity
- Inventory move plus source/destination balance updates
- Delivery acceptance plus invoice finalization and accounting handoff marker
- Customer Receipt plus applications and accounting handoff
- Supplier Payment plus AP applications and accounting handoff
- Payroll approval plus immutable result set
- Journal posting plus period and balance validations

### 20.2 Consistency

A transaction commits only when all relevant keys, quantities, statuses, approvals, and constraints are valid.

### 20.3 Isolation

- `READ COMMITTED` is the normal isolation level for ordinary commands.
- Explicit row locking is used for contested inventory, sequence, payment, and status-transition rows.
- `REPEATABLE READ` or `SERIALIZABLE` is used for business operations whose correctness depends on a stable multi-row view, after testing retry behavior.
- Isolation choice is made per use case, not raised globally without cause.

### 20.4 Durability

Committed financial, inventory, delivery, payroll, approval, and audit transactions rely on normal PostgreSQL durability and shall not use unsafe durability settings.

---

## 21. Concurrency and Locking

### 21.1 Optimistic control

Mutable records subject to user editing should use a version number or compare-and-update rule so one user cannot silently overwrite another user's change.

### 21.2 Pessimistic control

Row-level locks are appropriate for:

- Inventory Allocation against the same eligible balance
- Inventory movement and adjustment
- Business number issuance
- Payment release
- Payroll finalization
- Accounting-period close
- Final lifecycle transitions

### 21.3 Deadlock behavior

- High-contention rows are locked in a consistent order.
- Transactions remain short and contain no user think-time.
- Deadlock and serialization failures are retried only when the command is idempotent and the retry policy is defined.
- Repeated conflicts are logged and investigated.

### 21.4 Advisory locks

PostgreSQL advisory locks may coordinate rare application-level activities such as one close per period or one active business-clock advancement process. They do not replace row constraints or transaction integrity.

---

## 22. Idempotency and Reliable Handoffs

### 22.1 Command identity

Externally retriable or scheduled commands carry an idempotency key unique within the continuing environment and command type.

Examples:

- Post accepted Delivery
- Apply Customer Receipt
- Release Supplier Payment
- Post Payroll Run
- Execute scheduled simulation event

### 22.2 Outbox standard

When a committed database change must trigger asynchronous downstream work, the business change and Outbox Event are committed together.

The outbox record contains:

- Event ID
- Simulation Session Number when technically applicable
- Event type and version
- Source aggregate/table and ID
- Business date and timestamp
- Payload or stable payload reference
- Publication status and attempts

### 22.3 Consumer standard

- Consumers record processed Event ID.
- Duplicate delivery is safe.
- A failed consumer does not cause the source business transaction to roll back after it has committed.
- Pending or failed handoffs remain reportable.

### 22.4 Database-notification boundary

PostgreSQL notification mechanisms may wake workers but are not the durable event store. Durable work resides in relational queue/outbox tables.

---

## 23. Audit Architecture

### 23.1 Audit scope

Audit history is required for:

- Master creation and controlled change
- Status transition
- Approval and rejection
- Override
- Price, cost, credit, compensation, bank, and remittance change
- Inventory adjustment and disposition
- Payment and payroll release
- Manual Journal Entry
- Period close/reopen
- Privileged access and recovery action

### 23.2 Audit-event structure

The Audit Event stores:

- Audit Event ID
- Environment and Simulation Session when technically applicable
- Schema/table and row identity
- Business action
- User or process identity
- Actual timestamp
- Business date/accounting period when applicable
- Prior and new value representation appropriate to sensitivity
- Reason and approval reference
- Correlation/command ID

### 23.3 Sensitive values

Audit records shall not expose secrets, passwords, full banking credentials, or other values whose capture creates unnecessary risk. Sensitive change evidence records that a protected value changed without reproducing it in clear text.

### 23.4 Audit integrity

- Business users cannot edit or delete Audit Events.
- Audit inserts occur within the business transaction when practical.
- Audit history has indexed lookup by record identity, user, time, action, and technical Simulation Session when recorded.

---

## 24. Indexing Standards

### 24.1 Required indexes

- Every primary key is indexed by its constraint.
- Every foreign-key column or leading foreign-key column set used for joins/deletes is explicitly reviewed and normally indexed.
- Natural business primary keys and alternate keys use their constraint-created indexes.
- Status and date indexes support active work queues and period processing.
- Business-period worklists normally use status, business date, due date, scheduled timestamp, or accounting period as leading index columns when query shape justifies it.

### 24.2 Index design

Indexes are based on actual query predicates, joins, sorting, and uniqueness. Do not create an index on every column.

Use as appropriate:

- Composite B-tree indexes for status/date and period worklists
- Partial indexes for active, open, pending, overdue, available, or failed subsets
- Covering `INCLUDE` columns for proven high-value queries
- GIN indexes for approved full-text or `jsonb` use
- BRIN indexes for very large naturally time-ordered event/history tables

### 24.3 Index examples

Likely access paths include:

- Active Orders by run, delivery date, status
- Available inventory by run, Product, Facility, status, expiration
- Pick-slot placements by run, location, Product, expiration, placement time
- Open PO Lines by Supplier/Product/expected date
- Receiving appointments by Facility/date/status
- Route Stops by run, route, sequence
- AR/AP open items by counterparty, due date, status
- Journal Entries by period/source/status
- Scheduled events by run, status, scheduled timestamp, sequence
- Exceptions by run, severity, status, responsible role

### 24.4 Index maintenance

- Duplicate and unused indexes are avoided.
- Query-plan evidence supports nonobvious indexes.
- Index growth, bloat, and write overhead are monitored.
- Concurrent production index creation is preferred when table availability matters and transaction semantics permit.

---

## 25. Partitioning and Growth

### 25.1 No premature partitioning

The business' opening scale does not require every transaction table to be partitioned. Normal indexed tables are the default.

### 25.2 Partition candidates

Time- or run-partitioning may later be appropriate for:

- Simulation scheduled events and event attempts
- Audit events
- Inventory movements
- Status/event history
- Journal Entries and Lines
- Report runs and large snapshots
- Completed simulation-run transactions

### 25.3 Partition standard

- Partitioning requires measured maintenance, retention, or query benefit.
- Primary/unique key design accounts for PostgreSQL partition constraints.
- Partitions use consistent constraints and indexes.
- Archive/detach operations are controlled and tested.
- Application queries include the partition key where practical.

---

## 26. Views, Materialized Views, and Reporting

### 26.1 Views

Views may provide stable business representations such as:

- Available inventory
- AR aging
- AP aging
- Order fulfillment status
- Purchase commitments
- Daily route status
- Accounting trial balance

Views do not conceal unclear ownership or replace integrity constraints on base tables.

### 26.2 Materialized views

Materialized views may support expensive management analytics such as customer profitability, product velocity, route contribution, and KPI trends.

- The authoritative normalized sources are documented.
- Refresh timing and staleness are visible.
- Refresh failure is reportable.
- Operational decisions requiring current facts do not rely on stale materialized data.

### 26.3 Formal report snapshots

Published monthly financial statements, budgets, and selected management reports may be retained as immutable relational metadata plus controlled rendered output. The snapshot records its definition version, parameters, as-of time, source period, and checksum.

---

## 27. Stored Procedures, Functions, and Triggers

### 27.1 Appropriate database logic

Database functions/procedures may implement high-integrity operations that benefit from one authoritative transactional boundary, including:

- Business number allocation
- Inventory movement posting
- Journal Entry posting
- Period close control
- Payment release control
- Run/event claim and completion

### 27.2 Trigger policy

Triggers are appropriate for narrowly defined integrity or audit behavior. They shall not create invisible, sprawling business workflows.

Every trigger shall have:

- Documented purpose
- Defined ordering assumptions
- Unit and integration tests
- Error behavior
- Performance review

### 27.3 Calculation ownership

One calculation rule has one authoritative implementation. Gross margin, available inventory, invoice totals, and journal balance shall not have inconsistent formulas in multiple application and database locations.

---

## 28. Schema Migration Standards

### 28.1 Migration source

- All database definition changes are source-controlled.
- Migrations are ordered, immutable after shared use, and uniquely identified.
- A schema-version table records applied migration, checksum, start/end time, and result.
- Manual production schema changes are prohibited except documented emergency repair followed immediately by a matching migration.

### 28.2 Migration contents

Migrations may contain:

- Schema and table creation
- Columns and constraints
- Indexes
- Views/functions/triggers
- Reference-data changes
- Controlled data transformations

### 28.3 Deployment safety

- Migrations are tested against a representative database copy.
- Destructive or table-rewriting changes require explicit planning.
- Large changes use expand/migrate/contract when needed.
- Application and schema compatibility is defined during rolling change.
- Each migration has backup/recovery and failure instructions.

### 28.4 Rollback

Forward corrective migrations are preferred after a migration has been shared or applied to authoritative data. Down migrations are allowed only when they can safely preserve all data and dependent code assumptions.

---

## 29. Seed, Reference, and Opening-State Data

### 29.1 Data classes

| Class | Examples | Deployment method |
|---|---|---|
| Technical reference | Status codes, event types, storage classes | Versioned migration/seed |
| Business policy reference | Customer segments, reason codes, approval classes | Versioned controlled seed |
| Opening master data | 80 Customers, 3,000 Products, 60 Suppliers, Employees, Trucks | Validated opening data load |
| Opening financial state | Cash, debt, equity, assets, beginning inventory | Balanced opening-state load |
| Test fixtures | Small artificial records | Test-only setup |

### 29.2 Seed rules

- Seed operations are idempotent.
- Stable codes are matched by natural code, not assumed identity value.
- Production/opening data is validated through the same business constraints as entered data.
- Test fixtures never deploy to authoritative environments.
- Opening financial data must balance before continuing business operation begins.

---

## 30. Import and Export File Standards

PostgreSQL is authoritative, but controlled files remain necessary for migration, exchange, reports, backup, and recovery.

### 30.1 Tabular exchange

CSV is the default tabular interchange format.

- Encoding: UTF-8
- First row: column names
- Column names: lowercase `snake_case`
- Delimiter: comma unless a documented external requirement specifies otherwise
- Quoting: standards-compliant quoting for delimiter, quote, and newline
- Decimal separator: period
- Dates: ISO `YYYY-MM-DD`
- Timestamps: ISO 8601 with timezone/offset
- Booleans: `true` and `false`
- Null: empty unquoted field only when the interface specification defines it as null
- Money: decimal number without currency symbol; currency column included
- Quantity: numeric plus unit column

### 30.2 Structured exchange

JSON may be used for versioned hierarchical interfaces and event payloads.

- Encoding: UTF-8
- Schema/version identifier required
- Stable property names
- ISO dates/timestamps
- Decimal money represented without binary floating-point loss
- Core authoritative fields remain relational after import

### 30.3 File manifest

Material imports/exports use a manifest containing:

- Interface name and version
- File name
- Creation timestamp
- Source and intended destination
- Record count
- Control totals where applicable
- Checksum and algorithm
- Business period or technical Simulation Session when applicable
- Character encoding and delimiter for tabular data

### 30.4 Import process

```text
Receive file
  -> Verify manifest/checksum
  -> Load to staging schema
  -> Validate structure and business rules
  -> Produce reject/error report
  -> Approve valid batch
  -> Promote in one controlled transaction
  -> Reconcile counts and totals
  -> Archive source, result, and evidence
```

### 30.5 Import safety

- Files never load directly into authoritative tables.
- Each import batch has a unique identity and idempotency control.
- Invalid rows remain in staging/reject evidence and do not partially corrupt authoritative data.
- Sensitive exports are access-controlled and retained only as long as needed.

---

## 31. Document and Binary Object Standard

The relational database stores metadata and business relationships for documents such as Proof of Delivery images, supplier documents, formal report output, or supporting evidence.

Large binary content should normally reside in controlled object/file storage rather than ordinary operational table rows. The database retains:

- Document ID
- Business record relationship
- Document type and version
- Original name and media type
- Storage reference
- Byte size
- Checksum and algorithm
- Created/received timestamp
- Retention class
- Access classification

Small content may use PostgreSQL binary storage only when justified. File paths alone are not trusted as identity; checksum and controlled storage reference are required.

---

## 32. Backup and Recovery Standards

### 32.1 Recovery objectives

- Target recovery time for critical operations: four hours
- Target recent-data loss: fifteen minutes or less where practical
- Manual business-continuity procedures cover longer interruptions

### 32.2 Backup layers

The business shall maintain:

- Physical/base backups suitable for full recovery
- Write-ahead-log retention suitable for point-in-time recovery
- Logical backups for portability and object-level recovery where appropriate
- Separate preservation of migration source and configuration
- Controlled backup of externally stored documents referenced by the database

### 32.3 Backup rules

- Backups are encrypted and access-controlled.
- At least one protected copy is isolated from the primary database host.
- Backup success is monitored.
- Retention follows approved operational and financial requirements.
- Backup files are not considered valid solely because creation completed.

### 32.4 Restore testing

Restore tests shall verify:

- Database starts and accepts connections
- Required schemas and versions exist
- Referential constraints are valid
- Inventory, AR, AP, cash, payroll, and GL reconcile
- Simulation Sessions retain correct clock, seed, and event status
- External documents remain resolvable
- Application-level smoke tests pass

### 32.5 Recovery points

Named checkpoints are created before material schema migrations, bulk data loads, period-close changes, and other high-risk operations when appropriate.

---

## 33. Archival and Retention

### 33.1 Retention classes

Database records follow the retention classes established by the Information Model:

- Permanent company, ownership, key, GL, and major asset/debt history
- Seven-year financial and control records
- Food-safety records for seven years or longer requirement
- Employment plus seven years or longer requirement
- Routine operational history for at least three years

### 33.2 Archival principles

- Archiving preserves referential meaning and business keys.
- Archived business history remains identifiable by business date, accounting period, software/schema version, and technical session where applicable.
- Archival does not leave current tables with broken foreign keys.
- A legal, tax, audit, insurance, recall, or management hold suspends destruction.
- Destruction requires authorization and an auditable record.

### 33.3 Period and technical-session archival

Business records are archived according to their normal business and accounting retention classes, preserving relationships across periods. Technical Simulation Session logs, event attempts, random-stream diagnostics, software/schema versions, checksums, and archive manifests may be archived separately after they are no longer needed for restart or investigation. Ending a session never causes the associated business records to be archived as a separate data set.

---

## 34. Database Security and Roles

### 34.1 Role separation

Separate PostgreSQL roles shall exist for:

- Database ownership/administration
- Schema migration
- Application runtime
- Read-only operations/support
- Reporting/analytics
- Backup and recovery
- Monitoring

The application runtime role is not a superuser and does not own database objects.

### 34.2 Privilege standards

- Privileges are granted to group roles rather than individuals where practical.
- Default privileges are explicitly controlled.
- Public schema creation and broad `PUBLIC` privileges are removed unless justified.
- Application access is limited to required schemas and operations.
- Direct production table modification by ordinary users is prohibited.

### 34.3 Application authorization

Business authorization remains application-aware because PostgreSQL roles alone do not express all approvals, thresholds, and workflow states. Database privileges and business-role authorization work together.

### 34.4 Row-level security

Row-level security is not required for a single-company opening model. It may be introduced only if a future multi-tenant or strong row-segregation requirement exists. Test copies are isolated at the database/environment level rather than by row-level Simulation Session keys.

### 34.5 Connections and secrets

- Network connections use encryption.
- Credentials are stored outside source code and database scripts.
- Separate environments use separate credentials.
- Credentials and certificates rotate according to policy.
- Connection attempts and privileged actions are monitored.

---

## 35. Privacy and Sensitive Data

- Employee personal and payroll data is isolated in the `hr` domain and restricted.
- Bank-account and remittance details are restricted to authorized Finance processes.
- Credit references and customer risk notes are not exposed in general Sales queries.
- Reports select only required fields.
- Nonproduction datasets use fabricated or appropriately de-identified sensitive data.
- Audit records prove sensitive changes without unnecessarily reproducing protected values.

---

## 36. Database Maintenance and Observability

### 36.1 Routine maintenance

- PostgreSQL autovacuum remains enabled and is tuned from observed workload.
- Table and index statistics are kept current.
- Long-running transactions are monitored and corrected.
- Table and index growth, dead tuples, bloat, and disk capacity are reviewed.
- Reindexing or vacuum changes are evidence-based.

### 36.2 Operational monitoring

Monitor at minimum:

- Availability and connection usage
- Transaction failure rate
- Lock waits and deadlocks
- Long-running and slow queries
- Replication/WAL/archive health if configured
- Backup and restore-test status
- Disk and table growth
- Autovacuum progress/problems
- Failed migrations
- Failed/pending outbox and scheduled events
- Data-integrity and reconciliation exceptions

### 36.3 Query diagnostics

Execution plans are captured and reviewed for important slow queries. Indexes and queries are changed based on evidence, not intuition alone.

---

## 37. Connection and Workload Management

- Applications use bounded connection pools.
- Transactions begin only when required work is ready and end promptly.
- User interaction does not hold an open database transaction.
- Batch operations use controlled chunking when one massive transaction would create excessive locks or recovery pressure.
- Reporting workloads shall not jeopardize warehouse, dispatch, receiving, payment, payroll, or simulation-event processing.
- Read replicas may be considered later for heavy reporting, but they are not required at opening scale.

---

## 38. Development and Test Standards

### 38.1 Database tests

Automated tests shall cover:

- Primary, foreign, unique, and check constraints
- Effective-date overlap prevention
- Status transitions
- Inventory movement and balance agreement
- Allocation concurrency
- Receipt reconciliation
- Invoice pending-to-posted transition
- Three-way match and disputed amount handling
- AR/AP application
- Balanced Journal Entry posting
- Closed-period blocking
- Payroll finalization
- Idempotent event and command replay
- Simulation-run isolation
- Migration from every supported prior schema version

### 38.2 Test datasets

Maintain:

- Minimal deterministic fixture set
- Opening baseline test
- High-volume performance test
- Exception-heavy operating test
- Recovery/replay test
- Financial reconciliation test

### 38.3 Production data

Production or personally sensitive data shall not be copied into development environments without approved de-identification and control.

---

## 39. Database Documentation Standards

Each table shall eventually document:

- Business purpose and owner
- Primary and alternate keys
- Business key and, for technical records only, optional Simulation Session relationship
- Columns and business meaning
- Nullability and defaults
- Foreign-key relationships
- Unique and check constraints
- Lifecycle/status behavior
- Audit and retention class
- Expected volume and access patterns
- Index rationale
- Source capability/process requirements

Important columns and database objects should also use PostgreSQL comments so meaning is available with the schema.

---

## 40. Database Design Review Checklist

A new table or material change is approved only when:

1. Its business record and owner are identified.
2. The design is normalized to at least 3NF or an exception is documented.
3. Primary, foreign, unique, and check constraints are defined.
4. Natural primary-key scope and any technical Simulation Session relationship are correct.
5. Data types and units are appropriate.
6. Effective dating and history needs are addressed.
7. Delete/inactivation/correction behavior is defined.
8. Audit and retention requirements are assigned.
9. Transaction boundaries and concurrency are understood.
10. Accounting and reconciliation effects are defined where applicable.
11. Indexes support known access paths without unnecessary duplication.
12. Migration, rollback/correction, backup, and restore impacts are understood.
13. Sensitive data access is restricted.
14. Automated tests prove integrity and test-environment isolation.

---

## 41. Architecture Decisions Locked by This Specification

1. PostgreSQL is the authoritative persistent data platform.
2. Operational design targets at least Third Normal Form.
3. Controlled denormalization requires evidence, ownership, and reconciliation.
4. One continuing logical business database is used per environment; alternate tests use separate restored database copies.
5. Functional PostgreSQL schemas organize domains.
6. Lowercase `snake_case` and singular table names are standard.
7. Durable business records use stable natural business keys as primary keys.
8. Header/detail records without separate document numbers use governed composite primary keys.
9. Foreign keys and stable business constraints are database-enforced.
10. Master records are inactivated rather than deleted after use.
11. Completed transactions are corrected through linked transactions, not overwritten.
12. Actual instants use `timestamptz`; business timezone is America/New_York.
13. Money and quantity use exact numeric types.
14. Business statuses normally use reference tables rather than PostgreSQL enums.
15. Operational records are continuous across simulation sessions and contain no Simulation Session partition key.
16. Simulation Session is technical execution metadata and does not own business records.
17. Controlled reproducibility uses a separately restored database copy plus recorded configuration and random streams.
18. Inventory Movement is authoritative history; Inventory Balance is maintained transactionally and reconciled.
19. Physical selection uses FEFO; financial valuation uses FIFO.
20. Exact customer-to-Lot shipment linkage is intentionally not stored.
21. Customer Invoice is printed before departure and posted after accepted delivery.
22. Journal Entries use normalized balanced header-and-line structures.
23. High-risk handoffs are idempotent and recoverable.
24. Durable asynchronous handoffs use relational outbox/queue records.
25. Partitioning is introduced only when measured need exists.
26. Migrations and reference data are source-controlled.
27. Imports pass through staging and reconciliation.
28. Backups support point-in-time recovery and are restore-tested.
29. Application runtime roles do not own database objects or receive superuser access.
30. The original binary master/index-file persistence direction is superseded.

---

## 42. Recommended Next Deliverable

The next deliverable should be the **Relational Schema and Table Definition Specification**.

It should define, table by table:

- Columns and PostgreSQL data types
- Primary and alternate keys
- Foreign keys and cardinality
- Required and optional values
- Check and unique constraints
- Effective-date and audit columns
- Natural key definitions and technical-session relationships where applicable
- Status and lifecycle relationships
- Expected indexes
- Retention and volume assumptions

That deliverable should begin with the shared `core`, `party`, `simulation`, `sales`, `product`, and `inventory` foundations before moving to transactions and finance.

---

## 43. Completion Status

This document establishes the persistent relational architecture and PostgreSQL database standards as of September 4, 2026.

It is the authoritative input for detailed relational schema design, migration design, repository structure, database access architecture, implementation planning, and database testing.
