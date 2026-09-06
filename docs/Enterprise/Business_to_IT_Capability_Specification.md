# \<business name>

## Business-to-IT Capability Specification

**Company abbreviation:** \<company abbr>
**Business address:** \<business address>  
**Document date:** September 4, 2026  
**Document status:** Authoritative business-capability specification  
**Governing business document:** `Business_Model_and_Operating_Policies.md`

---

## 1. Purpose

This specification defines the information-technology capabilities required to support \<business name> as a complete operating business.

It is the bridge between:

1. The business model and operating policies
2. Detailed process, data, report, and control requirements
3. Later software architecture and implementation design

This document defines **what the business needs IT to accomplish**. It intentionally does not define programming languages, classes, binary layouts, physical files, databases, screen designs, or hardware architecture.

---

## 2. Scope

The specification covers:

- Company governance and operating configuration
- Customer and sales management
- Product and supplier management
- Pricing and contracts
- Customer ordering
- Credit and accounts receivable
- Inventory and warehouse operations
- Purchasing and receiving
- Quality and food-safety controls
- Transportation and delivery
- Returns, claims, and customer service
- Supplier invoices and accounts payable
- Cash, debt, equity, and fixed assets
- Employees, scheduling, time, and payroll
- General accounting and financial close
- Management reporting and planning
- Security, auditability, continuity, and controlled recovery

The specification supports the opening baseline of:

- One Charlotte office and distribution facility
- Approximately 50,000 square feet
- Eighty customer locations
- Approximately 3,000 active products
- Approximately sixty approved suppliers
- Six owned, financed, multi-temperature trucks
- Approximately forty-five to fifty employees, including any owners who also hold Employee roles
- Sunday-through-Friday operations according to the approved office, warehouse, and delivery calendar

---

## 3. Specification Conventions

### 3.1 Requirement language

The word **shall** identifies a required capability. **May** identifies an allowed option. **Should** identifies a preferred practice that may require later implementation judgment.

### 3.2 Requirement identifiers

Requirements use a capability prefix and number. Principal prefixes include `CUS` for Customer Management, `ORD` for Order Management, `INV` for Inventory Management, and `FIN` for Financial Management.

Identifiers provide traceability from business policy through later design, implementation, and testing.

### 3.3 Technology neutrality

Terms such as *record*, *system of record*, *transaction*, *workflow*, and *notification* describe logical business needs. They do not prescribe a particular storage engine, communication protocol, or user interface.

---

## 4. Governing Principles

### 4.1 Business policy controls the system

IT shall enforce approved policy and shall not silently invent different operational rules. When a policy is ambiguous, the policy owner shall resolve the ambiguity before technical implementation is finalized.

### 4.2 One authoritative source

Each key business fact shall have one authoritative source. Other capabilities may consume that fact but shall not independently maintain conflicting copies.

### 4.3 Transaction entered once

Information shall be captured at the earliest practical point and reused throughout downstream processes. Departments shall not re-enter the same business transaction merely to support their own records.

### 4.4 Operational and financial integration

Operational transactions shall produce their appropriate inventory, customer, supplier, cash, and accounting consequences through controlled handoffs.

### 4.5 Exception-first management

Normal transactions shall flow according to policy. Holds, mismatches, shortages, safety problems, overdue items, margin exceptions, and other abnormal conditions shall be clearly presented for authorized resolution.

### 4.6 Effective dating and history

Business facts that change over time—such as prices, terms, status, assignments, costs, credit limits, and employee compensation—shall retain effective dates and sufficient history to explain prior transactions.

### 4.7 No destructive rewriting of history

Completed transactions shall not be silently changed or deleted. Corrections shall use controlled reversal, adjustment, credit, debit, or replacement transactions with an audit trail.

### 4.8 Reproducible simulation

The simulation shall operate the same business capabilities and persistent records that a production application would use. Reproducibility applies to controlled tests; routine simulated days and weeks continue from the actual ending state of the preceding period.

---

## 5. Business Roles and Information Responsibilities

| Role | Primary information responsibility |
|---|---|
| General Management | Overall operating policy, cross-functional decisions, approved budgets, strategic exceptions |
| Sales management | Customer relationships, sales assignments, approved commercial arrangements, routine price authority |
| Operations and Purchasing management | Physical operations, purchasing, inventory policy, warehouse execution, supplier operations |
| Finance and Administration management | Credit, accounting, cash, AP, AR, payroll administration, financial control |
| Sales Representative | Customer activity, orders, forecasts, customer preferences, approved quotes |
| Customer Service / Order Entry | Order accuracy, service exceptions, customer communications, returns coordination |
| Buyer / Inventory Planner | Replenishment, purchase orders, supplier selection, inventory availability |
| Receiving | Accepted quantities, inspection results, lots, dates, temperatures, discrepancies |
| Warehouse | Putaway, replenishment, picking, staging, loading, counts, physical inventory status |
| Transportation / Dispatch | Trucks, routes, assignments, departure, delivery results, proof of delivery |
| Driver | Vehicle inspection, route execution, delivery exceptions, returned product custody |
| Accounts Receivable / Collections | Invoices, receipts, applications, disputes, aging, collection activity |
| Accounts Payable | Supplier invoices, matching, payment schedules, discounts, remittances |
| Human Resources / Payroll | Employee status, qualifications, compensation, time, leave, payroll |
| Accounting | Posted financial transactions, periods, reconciliations, statements, controlled adjustments |
| IT / Computer Operations | Availability, access, backup, recovery, processing control, technical support |

---

## 6. End-to-End Business Capability Model

The business requires six integrated business cycles.

### 6.1 Customer-to-cash

Customer setup → pricing and credit → order → allocation → picking → loading → delivery → accepted sale → invoice and AR → collection → cash application → general ledger

### 6.2 Replenish-to-pay

Demand and inventory need → purchase recommendation → purchase order → supplier shipment → receiving and quality inspection → inventory → supplier invoice → three-way match → payment → general ledger

### 6.3 Inventory lifecycle

Receipt → quality status → putaway → reserve storage → replenishment → pick slot → allocation → picking → staging → loading → delivery or return → adjustment or disposition

### 6.4 Employee-to-payroll

Employee setup → assignment and schedule → attendance and time → approval → payroll → payment and liabilities → general ledger

### 6.5 Record-to-report

Approved operational transaction → accounting entry → subsidiary records → reconciliation → period close → financial statements → management review

### 6.6 Plan-to-perform

Forecast → operating budget and capital plan → owner approval → daily execution → KPI measurement → variance analysis → management action

---

## 7. Authoritative Information Ownership

| Information subject | Authoritative owner | Primary capability |
|---|---|---|
| Company operating calendar and policy configuration | General Management | Governance and Configuration |
| Customer identity and locations | Sales, with Finance controls | Customer Management |
| Customer credit status, terms, and limits | Finance | Credit Management |
| Customer commercial assignment and preferences | Sales | Customer Management |
| Product identity and selling configuration | Operations and Purchasing | Product Management |
| Product prices and customer agreements | Sales, with Finance margin control | Pricing |
| Supplier identity and approval | Purchasing, with Finance controls | Supplier Management |
| Purchase commitments | Purchasing | Purchasing |
| Accepted receipt quantities and inspection results | Receiving | Receiving and Quality |
| Physical inventory quantity, location, lot, and status | Operations | Inventory Management |
| Customer order and fulfillment status | Customer Service and Operations | Order Management |
| Truck, route, and dispatch status | Transportation | Transportation |
| Delivery result and proof of delivery | Driver and Transportation | Delivery Management |
| Customer invoice, receipt, and balance | Finance | AR and Cash Receipts |
| Supplier invoice, payment, and balance | Finance | AP and Payments |
| Employee status and compensation | HR and Finance | HR and Payroll |
| Posted account balances and periods | Accounting | General Ledger |
| Asset, debt, equity, and cash position | Finance | Financial Management |

---

## 8. Governance and Business Configuration

**Capability owner:** General Management  
**Primary users:** Owners, department managers, Finance, IT/Computer Operations

### 8.1 Required capabilities

