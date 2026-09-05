# \<business name>
# Opening Business Data and Grand-Opening Baseline Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Opening-data and baseline design; executable load files not included  
**Depends on:** PFD design through the Simulation Execution and Scenario-Control Specification

## 1. Purpose

Define the business data, control totals, relationships, approvals, and validation required to create PFD's authoritative Grand-Opening Baseline for implementation, testing, and repeatable simulation.

## 2. Baseline Principle

The baseline represents a properly organized operating startup, not an empty shell. PFD begins with owners, capital, facility, equipment, systems, trained Employees, approved Customers/Suppliers/Products, initial Inventory, banking/credit arrangements, and operating policies ready.

The baseline contains ordinary business master, effective, reference, opening-balance, and asset records. It does not create special simulation versions of those records.

### 2.1 Public sample and private local baselines

The public repository contains a complete fictional sample-company baseline. Its business, facility, owner, Employee, Customer, Supplier, and financial identities are invented and contain no private operating data. A private local baseline may contain approved real information but remains outside the public repository.

Public and private baselines use the same versioned formats, loader, validation rules, relational structures, and approval controls. Baseline selection is explicit, and loading never silently combines sample and private records. Credentials, connection details, generated reports, exports, logs, backups, and dumps are outside opening business data and are never included merely because a baseline is selected.

## 3. Baseline Time

The exact Grand-Opening date is configurable. The approved baseline timestamp is **12:00 PM America/New_York on the Sunday immediately preceding the first Monday office/order cycle**.

The baseline is taken before the first production warehouse event of that operating week. Scenarios may create opening demand after startup. Any deliberately preloaded open Order, appointment, or other transaction must be separately identified in the Baseline manifest and reconcile as ordinary history.

## 4. Opening Scale

| Measure | Approved baseline |
|---|---:|
| Customer locations | 80 |
| Active Products/SKUs | Approximately 3,000 |
| Approved Suppliers | Approximately 60 |
| Regularly used Suppliers | Approximately 40 |
| Delivery trucks | 6 |
| Trucks normally dispatched | 5 |
| Spare trucks | 1 |
| Facility area | Approximately 50,000 square feet |
| Warehouse/operating area | Approximately 45,000 square feet |
| Office/employee area | Approximately 5,000 square feet |
| Employees including owners | Approximately 45–50 |
| Expected weekday Delivery stops after ramp-up | Approximately 40–45 |

Exact roster/SKU/Supplier counts may vary modestly when the approved opening data is assembled, but the manifest explains every variance from these planning totals.

## 5. Company Identity

The selected opening dataset supplies Company records establishing:

- Legal/trade name: \<business name>
- Abbreviation: PFD
- Principal facility: \<business address>
- Timezone: America/New_York
- Reporting currency: U.S. dollar
- Calendar fiscal year and monthly accounting periods
- Regional broadline food-service distribution business purpose

Legal entity, tax registrations, licenses, insurance, bank, lender, and regulator identifiers are protected configuration populated from verified real or controlled test evidence.

## 6. Ownership and Governance

The selected opening dataset supplies one or more Owners and their effective Ownership Interests. Owner identity, owner count, percentage, and management responsibility are configurable data rather than structural constants.

Opening Ownership Interests total exactly 100 percent and are effective at baseline time. Each Owner is linked to one Person/Party and, when paid for operational work, one Employee/owner role. Management responsibility is separately assigned and does not arise from ownership percentage. Owner capital, compensation, loans, and distributions remain distinct.

Reserved-matter approval thresholds are effective-dated governance configuration. They must remain valid for the active owner roster, require meaningful independent approval, and prevent an affected owner from approving that owner's own related-party matter alone.

## 7. Service Territory

The opening territory uses the Charlotte facility as the hub with practical direct corridors toward:

- Statesville, North Carolina
- Monroe, North Carolina
- Rock Hill, South Carolina
- Gastonia, North Carolina

Service-area records include approved communities/ZIP/geographic definitions, route zones, distance/time assumptions, jurisdiction, and effective dates. They support eligibility and planning without promising service to every point inside a broad polygon.

