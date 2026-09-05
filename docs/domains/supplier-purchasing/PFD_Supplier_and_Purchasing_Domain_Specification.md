# \<business name>
# Supplier and Purchasing Domain Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Design baseline  
**Depends on:** PFD Core, Party, Customer, and Product designs

## 1. Purpose

Define how PFD qualifies suppliers, establishes product sources, plans replenishment, issues purchase orders, schedules inbound deliveries, resolves discrepancies, and measures supplier performance. This is business and logical-data design; it contains no PostgreSQL implementation.

## 2. Scope

This domain owns:

- Supplier accounts, locations, contacts, status, and classifications
- Supplier approval and compliance
- Supplier-product sourcing arrangements
- Purchasing terms, lead times, order minimums, and allowances
- Replenishment recommendations and buyer decisions
- Requests for quotation when used
- Purchase orders, revisions, acknowledgments, and cancellations
- Inbound delivery appointments
- Supplier substitutions and backorders
- Purchasing-side discrepancy and return-to-supplier cases
- Supplier performance history

It does not own Product Master, physical inventory receipt, Accounts Payable invoices or payments, General Ledger postings, warehouse capacity, or truck dispatch.

## 3. Governing Decisions

1. `supplier_number` is the permanent Supplier Master primary key.
2. A Supplier is an Organization Party; multiple supplier accounts may reference one legal organization when commercial arrangements require separation.
3. `purchase_order_number` is the permanent Purchase Order primary key.
4. No surrogate keys are used.
5. Purchases require an approved Supplier and an effective approved source for the Product, except a documented emergency exception.
6. Purchase Orders are formal commitments and retain every revision.
7. Supplier acknowledgments do not silently replace PFD's order; differences require acceptance or rejection.
8. Inbound deliveries require appointments. Suppliers and carriers cannot arrive whenever they choose.
9. Receiving records actual quantity, lot, dates, condition, and discrepancies; Purchasing does not invent receipt results.
10. PFD protects supplier relationships: disputed items are resolved promptly, and an undisputed payable portion is not withheld solely because another portion is disputed.
11. Supplier credits, replacements, returns, and agreed price adjustments are documented against the originating transaction.
12. PFD plans cash to pay obligations timely and capture economically sound early-payment discounts; Purchasing records terms while Finance controls payment.
13. Variable-weight warehouse pricing is unsupported. Purchase commitments use agreed fixed units and quantities.
14. Simulation uses the same Supplier and Purchase Order records as normal operation.

## 4. Supplier Identity

PFD assigns a six-digit Supplier Number, initially `000001`. It is controlled, permanent, visible in operations and accounting, never generated with `MAX + 1`, and never reused.

Supplier Master records:

- Supplier number
- Organization Party number
- Operational supplier name
- Supplier classification
- Status and status reason
- Onboarding date
- Default currency
- Default purchasing and payment terms
- Responsible buyer
- Ordering method
- Tax-reporting classification where required
- Audit and effective history

Names and external supplier identifiers are not keys.

## 5. Supplier Classifications and Status

Opening classifications:

- Food manufacturer
- Food processor or packer
- Produce grower or shipper
- Broadline or specialty distributor
- Paper-products supplier
- Cleaning and sanitation supplier
- Other food-service supply source

Statuses:

| Status | Meaning |
|---|---|
| `PENDING_APPROVAL` | Qualification incomplete; no routine purchases |
| `APPROVED` | Eligible for authorized purchasing |
| `CONDITIONAL` | Approved only for stated Products, dates, or conditions |
| `PURCHASE_HOLD` | New Purchase Orders blocked temporarily |
| `QUALITY_HOLD` | Product sourcing blocked by Quality |
| `SUSPENDED` | All new commitments blocked |
| `INACTIVE` | Relationship closed; history retained |

Quality may impose a Quality Hold. Purchasing cannot release it without Quality approval.

## 6. Supplier Locations and Contacts

Supplier locations reuse Party Address structures and identify purposes such as ordering office, shipping origin, remittance office, claims office, and corporate office.

Contact responsibilities include:

- Sales representative
- Order desk
- Order acknowledgment
- Shipping and appointment scheduling
- Quality and recall
- Claims and returns
- Accounts receivable/remittance
- Management escalation

Every approved Supplier requires ordering, appointment, Quality/recall, and remittance contacts appropriate to its business.

## 7. Supplier Qualification

Approval considers:

- Product capability and capacity
- Food-safety and regulatory documentation
- Insurance and contractual requirements
- Recall and traceability capability
- Delivery reliability
- Financial and operational stability
- Pricing and terms
- Service responsiveness
- Geographic shipping origin
- Conflict-of-interest disclosure

Required documents are stored in approved document storage with type, version, issue/expiration dates, verification status, reference, checksum, and responsible reviewer.

Expiring required documents generate review work. Expiration may place the Supplier or affected Product sources on hold according to policy.

## 8. Supplier-Product Source

An approved source connects one Supplier, Supplier ship-from location, and PFD Product for an effective period.

It records:

- Supplier item number and description
- Manufacturer Party and item number when different
- Purchase unit and exact relationship to the PFD Product base unit
- Minimum order quantity and increment
- Case and pallet configuration
- Standard lead time and variability allowance
- Order cutoff
- Normal delivery days
- Minimum remaining shelf life at receipt
- Lot/date documentation requirements
- Substitution policy
- Source priority
- Approval status and effective dates

One Product may have multiple approved sources. A physical difference affecting brand, formula, pack, traceability, allergen, or customer acceptance requires a distinct Product or explicit approved substitution.

## 9. Supplier Pricing and Terms

Supplier-product commercial terms are effective-dated and may include:

- Base unit cost
- Currency
- Effective and expiration dates
- Quantity breaks
- Freight terms
- Fuel, delivery, or other allowed surcharges
- Promotional allowance
- Rebate arrangement
- Early-payment discount
- Return or restocking terms

The Purchase Order captures the agreed cost and terms. Later source changes do not rewrite an issued Purchase Order, receipt, supplier invoice, or accounting history.

Rebates dependent on future volume are tracked as agreements and earned events, not silently netted into every unit cost.

## 10. Replenishment Planning

Inventory provides projected availability, demand, safety stock, open allocations, and open inbound quantities. Purchasing converts recommendations into buyer decisions.

A recommendation includes:

- Product and stocking location
- Recommended Supplier/source
- Recommended quantity and purchase unit
- Need-by date
- Expected receipt date
- Demand and safety-stock basis
- Existing on-hand and inbound supply
- Minimum-order or pallet-rounding effect
- Shelf-life and capacity warnings

The buyer may accept, adjust, defer, combine, or reject a recommendation with a reason. Recommendations never become Purchase Orders without authorization.

## 11. Requests for Quotation

RFQs are optional for routine buying but supported for new Products, material price changes, large commitments, and source comparisons.

An RFQ identifies Products, quantities, required dates, invited Suppliers, response deadline, requirements, and buyer. Supplier responses preserve price, terms, availability, lead time, substitutions, exceptions, and expiration.

Award decisions record the selected response and reason. Lowest price is not automatically best when quality, service, shelf life, or risk differs.

## 12. Purchase Order

A Purchase Order contains:

- Purchase Order Number
- Supplier and ship-from location
- PFD receiving destination
- Order date
- Buyer
- Currency and payment terms
- Freight terms
- Requested delivery date/window
- Status
- Current revision number
- Supplier acknowledgment status
- Header instructions and approvals

Each line contains:

- Line number
- Product
- Approved source
- Ordered quantity and purchase unit
- Base-unit equivalent
- Agreed unit cost
- Allowances or surcharges
- Extended amount
- Requested delivery date
- Lot/date and quality requirements
- Substitution permission
- Line status

Line number is meaningful within the Purchase Order. It is never recycled after cancellation.

## 13. Purchase Order Lifecycle

Statuses:

`DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `SENT`, `ACKNOWLEDGED`, `PARTIALLY_RECEIVED`, `RECEIVED`, `CLOSED`, `CANCELLED`.

Rules:

- Drafts are not commitments.
- Approval validates authority, Supplier/source status, units, cost, dates, and expected amount.
- Sending freezes the issued revision.
- Commercial changes create a new revision; prior revisions remain immutable.
- Quantity reductions cannot fall below receipts already accepted.
- Cancellation requires reason and Supplier notification when already sent.
- Closure requires receipt, cancellation, or approved disposition of every line.

## 14. Acknowledgment and Change Control

Supplier acknowledgment records accepted quantity, price, ship date, delivery date, backorder, substitution, and exceptions by line.

Differences generate an acknowledgment exception. The buyer may:

- Accept and revise the Purchase Order
- Reject and request correction
- Split delivery
- Approve a substitute through Product/Sales/Quality rules
- Cancel affected quantity
- Escalate for approval

No acknowledgment changes the PFD commitment without an approved Purchase Order revision.

## 15. Inbound Appointments

Every planned inbound delivery has an appointment or an explicit approved exception.

The appointment records:

- Appointment number
- Supplier, carrier, and Purchase Order(s)
- PFD receiving location and dock when assigned
- Scheduled arrival window
- Expected pallets/cases and temperature classes
- Contact and confirmation status
- Reschedule/cancellation history
- Special unloading or security instructions

Overlapping dock capacity and receiving labor constraints are checked by Warehouse. A late, early, or unscheduled arrival is recorded and may be accepted, rescheduled, or refused by Operations.

## 16. Receiving Boundary

Warehouse owns the Receipt and actual receiving events. The Receipt references Purchase Order and appointment and reports:

- Actual Products, units, and quantities
- Supplier and manufacturer lots
- Expiration, best-by, use-by, or pack dates
- Temperature and condition
- Overages, shortages, damage, wrong Product, and documentation failures
- Accepted, quarantined, rejected, or pending quantities

Purchasing receives those facts and resolves commercial consequences. It does not overwrite warehouse observations.

## 17. Discrepancies, Claims, and Returns

A discrepancy case links the Purchase Order, line, Receipt, Supplier, issue type, quantity, expected and actual value, evidence, owner, status, and resolution.

Issue types include:

- Shortage or overage
- Damage
- Wrong Product or unit
- Price or terms variance
- Quality or temperature failure
- Insufficient remaining shelf life
- Missing/incorrect lot or documents
- Unapproved substitution

Possible resolutions:

- Accept as received
- Supplier credit
- Replacement shipment
- Return to Supplier
- Price adjustment
- Quantity correction
- Shared-cost settlement
- Rejection with no liability

PFD seeks a mutually acceptable resolution and preserves good supplier relations. Finance pays an undisputed payable portion on schedule while the disputed portion follows the case; the system must support partial dispute rather than placing the entire invoice on hold.

## 18. Return to Supplier

A Supplier Return requires authorization, originating receipt/lot, Product, quantity, unit, reason, disposition, expected credit or replacement, shipping responsibility, and status.

Physical movement is owned by Warehouse/Transportation. Purchasing owns Supplier authorization and commercial settlement. Inventory and Finance receive the resulting events; no domain independently adjusts quantity or money without the linked transaction.

## 19. Accounts Payable Boundary

Purchasing supplies AP with Purchase Order commitments, revisions, receipts, discrepancies, returns, and expected terms. Finance owns Supplier Invoice, three-way match, payable, payment, discount capture, and General Ledger entry.

Matching compares:

- Purchase Order quantity and price
- Accepted receipt quantity
- Supplier invoice quantity, price, tax, freight, and allowances

Tolerance exceptions require documented authority. Disputed and undisputed amounts remain separately identifiable.

## 20. Supplier Performance

Performance is calculated from immutable operating facts, not manually overwritten scores:

- On-time acknowledgment
- On-time delivery
- Fill rate
- Quantity accuracy
- Price accuracy
- Damage and rejection rate
- Shelf-life compliance
- Lot/document compliance
- Quality incidents and recalls
- Claim response and resolution time

Scorecards support sourcing decisions but do not automatically suspend a Supplier. Status decisions require review and approval.

## 21. Logical Structures

| Structure | Natural primary key |
|---|---|
| Supplier | `supplier_number` |
| Supplier Name | `supplier_number + effective_from` |
| Supplier Status History | `supplier_number + effective_from` |
| Supplier Classification | `supplier_number + classification_code + effective_from` |
| Supplier Location | `supplier_number + supplier_location_code` |
| Supplier Contact Assignment | `supplier_number + contact_role_code + person_party_number + effective_from` |
| Supplier Requirement/Document | `supplier_number + requirement_type + document_number` |
| Supplier Product Source | `supplier_number + supplier_location_code + product_number + effective_from` |
| Supplier Product Terms | `supplier_number + supplier_location_code + product_number + terms_effective_from` |
| Supplier Quantity Break | source key plus `minimum_quantity + effective_from` |
| Replenishment Recommendation | `recommendation_number` |
| RFQ | `request_for_quote_number` |
| RFQ Line | `request_for_quote_number + line_number` |
| RFQ Supplier Response | RFQ, Supplier, response revision, and line |
| Purchase Order | `purchase_order_number` |
| Purchase Order Revision | `purchase_order_number + revision_number` |
| Purchase Order Line | `purchase_order_number + revision_number + line_number` |
| Supplier Acknowledgment | `purchase_order_number + acknowledgment_number` |
| Acknowledgment Line | acknowledgment key plus PO line number |
| Inbound Appointment | `appointment_number` |
| Appointment Purchase Order | `appointment_number + purchase_order_number` |
| Purchasing Discrepancy | `discrepancy_number` |
| Supplier Return | `supplier_return_number` |
| Supplier Performance Period | `supplier_number + performance_period_start` |

Controlled business numbers are permanent operational identifiers, not technical surrogate keys.

## 22. Integrity and History

- Effective facts cannot overlap.
- Supplier Products reference active Product and Supplier records.
- Units and conversions must match Product policy.
- Purchase Order totals equal line, allowance, freight, and tax components.
- Issued Purchase Order revisions are immutable.
- Acknowledgment quantities cannot exceed the Supplier's stated availability without a new response.
- Receipt and discrepancy facts are referenced, not copied and altered.
- Returns cannot exceed eligible received quantity net of prior returns.
- Supplier status, source approval, terms, and documents are evaluated as of commitment time.
- Material changes record responsible Principal, effective time, reason, and approval.

## 23. Responsibilities

| Decision | Responsibility |
|---|---|
| Supplier onboarding/status | Operations/Purchasing; Quality for food-safety approval |
| Source and terms approval | Purchasing within authority |
| Purchase recommendation decision | Buyer |
| Purchase Order approval | Purchasing/General Management by amount |
| Quality Hold/release | Quality |
| Appointment acceptance | Warehouse/Operations |
| Receipt observation | Warehouse/Quality |
| Commercial discrepancy resolution | Purchasing; Finance for monetary settlement |
| Supplier payment | Finance/Admin |

No person approves their own transaction above delegated authority.

## 24. Business-to-IT Support

| Capability | Support |
|---|---|
| Maintain reliable supply | Approved sources, lead times, replenishment decisions |
| Control commitments | Purchase Orders, revisions, authority, acknowledgments |
| Run orderly receiving | Scheduled appointments and capacity checks |
| Protect quality | Supplier/source qualification, date/lot requirements, Quality Holds |
| Control cost | Effective terms, quotes, quantity breaks, variance handling |
| Preserve supplier relations | Clear claims, response tracking, partial dispute handling |
| Pay accurately and timely | PO/receipt evidence, terms, discount data, undisputed amounts |
| Improve suppliers | Fact-based scorecards and trend history |

## 25. Reports

- Approved, conditional, held, and inactive Suppliers
- Required documents approaching expiration
- Products with no approved source or only one source
- Cost/terms changes and expiring agreements
- Replenishment recommendations awaiting decision
- Purchase Orders awaiting approval, acknowledgment, delivery, or closure
- Late/backordered Purchase Order lines
- Inbound appointment schedule and exceptions
- Open discrepancies, claims, returns, credits, and replacements
- Undisputed versus disputed payable support
- Supplier performance scorecards

## 26. Security and Audit

- Purchasing maintains Suppliers, sources, terms, and Purchase Orders within authority.
- Quality controls safety approval and Quality Holds.
- Warehouse records appointments and receipts within its domain; it cannot revise commercial terms.
- Finance reads purchasing evidence and owns invoices/payments.
- Issued commitments, acknowledgments, discrepancy events, and audit records are append-only or revision-controlled.
- Sensitive banking and tax-payment data remains in Finance, not Purchasing.
- `PUBLIC` receives no domain access.

## 27. Simulation

Simulation uses ordinary Supplier, sourcing, Purchase Order, appointment, and discrepancy records. Simulated demand may generate recommendations and authorized Purchase Orders, but no parallel Supplier or purchasing tables are created. Period comparison uses operational timestamps and accounting records.

## 28. Remaining Configuration

These items do not block design:

- Opening Supplier catalog and numbers
- Initial source approvals, prices, terms, lead times, and minimums
- Purchase Order approval thresholds
- Match tolerances
- Receiving dock capacity and appointment duration
- Supplier-document requirements by classification
- Performance targets and scorecard weights

## 29. Next Step

The next design deliverable is the **PFD Supplier and Purchasing PostgreSQL Build Specification**. It will define the normalized database structures, natural keys, constraints, indexes, controlled functions, privileges, verification, and tests without producing executable SQL.