- `GOV-001` — IT shall maintain the configured company name, abbreviation, business address, fiscal calendar, operating calendar, and simulation start date.
- `GOV-002` — IT shall distinguish calendar date/time, business operating date, fulfillment cycle, shift, and accounting period.
- `GOV-003` — IT shall support the approved office, warehouse, ordering, and delivery schedules, including warehouse cycles that cross midnight.
- `GOV-004` — IT shall maintain approval authorities by role, transaction type, and threshold.
- `GOV-005` — IT shall support policies that take effect on a future date without rewriting earlier transactions.
- `GOV-006` — IT shall maintain approved business configuration separately from transaction history and temporary controlled-test overrides.
- `GOV-007` — IT shall support an approved annual budget and capital plan.
- `GOV-008` — IT shall enforce and record the Owner Approvals required by the effective governance policy for reserved matters.
- `GOV-009` — IT shall retain the identity, time, decision, and rationale for material overrides.
- `GOV-010` — IT shall prevent a closed accounting period from being reopened or changed without authorized Finance control.

### 8.2 Key outputs

- Operating calendar
- Shift calendar
- Accounting calendar
- Approval-authority register
- Active policy configuration
- Budget and capital-plan status
- Override and exception history

### 8.3 Key controls

- Only authorized owners or managers may change governing configuration.
- Changes shall be effective-dated and auditable.
- Material changes shall not take effect without required approval.

---

## 9. Customer and Sales Management

**Capability owner:** Sales  
**Control owner:** Finance for legal, tax, and credit-sensitive information  
**Primary users:** Sales, Customer Service, Credit, AR, Transportation

### 9.1 Required information

- Customer number and legal name
- Customer segment
- Billing address and contacts
- One or more delivery locations
- Receiving hours and delivery restrictions
- Assigned salesperson
- Authorized order contacts
- Tax status and supporting documentation
- Standard terms and credit status
- Product preferences and prohibited substitutions
- Contract or bid relationships
- Normal delivery schedule and route area
- Customer status and effective dates

### 9.2 Required capabilities

- `CUS-001` — IT shall assign a unique, permanent customer number.
- `CUS-002` — IT shall support multiple delivery locations under one billing customer.
- `CUS-003` — IT shall distinguish active, prospective, inactive, suspended, and closed customers.
- `CUS-004` — IT shall retain prior names, addresses, assignments, terms, and statuses when changed.
- `CUS-005` — IT shall record customer segment and route territory.
- `CUS-006` — IT shall record authorized contacts and their permitted order channels.
- `CUS-007` — IT shall record normal delivery days, receiving windows, unloading rules, and site restrictions.
- `CUS-008` — IT shall record substitution preferences and customer-specific product requirements.
- `CUS-009` — IT shall present Sales with customer sales, margin, order, delivery, credit, and service history appropriate to the user's authority.
- `CUS-010` — IT shall prevent a customer from being physically deleted after transactions exist; the customer shall instead be made inactive.
- `CUS-011` — IT shall support onboarding review and approval before the first credit order.
- `CUS-012` — IT shall identify customer concentration by revenue, gross profit, and receivable balance.

### 9.3 Key outputs

- Customer profile
- Sales territory and assignment list
- Customer delivery requirements
- Customer activity history
- Customer concentration report
- Inactive and suspended customer list

### 9.4 Key exceptions

- Missing tax documentation
- Missing delivery requirements
- Conflicting billing and delivery information
- Customer without salesperson assignment
- Customer outside the normal service territory
- Duplicate or potentially duplicate customer

---

## 10. Product and Assortment Management

**Capability owner:** Operations and Purchasing  
**Primary users:** Purchasing, Sales, Warehouse, Receiving, Pricing, Accounting

### 10.1 Required information

- Permanent product/SKU number
- Description, brand, category, and status
- Selling and purchasing units of measure
- Case pack and permitted split quantity
- Weight and cube for capacity planning
- Storage class and temperature requirements
- Food/nonfood classification and segregation rules
- Lot and date-control requirements
- Minimum remaining shelf life
- Primary and alternate suppliers
- Approved substitutes
- Reorder and safety-stock policy
- Standard selling price and current costs

### 10.2 Required capabilities

- `PRD-001` — IT shall assign a unique, permanent product number.
- `PRD-002` — IT shall maintain purchasing, stocking, and selling units with controlled conversions.
- `PRD-003` — IT shall identify whether full-case, split-pack, or both are permitted.
- `PRD-004` — IT shall prevent catch-weight pricing; variable-weight products shall be represented as predefined fixed-price cases or packs.
- `PRD-005` — IT shall assign dry, refrigerated, frozen, controlled-produce, or other approved storage requirements.
- `PRD-006` — IT shall identify products requiring segregation from food or other products.
- `PRD-007` — IT shall maintain lot, expiration, and remaining-shelf-life requirements by product.
- `PRD-008` — IT shall maintain approved substitutions and identify differences requiring customer consent.
- `PRD-009` — IT shall maintain product status including active, seasonal, discontinued, suspended, and recalled.
- `PRD-010` — IT shall prevent new orders and purchases for suspended or recalled products while preserving history.
- `PRD-011` — IT shall retain effective-dated product configuration and descriptions used on historical documents.
- `PRD-012` — IT shall support approximately 3,000 active products at opening and reasonable growth.

### 10.3 Key outputs

- Product catalog
- Product storage and handling list
- Approved-substitution list
- Shelf-life control list
- Discontinued and recalled-product list
- Product velocity and profitability report

### 10.4 Key exceptions

- Missing unit conversion
- Missing storage classification
- Missing shelf-life rule
- Product without an approved supplier
- Product with conflicting food-safety attributes
- Discontinued product with remaining inventory or open commitments

---

## 11. Supplier Management

**Capability owner:** Purchasing  
**Control owner:** Finance for payment and tax information  
**Primary users:** Purchasing, Receiving, AP, Quality, Accounting

### 11.1 Required capabilities

- `SUP-001` — IT shall assign a unique, permanent supplier number.
- `SUP-002` — IT shall maintain legal, ordering, shipping, remittance, and contact information.
- `SUP-003` — IT shall distinguish approved, conditional, suspended, inactive, and prospective suppliers.
- `SUP-004` — IT shall record supplier products, costs, case packs, minimums, lead times, freight terms, payment terms, and early-payment discounts.
- `SUP-005` — IT shall maintain supplier food-safety and quality approval status.
- `SUP-006` — IT shall identify primary, alternate, specialty, and sole-source supplier relationships.
- `SUP-007` — IT shall measure fill rate, on-time performance, rejection, damage, shelf-life, claim, and responsiveness performance.
- `SUP-008` — IT shall prevent routine purchase orders to suspended or unapproved suppliers.
- `SUP-009` — IT shall retain supplier history after inactivation.
- `SUP-010` — IT shall support approximately sixty approved suppliers at opening.

### 11.2 Key outputs

- Approved supplier list
- Product-source matrix
- Supplier terms and discount schedule
- Supplier performance scorecard
- Sole-source and supply-risk report
- Suspended supplier report

### 11.3 Key exceptions

- Supplier approval expired or missing
- Product offered by no active supplier
- Conflicting remittance change
- Performance below approved standard
- Material cost increase
- Sole-source critical item

---

## 12. Pricing and Contract Management

**Capability owner:** Sales  
**Control owner:** Finance  
**Primary users:** Sales, Customer Service, Finance, Management

### 12.1 Required capabilities

- `PRI-001` — IT shall maintain standard, customer-specific, contract, promotional, and exception pricing with effective dates.
- `PRI-002` — IT shall calculate pricing from the approved selling unit and quantity.
- `PRI-003` — IT shall apply a standard 15 percent per-unit premium to split packs unless an approved product or customer exception exists.
- `PRI-004` — IT shall use current approved prices for new orders while preserving the price actually used on prior orders and invoices.
- `PRI-005` — IT shall calculate expected gross margin using the approved cost basis.
- `PRI-006` — IT shall warn or hold an order line below the established margin floor.
- `PRI-007` — IT shall support documented price override authority and approval.
- `PRI-008` — IT shall manage contract start, expiration, renewal, quantity commitment, and price terms.
- `PRI-009` — IT shall identify products for which a supplier cost change makes the current selling price unacceptable.
- `PRI-010` — IT shall support the $500 normal delivery minimum and approved small-order or expedited-delivery charges.
- `PRI-011` — IT shall retain the source of each applied price and discount.