## 8. Customer Portfolio

| Segment | Opening locations | Normal frequency |
|---|---:|---|
| Restaurants | 48 | Three Deliveries per week |
| Hotels | 10 | Two per week |
| Schools | 10 | One or two per week |
| Hospitals/healthcare | 6 | Three per week |
| Correctional institutions | 6 | Two per week |
| **Total** | **80** | Approximately 40–45 weekday stops |

Each location has a Customer Number/Location Number, legal/billing/delivery information, receiving hours/windows, contacts, tax/exemption evidence, assigned Sales representative, order authority, substitution/preferences, route/service zone, minimum-order/fee treatment, credit account, terms, limit, and status.

Opening standard terms are Net 30. Approved governmental, school, healthcare, or contract Customers may use Net 45. Higher-risk test Customers may use prepaid/COD/restricted terms when a Scenario requires them.

## 9. Customer Data Distribution

The opening portfolio must support realistic variation in order size, Product mix, delivery frequency/window, payment behavior, service cost, margin, storage restrictions, substitutions, contract pricing, and seasonality.

No Customer is generated solely as an untraceable random row. Each has a stable business number and documented profile source/version. Synthetic names/addresses used for simulation are clearly non-real and geographically valid enough for route planning.

## 10. Products and Assortment

Approximately 3,000 active Products span:

- Canned/shelf-stable and dry grocery
- Frozen food
- Refrigerated dairy, eggs, and cheese
- Fresh produce
- Fresh/refrigerated meat and deli Products
- Paper and disposable food-service supplies
- Related nonfood consumables

Each Product has Product Number/SKU, description, category, brand/manufacturer reference, standard purchase/sell units, case/pack configuration, fixed-price basis, storage class, dimensions/weight where known, shelf-life/date requirements, minimum remaining shelf life, quality/traceability profile, approved Suppliers, cost/price basis, and active status.

PFD performs no catch-weight pricing. Split packs are permitted only where operationally approved and normally use the 15 percent per-unit handling premium.

## 11. Product Quality and Traceability Classification

Opening Product Safety Profiles classify temperature, allergen/segregation, raw/ready-to-eat, lot/date capture, shelf life, risk, and traceability.

Food Traceability List applicability and exemption determinations are reviewed and versioned. Products requiring regulated, contractual, or risk-based exact outbound Lot tracking are flagged before Inventory loading. Other Products use exposure-window traceability.

## 12. Suppliers

Approximately 60 Suppliers are approved and approximately 40 are expected to be used regularly. Records include Supplier/locations/contacts, ordering and appointment rules, Products/packs/costs, lead times, minimums, freight terms, payment terms, fill/on-time/quality profiles, alternate-source role, documents, recall contacts, quality approval, and status.

Supplier banking instructions are not ordinary master fields; Finance stores verified protected payment evidence. Approved and active-to-purchase states remain distinct.

## 13. Purchasing and Receiving Setup

Opening data includes buyers, approval authority, replenishment/forecast parameters, Purchase Order rules, Supplier calendars, lead-time profiles, receiving docks/appointment capacity, inspection/control plans, tolerances, and three-way-match policy.

No Supplier may arrive without an appointment or documented exception. Initial Inventory acquisition history is represented by controlled opening transactions or a specifically approved opening-balance procedure that preserves Supplier, Receipt, Lot, cost, and Finance evidence.

## 14. Facility and Warehouse

The approximately 50,000-square-foot facility includes about 45,000 square feet for warehouse/operations and 5,000 for office/employee use.

Opening data defines facility, zones, aisles, racks, reserve/pick/staging/quarantine/return/damage/receiving/loading locations, temperature/storage class, capacity, compatibility, access, and active status.

Location numbering is permanent and meaningful enough for operations without encoding changeable Product assignments.

## 15. Pick Slots and Replenishment

Active Products have appropriate reserve/pick-slot configuration, minimum/replenishment quantities, case/split capability, capacity, and storage compatibility. Fast movers may use a full pallet as the active pick location.

Each initial Lot/pallet placed in a pick slot receives an actual baseline placement timestamp. Multiple Lots may share a slot only when capacity/compatibility allows; FEFO and one-Lot-before-next procedure remain active.

## 16. Initial Inventory

Initial Inventory is sufficient to support committed opening demand and approved service levels without implying unlimited supply. It includes realistic quantities across storage classes, movement/velocity tiers, Suppliers, Lots, costs, and dates.

Every balance reconciles to an Inventory Lot, location, status, unit, Receipt/opening-acquisition source, and FIFO valuation layer. Lot/date codes are present when supplied. Exact-traceability Products include required data elements.

No baseline Inventory is negative, expired, in an incompatible location, unsupported by valuation, or available while on Hold. A controlled small amount of short-dated/damaged/held stock may exist only when explicitly included to test normal exception handling.

## 17. Inventory Valuation

Opening Inventory financial cost uses FIFO layers tied to acquisition evidence and landed-cost policy. Physical rotation uses FEFO. Total quantity by Product/Lot/location reconciles to valuation quantity and Inventory GL control.

Opening reserve for shrink, obsolescence, or short-date risk is separately approved; it does not alter physical quantity.

## 18. Fleet

Six owned delivery trucks are active assets, generally configured for PFD storage/route needs. Five are normally planned for dispatch and one for spare coverage.

Each truck has permanent Truck Number, vehicle identification/registration evidence, capacity, compartments/temperature capability, equipment, status, acquisition/financing Asset references, insurance, inspection/maintenance schedules, odometer/fuel baseline, and qualification requirements.

Specific makes, models, costs, loans, and capacities are verified opening configuration.

## 19. Routes and Delivery Setup

Opening route zones/templates, Customer stop/service data, delivery windows, travel/service-time assumptions, truck compatibility, driver requirements, load capacities, and dispatch calendars support the hub-and-spoke territory.

Templates are planning aids. Actual Routes/Stops/Loads receive ordinary business numbers and arise from actual released Orders.

## 20. Workforce

The baseline includes approximately 45–50 trained Employees, including any owners who also hold Employee roles. It covers Sales, Customer Service, Purchasing/planning, Warehouse supervision and labor, Receiving/putaway, replenishment/picking/staging/loading, Transportation/dispatch/drivers, Finance/AR/AP/Payroll, HR/administration, sanitation/facility, and IT support.

Each Employee has Person/Employee Number, employment period, Department, Job, Position, primary Assignment, supervisor, work location, schedule/pay classification, Compensation Agreement, Payroll/tax/payment setup, leave/benefit eligibility, training/qualifications, and access/property tasks as appropriate.

No Employee is active for work lacking required onboarding, qualification, or authority.

## 21. Work Schedules and Payroll

Opening schedule templates reflect office Monday–Friday 8:00 AM–5:00 PM, Sunday warehouse startup, evening/night fulfillment, early Delivery, and Saturday closure.

PFD uses one biweekly Payroll Calendar for hourly, salaried, and owner-employees. Opening Payroll Periods, cutoffs, pay dates, Pay Rules, Earning Codes, deduction/tax/benefit configuration, and approval roles are complete. No historical Payroll Results are loaded unless specifically required by the chosen first pay-period date.

## 22. Banking, Cash, and Credit Facility

Opening unrestricted cash is sufficient for timely operating expenses, Supplier obligations, Payroll/taxes, and worthwhile discounts while maintaining approximately one month of normal operating cash requirements.

PFD also has an unused revolving line target of approximately one additional month of normal operating cash needs. Exact Bank Accounts, balances, line limit, rates, lender, covenants, and protected identifiers are approved Finance configuration.

Bank statement opening balance, GL Cash, and Bank Account book balance reconcile exactly.

## 23. Owner Capital, Assets, and Debt