### 12.2 Key outputs

- Standard price list
- Customer price agreement
- Contract-expiration list
- Price and cost change report
- Below-margin exception report
- Split-pack activity and margin report
- Customer and product margin analysis

### 12.3 Key controls

- Sales may discount only within assigned authority.
- Below-floor pricing requires Sales and Finance approval.
- Material long-term exceptions require General Management approval.
- A price change shall not retroactively rewrite a completed sale.

---

## 13. Customer Order Management

**Capability owner:** Sales and Customer Service  
**Operational owner after release:** Operations  
**Primary users:** Sales, Customer Service, Credit, Warehouse, Transportation

### 13.1 Required capabilities

- `ORD-001` — IT shall assign a unique sales-order number.
- `ORD-002` — IT shall capture customer, delivery location, order time, requested delivery date, salesperson, order channel, and order lines.
- `ORD-003` — IT shall validate customer status, authorized location, product status, units, prices, credit, order minimum, delivery schedule, and cutoff time.
- `ORD-004` — IT shall support standard, standing-template, emergency, special-order, and replacement orders.
- `ORD-005` — IT shall apply the Monday-through-Friday order calendar and 4:00 PM standard cutoff.
- `ORD-006` — IT shall assign Friday orders to the Sunday fulfillment cycle for Monday delivery.
- `ORD-007` — IT shall support order entry, validation, hold, approval, release, allocation, picking, loading, delivery, completion, cancellation, and backorder statuses.
- `ORD-008` — IT shall identify every hold and the role authorized to resolve it.
- `ORD-009` — IT shall permit normal changes and cancellation before warehouse release.
- `ORD-010` — IT shall require authorized exception handling for changes after release.
- `ORD-011` — IT shall preserve the original order and record subsequent changes, identity, time, and reason.
- `ORD-012` — IT shall support approved substitutions, partial quantities, backorders, and cancellation of unavailable quantities.
- `ORD-013` — IT shall notify the responsible Sales or Customer Service user of material shortages or changes requiring customer communication.
- `ORD-014` — IT shall prevent an order from being released until required credit, price, inventory, route, and delivery validations are satisfied or authorized overrides are recorded.
- `ORD-015` — IT shall provide complete order status across departments without requiring duplicate departmental orders.

### 13.2 Key outputs

- Order confirmation
- Order hold list
- Cutoff and late-order list
- Released-order file or equivalent handoff
- Backorder and shortage report
- Customer notification worklist
- Order status inquiry

### 13.3 Key exceptions

- Inactive customer or product
- Unauthorized delivery location
- Credit hold
- Below-minimum order
- Below-margin line
- Insufficient inventory
- Unapproved substitution
- Missed cutoff
- Delivery date without route capacity
- Change after warehouse release

---

## 14. Credit Management

**Capability owner:** Finance and Administration  
**Primary users:** Credit, AR, Collections, Sales inquiry, General Management

### 14.1 Required capabilities

- `CRD-001` — IT shall maintain customer payment terms, credit limit, risk classification, and hold status.
- `CRD-002` — IT shall calculate exposure from open receivables, released uninvoiced orders, pending deliveries, and the proposed order.
- `CRD-003` — IT shall warn or hold an order that materially exceeds approved exposure.
- `CRD-004` — IT shall support Net 30 as the normal term and approved Net 45, prepaid, COD, or restricted terms.
- `CRD-005` — IT shall support temporary and permanent holds with reason, authority, start date, review date, and release history.
- `CRD-006` — IT shall prevent Sales from unilaterally removing a Finance credit hold.
- `CRD-007` — IT shall record credit reviews, references, payment behavior, disputes, returned payments, and collection history.
- `CRD-008` — IT shall support an authorized one-order or temporary-limit exception without permanently altering the standard limit.
- `CRD-009` — IT shall identify deteriorating payment performance and customers requiring review.
- `CRD-010` — IT shall provide Sales appropriate visibility into credit availability and holds without exposing restricted Finance information.

### 14.2 Key outputs

- Credit exposure inquiry
- Credit-hold worklist
- Credit-review schedule
- Limit-utilization report
- Payment-behavior trend
- High-risk customer report

---

## 15. Inventory Management

**Capability owner:** Operations  
**Financial control owner:** Accounting  
**Primary users:** Warehouse, Purchasing, Receiving, Sales, Accounting

### 15.1 Required capabilities

- `INV-001` — IT shall maintain perpetual quantity by product, warehouse zone, location, unit of measure, lot where applicable, and inventory status.
- `INV-002` — IT shall distinguish reserve, pick, staging, loaded, quality-hold, quarantine, damaged, returned, expired, and pending-disposition inventory.
- `INV-003` — IT shall distinguish on-hand, available, allocated, picked, and on-order quantities.
- `INV-004` — IT shall record every inventory movement with product, quantity, source, destination, date/time, reason, and responsible employee or process.
- `INV-005` — IT shall record when each lot or pallet is placed into a picking slot.
- `INV-006` — IT shall allow multiple lots of the same product in a picking slot while identifying the lot that should be depleted next.
- `INV-007` — IT shall direct FEFO selection; equal expiration dates shall use oldest pick-slot placement first.
- `INV-008` — IT shall block expired inventory and inventory below the product's minimum remaining shelf life from normal allocation and shipment.
- `INV-009` — IT shall support authorized short-dated discount disposition with informed customer acceptance, supplier return, donation, or disposal.
- `INV-010` — IT shall support reserve-to-pick replenishment based on released demand, minimum pick quantity, and case configuration.
- `INV-011` — IT shall generate planned second-shift replenishment work and permit documented emergency replenishment during picking.
- `INV-012` — IT shall support allocation by delivery priority, contractual obligation, customer priority, approved substitution, fairness, and route feasibility.
- `INV-013` — IT shall prevent informal inventory reservations outside the authorized allocation process.
- `INV-014` — IT shall support cycle counting by product importance and an annual full physical inventory.
- `INV-015` — IT shall freeze or otherwise control the quantity being counted so normal movement does not invalidate the count.
- `INV-016` — IT shall require recount and warehouse-manager approval for significant variances.
- `INV-017` — IT shall require a reason and accounting consequence for each approved adjustment.
- `INV-018` — IT shall value inventory using FIFO while directing physical movement using FEFO.
- `INV-019` — IT shall support inventory reconciliation to the general ledger.
- `INV-020` — IT shall retain sufficient receipt, location, lot-placement, movement, and shipment timing to estimate a recall exposure window without recording an exact customer-to-lot relationship.

### 15.2 Key outputs

- Inventory availability inquiry
- Inventory by location and status
- Allocation and shortage worklist
- Pick-slot replenishment worklist
- FEFO and expiration-risk report
- Short-dated and expired inventory report
- Inventory valuation
- Cycle-count schedule and variance report
- Slow-moving and excess inventory report
- Estimated recall-exposure report

### 15.3 Key controls

- Held, quarantined, damaged, expired, and recalled inventory shall not be available for normal sale.
- Inventory adjustments shall not be used to conceal receiving, picking, or shipment errors.
- Physical and financial inventory shall be reconciled regularly.
- Exact outbound customer-lot traceability is intentionally outside the approved business model.

---

## 16. Purchasing and Replenishment

**Capability owner:** Operations and Purchasing  
**Primary users:** Buyers, Inventory Planning, Receiving, AP, Management

### 16.1 Required capabilities

- `PUR-001` — IT shall calculate purchase recommendations from available inventory, allocations, open orders, on-order quantities, forecast demand, safety stock, lead time, supplier reliability, case packs, minimums, storage capacity, shelf life, and cash considerations.
- `PUR-002` — IT shall allow the buyer to accept, modify, defer, or reject a recommendation with an appropriate reason.
- `PUR-003` — IT shall assign a unique purchase-order number.
- `PUR-004` — IT shall capture supplier, ship-to location, order date, expected date, products, quantities, units, costs, freight terms, payment terms, and buyer.
- `PUR-005` — IT shall apply buyer and management approval limits.
- `PUR-006` — IT shall prevent routine ordering from unapproved or suspended suppliers.
- `PUR-007` — IT shall support primary and approved alternate-source selection.
- `PUR-008` — IT shall identify sole-source risk and critical products lacking an available supplier.
- `PUR-009` — IT shall maintain open, acknowledged, partially received, completed, cancelled, and closed purchase-order status.
- `PUR-010` — IT shall record supplier acknowledgement and expected-date changes.
- `PUR-011` — IT shall prevent received quantities from silently exceeding approved purchase quantities beyond established tolerance.
- `PUR-012` — IT shall identify projected stockouts, excess stock, storage-capacity issues, and expiration risk before an order is placed.
- `PUR-013` — IT shall provide purchase commitments and expected cash requirements to Finance.
- `PUR-014` — IT shall measure buyer overrides and the later operational outcome.

### 16.2 Key outputs

- Purchase recommendation worklist
- Purchase order
- Open purchase-order report
- Expected receipt schedule
- Projected stockout report
- Excess and slow-moving inventory forecast
- Purchase commitment and cash-requirement forecast
- Supplier-source risk report

---

## 17. Receiving, Putaway, and Quality

**Capability owner:** Operations  
**Primary users:** Receiving, Warehouse, Purchasing, Quality, AP

### 17.1 Appointment capabilities

- `REC-001` — IT shall schedule supplier receiving appointments during authorized first-shift receiving windows.
- `REC-002` — IT shall consider dock, labor, storage-zone, and expected-volume capacity.
- `REC-003` — IT shall identify unscheduled or late arrivals and require approval for acceptance.

### 17.2 Receiving capabilities

- `REC-004` — IT shall match each normal receipt to an approved purchase order.
- `REC-005` — IT shall capture actual product, unit, quantity, lot, expiration date, condition, temperature, and inspection results as applicable.
- `REC-006` — IT shall distinguish accepted, rejected, held, quarantined, damaged, short, over, and substituted quantities.
- `REC-007` — IT shall permit acceptance of the satisfactory portion and rejection of the affected portion.
- `REC-008` — IT shall generate discrepancy information for Purchasing and AP.
- `REC-009` — IT shall prevent held or quarantined product from becoming available inventory.
- `REC-010` — IT shall identify insufficient remaining shelf life at receipt.
- `REC-011` — IT shall create putaway work appropriate to storage temperature, segregation, capacity, and product location rules.
- `REC-012` — IT shall update inventory only for the quantity and status actually accepted or held.
- `REC-013` — IT shall update purchase-order received status without destroying the original ordered commitment.
- `REC-014` — IT shall retain inspection and discrepancy history by supplier, product, shipment, and receiver.

### 17.3 Key outputs

- Receiving appointment schedule
- Expected-arrival list
- Receipt record
- Receiving discrepancy report
- Quality-hold and quarantine worklist
- Putaway worklist
- Supplier rejection and shelf-life report

### 17.4 Key controls

- A receiver shall not alter the purchase-order price to force a match.
- Product shall not be available before required inspection is complete.
- Receipt corrections after completion shall require authorization and history.

### 17.5 Food-safety and sanitation capabilities

- `QFS-001` — IT shall identify the authorized food-safety leader and backup.
- `QFS-002` — IT shall maintain scheduled and completed sanitation, inspection, pest-control, and temperature-check activities.
- `QFS-003` — IT shall record the facility area, responsible person, completion time, findings, corrective action, and verification for controlled food-safety work.
- `QFS-004` — IT shall maintain employee food-safety training and required renewal dates.
- `QFS-005` — IT shall support immediate product hold by product, lot, location, supplier, date range, or other available identifying information.
- `QFS-006` — IT shall prevent held, quarantined, recalled, expired, or unsafe product from allocation, picking, loading, or supplier return without authorized disposition.
- `QFS-007` — IT shall support a documented investigation, risk assessment, corrective action, disposition, and closure for a food-safety incident.
- `QFS-008` — IT shall support recall investigation using supplier receipts, recorded lots, expiration dates, slot-placement history, movements, remaining inventory, and customer shipment dates.
- `QFS-009` — IT shall clearly state when recall exposure is estimated because the business does not capture exact customer-to-lot shipment linkage.
- `QFS-010` — IT shall retain supplier, customer, management, and other required communications associated with a withdrawal or recall.
- `QFS-011` — IT shall support recall effectiveness review and management signoff before closure.
- `QFS-012` — IT shall report overdue sanitation, temperature, training, hold, investigation, and corrective-action work.

### 17.6 Food-safety outputs

- Sanitation and inspection schedule
- Temperature exception report
- Food-safety training status
- Product hold and quarantine register
- Recall exposure estimate
- Recall action and communication log
- Corrective-action worklist
- Food-safety incident report

---

## 18. Warehouse Fulfillment

**Capability owner:** Operations  
**Primary users:** Warehouse supervisors, replenishers, pickers, loaders, Customer Service, Dispatch

### 18.1 Required capabilities

- `WHS-001` — IT shall organize warehouse work by fulfillment cycle, shift, route, stop, storage zone, and order priority.
- `WHS-002` — IT shall release only orders that have passed required customer, credit, price, inventory, and route controls.
- `WHS-003` — IT shall create planned second-shift replenishment and picking work.
- `WHS-004` — IT shall create primary third-shift picking, staging, and loading work.
- `WHS-005` — IT shall direct the correct product, location, selling unit, quantity, and FEFO choice.
- `WHS-006` — IT shall distinguish full-case and split-pack work.
- `WHS-007` — IT shall require controlled handling of open cases and remaining split inventory.
- `WHS-008` — IT shall record picked, short, damaged, substituted, and skipped quantities.
- `WHS-009` — IT shall route exceptions to authorized resolution without permitting undocumented substitution.
- `WHS-010` — IT shall stage completed product by route and stop while preserving temperature and segregation requirements.
- `WHS-011` — IT shall support independent checking for controlled, high-error, high-value, or split-pack items.
- `WHS-012` — IT shall build and reconcile the load against released orders and approved changes.
- `WHS-013` — IT shall prevent undocumented product from being loaded.
- `WHS-014` — IT shall record work start, completion, employee, quantity, and exception information sufficient for productivity and capacity analysis.
- `WHS-015` — IT shall identify orders or routes at risk of missing the planned departure time.
- `WHS-016` — IT shall carry the fulfillment-cycle business date across midnight so Sunday night activity fulfills Monday deliveries and weekday night activity remains associated with the originating order cycle.

### 18.2 Key outputs

- Replenishment work
- Pick work
- Warehouse exception worklist
- Staging and load plan
- Load reconciliation
- Unfilled and partial-order report
- Warehouse completion status
- Labor productivity and capacity report
- Departure-risk alert

---

## 19. Transportation, Routing, and Delivery

**Capability owner:** Operations / Transportation  
**Primary users:** Dispatcher, Transportation supervisor, Drivers, Customer Service, Fleet maintenance

### 19.1 Fleet capabilities

- `TRN-001` — IT shall maintain six owned, financed, multi-temperature trucks with permanent truck numbers.
- `TRN-002` — IT shall maintain capacity, compartment, registration, insurance, maintenance, inspection, mileage, and availability information.
- `TRN-003` — IT shall identify five normal route trucks and one spare without permanently restricting the spare from use.
- `TRN-004` — IT shall prevent dispatch of an unavailable or unsafe truck.
- `TRN-005` — IT shall plan and record preventive maintenance without losing vehicle history.

### 19.2 Route and dispatch capabilities

- `TRN-006` — IT shall maintain stable geographic route patterns for Statesville, Monroe, Rock Hill, Gastonia, and intervening service corridors.
- `TRN-007` — IT shall assign deliveries to routes considering geography, customer receiving windows, truck and compartment capacity, service commitments, driver availability, and departure time.
- `TRN-008` — IT shall support daily adjustments without destroying the standard route plan.
- `TRN-009` — IT shall identify overload, time-window conflict, excessive route time, and unavailable-driver conditions.
- `TRN-010` — IT shall prepare a stop sequence, route manifest, invoices, and required delivery documents before departure.
- `TRN-011` — IT shall record load completion, truck, driver, scheduled departure, actual departure, and route status.