Opening owner contributions fund the business according to approved capitalization; contribution amounts and Ownership Interest percentages remain distinct and reconcile to the selected baseline's approved equity structure. The facility and six trucks are owned assets with financing. Warehouse, office, computer, and other equipment are recorded as Assets or expense according to adopted policy.

Each Asset reconciles acquisition cost, placed-in-service date, location/custodian, useful life, depreciation schedule, and financing link. Debt schedules reconcile principal to GL and lender evidence.

## 24. Chart of Accounts and Financial Opening

The opening Chart of Accounts, hierarchies, control-account rules, dimensions, posting rules, periods, bank mappings, tax registrations, asset classes, budget, cash forecast, and close calendar are approved.

The opening Trial Balance balances: Assets = Liabilities + Equity. Inventory, Cash, Fixed Assets, Debt, Owner Equity, and any approved opening obligations reconcile to subsidiaries.

PFD has no inherited Customer receivables or Supplier payables unless expressly listed. Opening AR and AP control balances are therefore normally zero.

## 25. Budget and Operating Plan

The approved opening annual Operating Budget and Capital Plan include Sales/margin, Inventory purchases, labor, facility/fleet, operating expenses, cash, debt service, taxes, and capital assumptions. The effective governance policy determines the required owner approvals.

Monthly targets support management reporting but do not create actual results.

## 26. Quality and Recall Readiness

Opening Standards, Control Plans, Product/Supplier profiles, measuring equipment/calibration, sanitation/pest plans, quarantine/Hold locations, Traceability Plan, Recall Plan, Customer/Supplier/regulator contacts, notice templates, mock-recall calendar, and Food Safety Leader/backup are active.

The baseline passes a traceability/readiness test before approval.

## 27. Reporting, Audit, and Security

Opening Report/KPI definitions, Owner scorecard, alert/action rules, reconciliation/data-quality rules, recipients, retention, and report privileges are effective.

Each Principal has unique identity and least-privilege roles based on Assignment. Segregation covers credit, AP/payment, Payroll/payment, Journal approval, bank reconciliation, owner compensation, Quality release, and audit administration.

The initial privileged-access grant and Baseline creation are fully audited.

## 28. Reference and Configuration Data

Every reference/configuration group has code, meaning, owner, effective date, active status, display/order where relevant, and approval. Codes are stable and never repurposed.

Configuration includes business calendars, units/currencies, statuses/reasons, numbering, tolerances, approvals, storage/temperature, price/credit, replenishment, route, pay/leave/benefit, accounting/tax, quality/traceability, reporting, security, and retention.

## 29. Data Provenance

Each baseline dataset identifies source, preparer, owner, approval, extraction/generation date, transformation/version, row/control totals, checksum, sensitivity, and load order.

Synthetic data identifies generator/version/seed. Real protected data is minimized, encrypted/tokenized, and never copied into general test environments without authority.

## 30. Number Allocation

All opening records use permanent business numbers from governed ranges. Numbers are not reused after failed loads. Parent-relative lines/sequences remain unique within parents.

The baseline reserves reasonable offline/emergency ranges without creating transactions. No surrogate IDs or Simulation Session keys are introduced.

## 31. Load Order

The logical load order is:

1. Core reference, calendar, locations, numbering, and security foundations
2. Company, Party, people, Owners, Suppliers, Customers, and contacts
3. Product, packs, quality/traceability profiles, and Supplier sources
4. Facility, warehouse locations, equipment, fleet, and route templates
5. Workforce, positions, assignments, qualifications, Payroll setup
6. Finance chart, periods, banks, assets, debt, equity, Budget
7. Purchase/Receipt/opening acquisition and initial Inventory/FIFO value
8. Reporting, audit, quality plans, and operational configuration
9. Cross-domain relationships, validations, and Baseline manifest

Foreign keys are never disabled to force invalid data. Staging errors are corrected before promotion.

## 32. Validation Control Totals

Required totals include Customer locations by segment; Product/Supplier counts/status; locations/capacity; Inventory quantity/value/status/storage; fleet count/readiness; Employee count/assignment/qualification; ownership percentage; cash/bank; Asset/Debt/equity; Trial Balance; configuration completeness; protected-data checks; and zero/unlisted opening AR/AP.