### 19.3 Delivery capabilities

- `TRN-012` — IT shall record arrival, completion, accepted quantity, refusal, shortage, damage, late delivery, and other delivery results.
- `TRN-013` — IT shall capture proof of delivery and the identity of the receiving party when available.
- `TRN-014` — IT shall route refused, damaged, or undelivered product into the controlled return process.
- `TRN-015` — IT shall prevent drivers from changing prices or authorizing credits.
- `TRN-016` — IT shall notify Customer Service promptly of material delivery exceptions.
- `TRN-017` — IT shall measure on-time delivery, route cost, miles, stops, capacity use, fuel, and exception rates.
- `TRN-018` — IT shall support truck breakdown and route reassignment using the spare truck or other approved contingency.

### 19.4 Key outputs

- Daily route plan
- Route manifest
- Truck load and compartment plan
- Customer invoices and delivery documents
- Dispatch status board
- Proof-of-delivery record
- Delivery exception worklist
- Route performance and cost report
- Fleet maintenance and availability report

---

## 20. Invoice Finalization, Accounts Receivable, and Collections

**Capability owner:** Finance and Administration  
**Primary users:** Billing, AR, Collections, Customer Service, Accounting

### 20.1 Invoice timing and status

- `AR-001` — IT shall assign a unique invoice number and prepare the customer invoice before truck departure.
- `AR-002` — IT shall distinguish a predeparture invoice pending delivery from a finalized, posted invoice.
- `AR-003` — IT shall permit the printed invoice to accompany the delivery while delaying final revenue and receivable recognition until accepted delivery is confirmed.
- `AR-004` — IT shall finalize accepted delivered quantities and create the related sale, AR, revenue, and cost-of-goods-sold consequences.
- `AR-005` — IT shall not recognize revenue for refused, undelivered, or rejected quantities.
- `AR-006` — IT shall resolve postdeparture differences through a controlled credit memo, debit memo, supplemental invoice, or invoice finalization adjustment.

### 20.2 Receivable capabilities

- `AR-007` — IT shall maintain open items by customer, invoice, due date, amount, dispute status, and aging category.
- `AR-008` — IT shall support partial payments, unapplied receipts, deductions, credits, write-offs, and refunds with approval.
- `AR-009` — IT shall apply receipts to specific open items or according to an approved customer remittance rule.
- `AR-010` — IT shall keep disputed and undisputed balances distinguishable.
- `AR-011` — IT shall produce customer statements and support delivery by approved means.
- `AR-012` — IT shall calculate current, 1-30, 31-60, 61-90, and over-90-day aging.
- `AR-013` — IT shall maintain collection contacts, promises to pay, disputes, follow-up dates, and outcomes.
- `AR-014` — IT shall generate collection work based on age, amount, risk, promise date, and customer importance.
- `AR-015` — IT shall identify accounts requiring credit review or hold.
- `AR-016` — IT shall support an allowance for expected credit losses and approved write-off.
- `AR-017` — IT shall reconcile the AR subsidiary balance to the general ledger.

### 20.3 Key outputs

- Invoice and credit memo
- Customer statement
- AR aging
- Collections worklist
- Promise-to-pay report
- Dispute report
- Cash-receipt and application report
- AR-to-GL reconciliation
- Days-sales-outstanding analysis

---

## 21. Returns, Claims, and Customer Service

**Capability owner:** Customer Service  
**Disposition owner:** Operations  
**Financial control owner:** Finance

### 21.1 Required capabilities

- `RET-001` — IT shall assign a unique case or return-authorization number to a customer complaint or planned return.
- `RET-002` — IT shall relate the issue to the customer, delivery, invoice, product, quantity, route, driver, and order when applicable.
- `RET-003` — IT shall record reason, description, customer communication, ownership, target date, and resolution.
- `RET-004` — IT shall distinguish immediate driver-recorded refusal from a later authorized return.
- `RET-005` — IT shall place returned product into a nonavailable status pending inspection.
- `RET-006` — IT shall record inspection and final disposition: available, hold, quarantine, supplier return, donation, or disposal.
- `RET-007` — IT shall presume temperature-controlled product unsuitable for resale after customer custody unless authorized evidence establishes integrity.
- `RET-008` — IT shall require approved reason codes and original-transaction reference for credits.
- `RET-009` — IT shall require approval for material or unusual credits.
- `RET-010` — IT shall identify recurring patterns by product, supplier, picker, driver, route, salesperson, and customer.
- `RET-011` — IT shall ensure financial, inventory, customer, and supplier-claim consequences are completed before a case is closed.

### 21.2 Key outputs

- Customer-service worklist
- Return authorization
- Product-disposition worklist
- Credit approval worklist
- Open complaint and aging report
- Return and credit trend report
- Root-cause report

---

## 22. Supplier Invoices, Accounts Payable, and Payments

**Capability owner:** Finance and Administration  
**Primary users:** AP, Purchasing, Receiving, Accounting, Cash Management

### 22.1 Required capabilities

- `AP-001` — IT shall record each supplier invoice with supplier, invoice number, date, due date, terms, discount date, amount, and related purchase order or expense authority.
- `AP-002` — IT shall detect potential duplicate supplier invoices.
- `AP-003` — IT shall perform a three-way match among purchase order, accepted receipt, and supplier invoice.
- `AP-004` — IT shall apply approved quantity, price, freight, and rounding tolerances.
- `AP-005` — IT shall route mismatches to Purchasing, Receiving, or AP according to the discrepancy type.
- `AP-006` — IT shall distinguish disputed and undisputed amounts.
- `AP-007` — IT shall schedule the undisputed amount for timely payment even when a disputed portion remains unresolved.
- `AP-008` — IT shall retain supplier communications, agreed resolution, credits, and adjustments.
- `AP-009` — IT shall identify economically worthwhile early-payment discounts and their deadlines.
- `AP-010` — IT shall consider available cash, cash forecast, payment priority, and supplier terms when proposing payments.
- `AP-011` — IT shall require appropriate approval before releasing payment.
- `AP-012` — IT shall produce clear supplier remittance information.
- `AP-013` — IT shall prevent the same obligation from being paid twice.
- `AP-014` — IT shall maintain AP aging and reconcile the AP subsidiary balance to the general ledger.
- `AP-015` — IT shall measure available discounts, discounts taken, and discounts lost.

### 22.2 Key outputs

- Three-way-match worklist
- Supplier discrepancy and dispute report
- Proposed payment register
- Early-payment discount report
- Payment approval register
- Supplier remittance
- AP aging
- AP-to-GL reconciliation

---

## 23. Cash, Banking, Debt, and Equity

**Capability owner:** Finance and Administration  
**Primary users:** Cash Management, Accounting, Owners

### 23.1 Required capabilities

- `CSH-001` — IT shall maintain bank, cash, restricted-cash, and line-of-credit accounts.
- `CSH-002` — IT shall forecast cash from expected customer receipts, supplier payments, payroll, taxes, debt service, capital spending, and other commitments.
- `CSH-003` — IT shall compare projected cash to one-month operating-cash target.
- `CSH-004` — IT shall maintain unused line-of-credit availability approximately equal to one additional month of normal operating cash needs.
- `CSH-005` — IT shall require owner approval for normal line-of-credit draws.
- `CSH-006` — IT shall support an emergency draw to prevent overdraft or missed payroll and immediately report it for owner review.
- `CSH-007` — IT shall maintain loan principal, interest, payment schedule, maturity, collateral, and covenant information.
- `CSH-008` — IT shall distinguish owner capital contributions, compensation, loans, and distributions.
- `CSH-009` — IT shall prevent owner distributions from being treated as operating expense.
- `CSH-010` — IT shall support bank reconciliation by an employee independent of routine cash-receipt and payment preparation when staffing permits.
- `CSH-011` — IT shall identify unusual, stale, duplicate, or unreconciled cash items.
- `CSH-012` — IT shall provide a rolling cash forecast and liquidity warning.

### 23.2 Key outputs

- Daily cash position
- Rolling cash forecast
- Credit-line availability and usage report
- Debt schedule
- Debt-service forecast
- Owner capital and distribution statement
- Bank reconciliation
- Liquidity exception report

---

## 24. Human Resources, Scheduling, Time, and Payroll

**Capability owner:** Finance and Administration  
**Operational users:** Department managers and supervisors

### 24.1 Required capabilities

- `HR-001` — IT shall assign a unique, permanent employee number.
- `HR-002` — IT shall maintain employment status, department, position, manager, hire date, compensation method, and effective-dated compensation.
- `HR-003` — IT shall maintain qualifications, training, licenses, and expiration dates required for assigned duties.
- `HR-004` — IT shall maintain standard schedules and actual attendance by date and shift.
- `HR-005` — IT shall record absence, vacation, sick leave, overtime, training, and temporary assignment.
- `HR-006` — IT shall translate employee availability into departmental and shift capacity.
- `HR-007` — IT shall alert management when absence or qualification loss creates a critical staffing shortage.
- `HR-008` — IT shall support biweekly payroll for hourly employees and the approved payroll calendar for salaried employees.
- `HR-009` — IT shall calculate regular time, overtime, approved paid leave, deductions, employer taxes, and benefits.
- `HR-010` — IT shall require supervisor approval of time and independent payroll review before payment.
- `HR-011` — IT shall separate employee master changes from payroll approval when staffing permits.
- `HR-012` — IT shall record payroll payment, liabilities, and general-ledger effects.
- `HR-013` — IT shall prevent terminated or inactive employees from receiving routine payroll unless a controlled final payment is authorized.
- `HR-014` — IT shall retain employment and payroll history after termination.
- `HR-015` — IT shall distinguish owner payroll from owner distributions.

### 24.2 Key outputs

- Employee roster
- Shift schedule and staffing-capacity report
- Attendance and absence report
- Expiring qualification report
- Overtime and labor-cost report
- Payroll register
- Payroll exception and approval report
- Payroll liabilities and GL reconciliation

---

## 25. Fixed Assets and Fleet Assets

**Capability owner:** Finance and Administration  
**Custody owners:** Operations, Transportation, and department managers

### 25.1 Required capabilities

- `AST-001` — IT shall assign a unique, permanent fixed-asset number.
- `AST-002` — IT shall maintain description, category, acquisition date, cost, location, custodian, financing, useful life, depreciation method, and status.
- `AST-003` — IT shall relate financed assets to their debt obligations without combining the asset and liability records.
- `AST-004` — IT shall support facility, refrigeration, warehouse equipment, computer equipment, office equipment, and trucks.
- `AST-005` — IT shall calculate and post periodic depreciation according to approved policy.
- `AST-006` — IT shall support additions, transfers, improvements, impairments, retirements, sales, and disposals with approval.
- `AST-007` — IT shall distinguish capital improvement from routine repair and maintenance.
- `AST-008` — IT shall support physical verification and reconciliation of assets.
- `AST-009` — IT shall preserve complete history after disposal.

### 25.2 Key outputs

- Fixed-asset register
- Depreciation schedule
- Asset addition and disposal report
- Asset-to-GL reconciliation
- Asset location and custodian report
- Capital-plan comparison

---

## 26. General Ledger and Financial Close

**Capability owner:** Finance and Administration / Accounting  
**Primary users:** Accounting, Owners, department managers for approved reports

### 26.1 Required capabilities

- `FIN-001` — IT shall maintain a controlled chart of accounts and calendar fiscal periods.
- `FIN-002` — IT shall receive balanced accounting effects from approved operational transactions.
- `FIN-003` — IT shall maintain clear linkage from each accounting entry to its originating business transaction.
- `FIN-004` — IT shall prevent an unbalanced journal entry from posting.
- `FIN-005` — IT shall support documented manual journals, reversals, accruals, allocations, and recurring entries.
- `FIN-006` — IT shall require independent approval of material manual journals.
- `FIN-007` — IT shall prevent ordinary posting to a closed period.
- `FIN-008` — IT shall support accrual-basis accounting and FIFO inventory valuation.
- `FIN-009` — IT shall recognize revenue and related cost of goods sold upon accepted delivery.
- `FIN-010` — IT shall account for returns, credits, expected credit losses, shrink, spoilage, obsolescence, depreciation, interest, taxes, debt, and equity appropriately.
- `FIN-011` — IT shall maintain subsidiary-to-GL reconciliation for AR, AP, inventory, payroll liabilities, fixed assets, debt, and cash.
- `FIN-012` — IT shall continuously verify that assets equal liabilities plus equity.
- `FIN-013` — IT shall support monthly closing tasks, responsibility, status, evidence, and approval.
- `FIN-014` — IT shall produce a trial balance, income statement, balance sheet, and cash-flow information.
- `FIN-015` — IT shall preserve posted history and corrections through controlled entries rather than silent edits.
- `FIN-016` — IT shall compare actual results with the approved budget.

### 26.2 Standard operational accounting events

| Business event | Required accounting result |
|---|---|
| Accepted customer delivery | Recognize revenue and accounts receivable |
| Accepted customer delivery | Recognize cost of goods sold and reduce inventory |
| Customer payment | Increase cash and reduce accounts receivable |
| Customer credit or accepted return | Reduce revenue/AR and record inventory or loss consequence as appropriate |
| Accepted supplier receipt with obligation | Increase inventory and establish AP or received-not-invoiced accrual as appropriate |
| Supplier invoice match | Establish or finalize accounts payable |
| Supplier payment | Reduce accounts payable and cash |
| Payroll | Record labor expense, liabilities, deductions, and cash payment |
| Asset acquisition | Record asset, cash/down payment, and financing obligation |
| Depreciation | Record depreciation expense and accumulated depreciation |
| Owner capital contribution | Increase cash or contributed asset and owner equity |
| Owner distribution | Reduce cash and owner equity; do not record operating expense |
| Debt draw and repayment | Record debt, cash, principal reduction, and interest separately |

### 26.3 Key outputs

- Trial balance
- General ledger
- Income statement
- Balance sheet
- Cash-flow information
- Budget-to-actual report
- Subsidiary reconciliation status
- Close checklist and unresolved-item report
- Accounting-integrity report

---

## 27. Management Planning, Reporting, and Analytics

**Capability owner:** General Management  
**Information owners:** Respective department owners  
**Primary users:** Owners and department managers

### 27.1 Required capabilities

- `RPT-001` — IT shall produce daily, weekly, monthly, annual, and on-demand management information.
- `RPT-002` — IT shall use the configured company name and reporting period on formal reports.
- `RPT-003` — IT shall permit authorized drill-through from summarized results to supporting transactions.
- `RPT-004` — IT shall distinguish actual, budget, forecast, and prior-period values.
- `RPT-005` — IT shall support analysis by customer, segment, salesperson, product, category, supplier, warehouse zone, route, truck, driver, and period as appropriate.
- `RPT-006` — IT shall identify exceptions requiring action and assign or route responsibility.
- `RPT-007` — IT shall preserve the parameters and timing used to produce a formal period report.
- `RPT-008` — IT shall support controlled reproducibility when a deliberate test is initialized from a restored database copy with a recorded configuration and random seed.
- `RPT-009` — IT shall compare days, weeks, months, budgets, and forecasts across revenue, margin, profit, cash, service, inventory, labor, and capacity measures using the ordinary business records.
- `RPT-010` — IT shall restrict confidential payroll, employee, credit, and owner information to authorized users.

### 27.2 Daily operating reports

- Orders received, released, held, late, and cancelled
- Warehouse completion and departure readiness
- Inventory shortages and substitutions
- Routes, departures, completed stops, and exceptions
- Receiving schedule and discrepancies
- Critical cash, credit, quality, and staffing events

### 27.3 Weekly management reports

- Sales and gross margin
- Fill rate and customer service
- Warehouse productivity and overtime
- Delivery performance and route cost
- Inventory shortages, excess, and expiration risk
- Supplier service and purchasing exceptions
- AR collections and overdue risk
- AP obligations and discount opportunities