Every dataset count and monetary/quantity total reconciles from source to staged to final.

## 33. Cross-Domain Invariants

- All active business roles link to valid Parties/Principals.
- Every Customer location is service-eligible, assigned, and contactable.
- Every active Product has sell/purchase units, storage, price/cost, and approved source or documented exception.
- Inventory has valid Product/Lot/location/status and valuation.
- Facility/location compatibility and capacity are not exceeded.
- Trucks/drivers/Employees are active, scheduled, trained, and qualified as applicable.
- Ownership totals 100 percent.
- Cash, Assets, Debt, Equity, Inventory, and GL reconcile.
- No expired/held Product is normally available.
- All required definitions/configuration have exactly one effective version.

## 34. Baseline Manifest

The Baseline manifest records Baseline Code/version, business timestamp, schema/change level, dataset versions/checksums, counts/totals, configuration, approved variances, validation results, environment/tool versions, preparers/reviewers, and approval time.

Once approved, the manifest and underlying backup are immutable. A correction creates a new Baseline version.

## 35. Approval

Assigned domain authorities approve their data. The authorized Finance role approves Finance/security-sensitive setup; Operations and Purchasing approves operations/purchasing/quality; Sales approves Customer/commercial setup; and General Management approves cross-domain operational readiness.

The Owner Approvals required by the effective governance policy approve the final Grand-Opening Baseline, Budget/capital plan, opening capitalization, and readiness to begin.

## 36. Baseline Variants

Each selected configuration has one authoritative Grand-Opening Baseline version. Controlled variants may adjust demand, cash, Product mix, Supplier reliability, staffing, or other assumptions for testing, but are produced as separate complete Baseline versions/copies with explicit purpose.

Variants do not change PFD's core business identity or overwrite the authoritative baseline.

## 37. Protection and Retention

The approved baseline backup, manifest, load evidence, checksums, approvals, and validation reports receive durable retention and access control. Protected identity, banking, payroll, tax, and regulatory data is restricted.

Recovery tests prove the baseline can be restored independently and retains referential/integrity checks.

## 38. Decisions Established

- Baseline time is Sunday noon before the first Monday operating cycle.
- The baseline is a complete operating startup with ordinary records.
- The opening scale uses 80 Customer locations, about 3,000 Products, 60 approved/40 regular Suppliers, six trucks, and about 45–50 Employees.
- Five trucks normally dispatch; one is spare.
- The owner roster and effective interests are configurable, total 100 percent, and approve the final baseline under the effective governance policy.
- Initial Inventory includes Lot/date, storage, status, Receipt/acquisition, and FIFO valuation evidence.
- Opening AR/AP are normally zero; all listed exceptions must reconcile.
- Cash supports timely obligations and the one-month reserve policy; the revolving line targets another month.
- Facility and trucks are owned Assets with financing.
- Exact private amounts, identities, addresses, rosters, SKUs, vehicles, and account details are external configuration supported by verified data and excluded from the public repository.
- The public repository provides a complete fictional sample baseline using the same formats and validation as a private local baseline.
- No surrogate or Simulation Session keys are permitted.

## 39. Remaining Configuration

The exact opening date; legal/tax/license data; geographic records; Customer/Supplier/Product rosters; pricing/costs; Inventory quantities/Lots; facility map/capacity; truck details; Employee/pay/benefits; bank/cash/debt/asset amounts; Chart/Budget; Quality controls; report targets; and security assignments require approved opening datasets.

## 40. Acceptance Criteria

The Baseline is acceptable when it restores cleanly at the required schema level; all control totals and invariants pass; the Trial Balance and subsidiaries reconcile; protected data/access are correct; every active role is operationally ready; traceability/Recall readiness passes; and a one-day normal Scenario can begin without repairing opening data.

## 41. Next Design Work

Next: **PFD Integrated Design Validation and Implementation Readiness Specification**.