### 27.4 Monthly management reports

- Income statement and balance sheet
- Cash-flow and liquidity forecast
- Budget-to-actual results
- Customer and product profitability
- Inventory valuation, turnover, shrink, spoilage, and obsolescence
- AR and AP aging
- Labor cost and productivity
- Fleet cost and utilization
- KPI scorecard and corrective actions

### 27.5 Core KPIs

- Revenue growth
- Gross profit dollars
- Gross-margin percentage
- Contribution by customer and route
- Order fill rate
- On-time delivery rate
- Picking and delivery accuracy
- Credits and returns as a percentage of sales
- Inventory turnover
- Expiration, spoilage, damage, and shrink rate
- Warehouse cases per labor hour
- Truck utilization and route cost
- Supplier fill rate and on-time performance
- Days sales outstanding
- AP discount capture
- Cash reserve and credit-line use
- Operating income
- Return on owner equity
- Safety and food-quality incidents

---

## 28. Notifications, Holds, and Exception Work

### 28.1 Common exception requirements

- `EXC-001` — Every material exception shall have a type, severity, creation time, related business object, responsible role, status, and resolution history.
- `EXC-002` — An exception shall not disappear merely because the originating transaction advances.
- `EXC-003` — A hold shall identify what is blocked and who may release it.
- `EXC-004` — Overrides shall record the approving person, time, reason, and original condition.
- `EXC-005` — Unresolved exceptions shall age and escalate according to business importance.
- `EXC-006` — Safety, quality, cash, payroll, and departure-threatening exceptions shall receive highest operational visibility.

### 28.2 Principal exception queues

- Customer onboarding incomplete
- Credit hold or excess exposure
- Price or margin exception
- Order below minimum
- Inventory shortage or allocation conflict
- Product near expiration
- Pick-slot replenishment shortage
- Warehouse completion at risk
- Truck, driver, or route-capacity problem
- Delivery refusal, damage, or shortage
- Receiving discrepancy or quality hold
- Unmatched supplier invoice
- Lost early-payment discount opportunity
- Overdue receivable or broken promise to pay
- Inventory-count variance
- Payroll or time exception
- Bank-reconciliation difference
- Accounting imbalance or close task overdue

---

## 29. Authorization and Segregation of Duties

### 29.1 General access requirements

- `SEC-001` — Each user shall have an individual identity.
- `SEC-002` — Access shall follow job responsibility and least privilege.
- `SEC-003` — Sensitive actions shall require explicit authority, not merely screen access.
- `SEC-004` — Inactive and terminated users shall lose access promptly.
- `SEC-005` — Privileged and owner activity shall remain auditable.
- `SEC-006` — Temporary access shall have an expiration date and approval.
- `SEC-007` — Confidential employee, payroll, credit, banking, and owner information shall be restricted.

### 29.2 Required separation where staffing permits

| Process | Preparation or custody | Independent approval or reconciliation |
|---|---|---|
| Customer pricing below floor | Sales | Finance and authorized management |
| Customer credit hold and release | Credit/Finance | Authorized Finance management |
| Purchase order | Buyer | Purchasing management above threshold |
| Goods receipt | Receiving | Purchasing/AP use the independent receipt |
| Supplier invoice | AP | Match and payment approval |
| Supplier payment | AP prepares | Authorized approver releases; bank reconciler reviews |
| Inventory count | Counter | Independent recount/warehouse-manager approval for variance |
| Inventory adjustment | Warehouse prepares | Warehouse manager; Accounting for material adjustment |
| Cash receipt | AR records/applies | Independent bank reconciliation |
| Employee master/compensation | HR prepares | Authorized management approves |
| Payroll | Payroll prepares | Independent review and payment approval |
| Manual journal | Accountant prepares | Independent approver for material entry |
| Owner distribution | Finance prepares | Required owner approval |

When staffing makes full separation impractical, the business shall use compensating owner review and documented reconciliation.

---

## 30. Audit Trail and Record Integrity

- `AUD-001` — IT shall record creation, change, approval, status transition, reversal, and override history for controlled records and transactions.
- `AUD-002` — History shall identify user or process, timestamp, prior value, new value, and reason when applicable.
- `AUD-003` — Completed transactional history shall be append-only from the business user's perspective.
- `AUD-004` — Corrections shall preserve the original transaction and the correcting transaction.
- `AUD-005` — Number sequences for customers, products, employees, suppliers, orders, invoices, purchase orders, receipts, payments, journals, and assets shall not be silently reused.
- `AUD-006` — Missing, duplicated, or out-of-sequence controlled numbers shall be reportable.
- `AUD-007` — IT shall support traceability from management and financial reports to originating business activity.
- `AUD-008` — Rebuilt indexes or other technical recovery operations shall not alter authoritative business content.

---

## 31. Business Calendar and Processing Windows

### 31.1 Office

- Monday-Friday, 8:00 AM-5:00 PM
- Closed Saturday and Sunday

### 31.2 Ordering

- Monday-Friday only
- Standard next-delivery cutoff: 4:00 PM

### 31.3 Warehouse

| Day | First shift, 7 AM-3 PM | Second shift, 3 PM-11 PM | Third shift, 11 PM-7 AM |
|---|---|---|---|
| Sunday | Closed | Prep, replenishment, early picking/loading | Primary picking/loading |
| Monday-Thursday | Receiving and daytime work | Prep, replenishment, early picking/loading | Primary picking/loading |
| Friday | Receiving and daytime work | Closed | Closed |
| Saturday | Closed | Closed | Closed |

### 31.4 Delivery relationship

| Order day | Fulfillment cycle | Expected delivery |
|---|---|---|
| Monday | Monday evening/night | Tuesday |
| Tuesday | Tuesday evening/night | Wednesday |
| Wednesday | Wednesday evening/night | Thursday |
| Thursday | Thursday evening/night | Friday |
| Friday | Sunday evening/night | Monday |

### 31.5 Processing requirement

- `CAL-001` — IT shall schedule business work using actual timestamps while preserving the correct operating date and fulfillment cycle.
- `CAL-002` — IT shall not treat activity after midnight as a new unrelated business cycle merely because the calendar date changed.
- `CAL-003` — Planned technical maintenance shall avoid critical order cutoff, picking, loading, dispatch, payroll, payment, and close windows.

---

## 32. Availability, Continuity, and Recovery

### 32.1 Availability priorities

The highest availability is required during:

- Weekday order entry and cutoff
- Sunday-through-Thursday replenishment, picking, and loading
- Early-morning dispatch
- First-shift receiving
- Payroll and supplier-payment processing
- Accounting close

### 32.2 Required capabilities

- `BCP-001` — IT shall support controlled backup of master information, open work, completed transactions, configuration, and audit history.
- `BCP-002` — IT shall verify that backups can be restored.
- `BCP-003` — IT shall support restart after interruption without duplicating or losing completed business transactions.
- `BCP-004` — IT shall identify transactions that were in progress at failure and require controlled completion, reversal, or review.
- `BCP-005` — IT shall support manual continuity documents for essential receiving, warehouse, dispatch, delivery, cash, and payroll work.
- `BCP-006` — IT shall support later entry and reconciliation of controlled manual transactions.
- `BCP-007` — IT shall retain an outage and recovery log.
- `BCP-008` — IT shall support business-date control during restart so overnight work remains in the correct fulfillment cycle.

### 32.3 Recovery objectives

For normal planning:

- Critical operational services should be restored within four hours.
- Recent transaction loss should be limited to fifteen minutes or less where practical.
- Manual procedures shall support essential operations when the recovery objective cannot be met.
- Financial and inventory reconciliation shall confirm completeness after recovery.

---

## 33. Information Quality Requirements

- `DQA-001` — Required business keys shall be unique and permanent.
- `DQA-002` — Required fields shall be validated before a transaction advances to the next responsible function.
- `DQA-003` — Units of measure shall be explicit; quantity shall never be interpreted without its unit.
- `DQA-004` — Dates shall distinguish order, requested delivery, scheduled delivery, actual delivery, invoice, due, receipt, posting, and accounting dates.
- `DQA-005` — Monetary values shall identify currency and shall follow controlled rounding rules.
- `DQA-006` — Status values shall follow defined transitions; invalid jumps shall require correction or override.
- `DQA-007` — Inactive master records shall remain available for historical interpretation.
- `DQA-008` — Duplicate-candidate checks shall exist for customers, suppliers, invoices, receipts, and payments.
- `DQA-009` — Reconciliations shall identify unexplained differences rather than forcing balances to agree.
- `DQA-010` — Reports shall identify their as-of time, business date, accounting period, and selection criteria.

---

## 34. Cross-Capability Business Events and Handoffs

| Business event | Originating capability | Required consumers and consequences |
|---|---|---|
| Customer approved | Customer/Credit | Sales and Order Management may transact |
| Price activated | Pricing | New order lines use the effective price |
| Order entered | Order Management | Pricing, Credit, Inventory, and Routing validate |
| Order released | Order Management | Inventory allocates; Warehouse receives work |
| Inventory shortage | Inventory/Warehouse | Customer Service, Purchasing, and Routing respond |
| Purchase order approved | Purchasing | Supplier commitment, expected receipt, cash forecast |
| Goods accepted | Receiving | Inventory increases; PO updates; AP gains match evidence |
| Goods held or rejected | Receiving/Quality | Inventory unavailable; Purchasing and AP notified |
| Pick completed | Warehouse | Inventory and order status update; staging begins |
| Load completed | Warehouse | Dispatch may assign departure; invoice documents finalize for print |
| Truck departed | Transportation | Route active; pending-delivery invoices remain unposted |
| Delivery accepted | Transportation | Sale and AR finalize; revenue and COGS post; inventory completes |
| Delivery exception | Transportation | Customer Service, Returns, Inventory, and Billing respond |
| Customer payment received | AR/Cash | AR reduces; cash increases; credit exposure updates |
| Supplier invoice matched | AP | Liability approved; payment scheduling and cash forecast update |
| Supplier payment released | AP/Cash | AP and cash reduce; remittance and GL update |
| Inventory adjustment approved | Inventory | Quantity, valuation, expense or recovery, and audit history update |
| Payroll approved | Payroll | Payment, liabilities, expense, cash forecast, and GL update |
| Asset placed in service | Fixed Assets | Depreciation schedule, custody, financing, and GL update |
| Period closed | General Ledger | Period reports become authoritative; ordinary posting stops |

### 34.1 Handoff requirements

- `INT-001` — Each handoff shall identify the originating transaction and current status.
- `INT-002` — A downstream rejection shall return a clear reason to the responsible upstream role.
- `INT-003` — Reprocessing shall not duplicate inventory, receivable, payable, cash, payroll, or general-ledger effects.
- `INT-004` — Related operational and accounting effects shall either complete together or be visibly held for controlled recovery.
- `INT-005` — Handoffs shall retain business date, actual timestamp, and responsible identity.

---

## 35. Formal Report Catalog

| Report | Frequency | Primary owner | Principal audience |
|---|---|---|---|
| Daily Operating Report | Daily | General Management | Owners and managers |
| Order Hold and Exception Report | Daily/on demand | Customer Service | Sales, Credit, Operations |
| Warehouse Completion Report | Each fulfillment cycle | Operations | Warehouse and Dispatch |
| Inventory Availability Report | On demand | Operations | Sales, Purchasing, Warehouse |
| Shortage and Backorder Report | Daily | Operations | Customer Service, Sales, Purchasing |
| Replenishment Worklist | Each warehouse cycle | Warehouse | Replenishment staff |
| Cycle Count and Variance Report | Scheduled | Warehouse | Operations and Accounting |
| Expiration and Short-Dated Report | Daily/weekly | Operations | Purchasing, Warehouse, Sales |
| Receiving Appointment Report | Daily | Receiving | Warehouse and Purchasing |
| Receiving Discrepancy Report | Daily | Receiving | Purchasing, AP, Quality |
| Food-Safety and Product-Hold Report | Daily/on demand | Operations | Food-safety leader, owners, Warehouse |
| Recall Exposure and Action Report | On demand | Operations | Food-safety leader and authorized management |
| Supplier Performance Scorecard | Monthly | Purchasing | Operations and owners |
| Purchase Commitment Report | Weekly | Purchasing | Operations and Finance |
| Route Manifest | Each route | Transportation | Dispatcher and driver |
| Delivery Performance Report | Daily/weekly | Transportation | Operations and owners |
| Fleet Maintenance Report | Weekly/monthly | Transportation | Operations and Finance |
| Sales and Gross Margin Report | Daily/weekly/monthly | Sales | Sales, Finance, owners |
| Customer Profitability Report | Monthly | Finance | Sales and owners |
| AR Aging | Weekly/monthly | Finance | Collections, Sales, owners |
| Collections Worklist | Daily | Finance | Collections |
| AP Aging and Payment Forecast | Weekly | Finance | AP and Cash Management |
| Early-Payment Discount Report | Each payment cycle | Finance | AP and Cash Management |
| Cash Position and Forecast | Daily/weekly | Finance | Owners |
| Payroll Register | Each payroll | Finance | Authorized payroll approvers |
| Labor and Overtime Report | Weekly/monthly | HR/Finance | Department managers |
| Trial Balance | Monthly/on demand | Accounting | Finance |
| Income Statement | Monthly | Accounting | Owners and management |
| Balance Sheet | Monthly | Accounting | Owners and management |
| Cash-Flow Report | Monthly | Accounting | Owners and management |
| Budget-to-Actual Report | Monthly | Finance | Owners and managers |
| KPI Scorecard | Weekly/monthly | General Management | Owners and managers |
| Audit and Override Report | Monthly/on demand | Finance/IT | Authorized owners |

---

## 36. Capability Acceptance Criteria

A business capability is not complete merely because information can be stored. It is accepted only when:

1. The responsible business owner can perform the normal process from start to finish.
2. Required upstream information is available without duplicate entry.
3. Required validations, approvals, and holds operate correctly.
4. Expected downstream operational and accounting consequences occur exactly once.
5. Exceptions are visible and can be resolved by an authorized role.
6. History explains what happened, when, and by whom.
7. Required reports reconcile to their underlying transactions.
8. Period and business-date rules work across midnight and weekends.
9. A restart or recovery does not duplicate or lose completed effects.
10. The capability works reproducibly under a controlled simulation seed.

---

## 37. Traceability to the Business Model

| Business-model area | Principal capability sections |
|---|---|
| Ownership and governance | 8, 29, 30 |
| Customer market and service territory | 9, 13, 19 |
| Product offering and units | 10, 12, 15 |
| Pricing and delivery economics | 12, 13, 20 |
| Ordering and fulfillment schedule | 13, 18, 31 |
| Credit, billing, and collections | 14, 20 |
| Inventory and FEFO | 15, 17, 18 |
| Purchasing and supplier relations | 11, 16, 17, 22 |
| Receiving and food safety | 17, 21, 28 |
| Transportation and delivery | 19, 20, 21 |
| Returns and customer service | 21 |
| Employees and payroll | 24 |
| Accounting and financial statements | 23, 25, 26 |
| Cash, financing, and capital | 23, 25 |
| Management objectives and KPIs | 27, 35 |
| Business continuity | 32 |

---

## 38. Boundaries for the Next Design Layer

This specification intentionally does not decide:

- Programming language features or class design
- Physical record layout
- Master-file or transaction-file byte format
- Index structure
- User-interface technology
- Interprocess or network protocol
- Hardware topology
- Report-rendering technology
- Backup product or storage medium

Those choices belong to later architecture and detailed design. They shall be evaluated against the capabilities and controls in this specification.

The next recommended deliverable is a **Information Model and Record Ownership Specification**. It should define the logical business records, permanent keys, relationships, lifecycle states, authoritative owners, retention needs, and transaction-to-accounting linkages before physical binary formats are designed.

---

## 39. Completion Status

This document completes the technology-neutral Business-to-IT capability layer for the approved business model as of September 3, 2026.

It provides the authoritative capability baseline for:

- Logical information modeling
- Process and transaction design
- Report design
- Control design
- Software architecture
- Implementation planning
- Test planning
