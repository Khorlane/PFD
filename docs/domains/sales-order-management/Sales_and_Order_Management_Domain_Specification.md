# \<business name>
# Sales and Order Management Domain Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Design baseline  
**Depends on:** Party/Customer, Product, Inventory, and Warehouse Operations designs

## 1. Purpose

Define how the business establishes prices, captures customer demand, validates and releases Sales Orders, handles shortages and substitutions, coordinates fulfillment, and resolves post-order service matters. This is business and logical-data design, not PostgreSQL implementation.

## 2. Scope

Sales and Order Management owns:

- Price lists, customer prices, contract prices, and authorized price exceptions
- Order channels, standing-order templates, Sales Orders, lines, revisions, and status
- Order minimum, cutoff, delivery-date, Customer, Product, unit, price, and tax validation
- Order holds and release coordination
- Customer decisions for shortages, substitutions, backorders, changes, and cancellations
- Commercial fulfillment status and customer communication
- Customer-service cases, return authorization, and requested billing resolution

It does not own Customer or Product masters, credit limits, Inventory balances/allocation logic, warehouse execution, routes/vehicles/delivery, invoices/AR/GL, or Quality disposition.

## 3. Business Context

The business primarily serves restaurants, hotels, schools, hospitals/healthcare facilities, and correctional institutions. Each Customer has an assigned sales representative. Sales owns the commercial relationship; Customer Service coordinates routine orders and service issues. Finance and Administration independently controls credit.

Opening service is hub-and-spoke from \<business address>, toward Statesville, Monroe, Rock Hill, and Gastonia and locations along practical direct corridors. Order acceptance remains subject to active service eligibility and delivery feasibility.

## 4. Governing Decisions

1. Every Sales Order has one permanent Sales Order Number.
2. Orders may be entered only for an eligible Customer Account and active delivery location, unless an approved exception exists.
3. Only authorized contacts, channels, Sales, or Customer Service may place orders.
4. Orders are normally taken Monday–Friday, 8 AM–4 PM. No routine orders are taken Saturday or Sunday.
5. The standard cutoff for next-scheduled-day delivery is 4 PM. Friday orders enter the Sunday-night fulfillment cycle for Monday delivery.
6. The normal minimum is $500 per delivery unless contract terms or an approved exception applies.
7. Price is resolved from effective contract, customer-specific, or standard price rules and preserved as order evidence.
8. Split packs are permitted where authorized but discouraged; the standard planning premium is 15% per unit over the equivalent full-case unit price.
9. The business does not use warehouse catch-weight pricing or post-pick price-at-weigh processing.
10. Sales cannot release its own Finance credit hold or bypass approved margin authority.
11. Inventory allocation uses the Inventory domain; informal salesperson reservations are prohibited.
12. A substitution never silently changes an order.
13. Customers may change/cancel before warehouse release. Later changes require Customer Service and Operations approval.
14. Final records are corrected through revisions, reversals, credits/debits, or linked replacement records—not overwritten.
15. Simulation uses the same Sales records as normal operation.

## 5. Responsibilities and Boundaries

| Area | Owner | Sales interaction |
|---|---|---|
| Customer/account/location/contact | Customer domain | Uses approved facts and standing requirements |
| Product/unit/substitution relationships | Product domain | Applies current sell eligibility and relationships |
| Price and Sales Order | Sales | Creates and controls commercial demand |
| Credit/exposure/hold | Finance | Requests decision; cannot self-approve |
| Availability/allocation/lot selection | Inventory | Requests and consumes controlled allocation results |
| Picking/staging/loading | Warehouse | Receives released demand and reports execution |
| Route/delivery/proof | Transportation | Confirms feasibility and delivery outcome |
| Safety disposition | Quality | Sales cannot override |
| Invoice/AR/revenue/tax posting | Finance | Supplies approved commercial and delivery evidence |

## 6. Order Channels and Authority

Approved channels may include assigned Sales Representative, Customer Service, approved electronic transmission, and another specifically authorized channel. Each order retains channel, originating contact/Principal, received time, source reference, and entry Principal.

Electronic or imported orders undergo the same validation as manually entered orders. Duplicate detection uses Customer, source reference, channel, and received facts. A duplicate is rejected or linked for review; it is not silently re-entered.

An unauthorized contact may submit an inquiry but cannot create a releasable order without confirmation by an authorized ordering contact.

## 7. Operating Calendar and Fulfillment Cycle

The order calendar distinguishes:

- Order received timestamp
- Business/order date
- Requested delivery date
- Scheduled delivery date
- Fulfillment cycle
- Cutoff result

Calendar midnight does not change the fulfillment cycle. Work after midnight retains the cycle associated with the intended delivery. Orders received after cutoff move to the next available scheduled delivery unless Operations approves an exception.

Emergency or off-schedule requests require capacity review and may carry an expedited-delivery charge. Contract commitments may override standard cutoff, minimum, and fee rules when explicitly recorded.

## 8. Standing and Recurring Orders

A Standing Order Template records Customer, delivery location, normal schedule, Products, units, expected quantities, confirmation requirements, effective period, and responsible contact.

A template is not itself a Sales Order and does not reserve Inventory, establish final price, or bypass credit. Each scheduled occurrence creates or proposes an ordinary Sales Order. The Customer or assigned Sales representative confirms quantities according to the agreement.

Skipped, changed, or expired occurrences remain traceable. A template revision applies prospectively and does not rewrite previously created orders.

## 9. Sales Order Identity and Types

Opening order types:

- Standard scheduled order
- Standing-order release
- Backorder fulfillment
- Emergency/off-schedule order
- Replacement order
- No-charge replacement when approved

One Sales Order may contain ambient, refrigerated, frozen, food, and nonfood lines when delivery and segregation rules permit. Orders are separated when different legal Customer Accounts, delivery locations, delivery dates, payment arrangements, or contractual controls require independent commitments.

## 10. Sales Order Lifecycle

| Status | Meaning |
|---|---|
| `ENTERED` | Demand captured but not fully validated |
| `VALIDATING` | Required controls are being evaluated |
| `HELD` | One or more blocking matters remain assigned |
| `READY` | All release conditions are satisfied |
| `RELEASED` | Controlled commitment transferred to fulfillment |
| `IN_FULFILLMENT` | Warehouse activity has begun |
| `LOADED` | Deliverable quantity is on an approved load |
| `DISPATCHED` | Transportation has departed |
| `DELIVERY_EXCEPTION` | Delivery outcome needs resolution |
| `DELIVERED` | Delivery outcome is confirmed |
| `CANCELLED` | Remaining demand was validly cancelled |
| `CLOSED` | Operational and required commercial resolution is complete |

Status changes are explicit, timestamped, and attributed. Downstream milestones are reflections of authoritative Warehouse or Transportation events, not independently asserted by Sales.

## 11. Order Header

The Order Header records:

- Sales Order Number, type, channel, business date, and received timestamp
- Customer Number and ordering contact
- Delivery location and billing arrangement
- Requested/scheduled delivery dates and fulfillment cycle
- Customer PO/reference and contract when applicable
- Payment-term and tax-treatment snapshot references
- Assigned Sales representative
- Route/service feasibility reference
- Order instructions and standing-requirement snapshot
- Status, totals, holds, release, and audit information

The Header does not store editable copies of Customer master data. It retains controlled snapshots or references needed to explain the transaction historically.

## 12. Order Lines

Each line records permanent line number, Product Number, requested sell unit/quantity, base-unit conversion evidence, requested substitution/backorder behavior, price components, tax classification, scheduled quantity, fulfilled quantity, cancelled quantity, and status.

Quantity components must reconcile to ordered quantity. A line cannot use an inactive Product/unit or violate Customer/Product restrictions without an approved exception. Free-text descriptions cannot substitute for a valid Product on a normal merchandise line.

Charge lines identify governed charge types such as small-order delivery, expedited delivery, or another authorized service charge; they are not disguised merchandise.

## 13. Pricing Model

The business maintains:

- Standard Price Lists
- Customer-specific Price Lists or agreements
- Contract/bid prices
- Quantity breaks
- Effective promotional or temporary prices when approved
- Authorized price exceptions

Price precedence is: applicable contract price, applicable Customer-specific price, then applicable standard price, subject to explicit agreement rules. When more than one candidate exists at the same precedence, the most specific valid rule wins; unresolved conflicts block pricing.

Selling price considers replacement/landed cost, handling/storage, shrink/spoilage, required margin, Customer volume/service cost, competition, contract commitments, and reliably measurable rebates/allowances.

## 14. Price Evidence and Authority

Each priced line retains price source, effective version, list/base price, quantity break, discount/premium, split-pack effect, override, final unit price, extension, expected cost/margin evidence, currency, rounding, and decision time.

Sales representatives may quote within approved lists and discount limits. The authorized Sales role holder may approve routine Customer-specific pricing within margin policy. Below-floor pricing requires Sales and Finance approval. Material long-term commitments below normal margin expectations require General Management approval.

A later price-list or cost change does not reprice a Released Order automatically. An authorized revision is required.

## 15. Split-Pack Pricing

Split-pack eligibility comes from Product and Customer requirements. The standard price is the equivalent full-case unit price plus a 15% per-unit handling premium, subject to governed rounding and Product-specific exception.

The premium is included in the per-unit selling price rather than stated as a separate invoice fee. The line retains full-case reference price and premium evidence. No actual warehouse weight can determine or alter the price.

## 16. Minimum Order and Delivery Charges

The $500 minimum is evaluated per planned delivery using eligible merchandise value under the applicable contract policy. Taxes, deposits, finance charges, and unrelated balances do not satisfy the merchandise minimum unless a contract explicitly states otherwise.

Below-minimum demand may be:

- Combined with the next scheduled order
- Accepted with an approved small-order delivery charge
- Approved as a Customer-service exception
- Declined or rescheduled

The decision, authority, charge, and Customer communication are retained. Emergency/off-schedule service separately evaluates expedited-delivery charges and capacity.

## 17. Tax and Billing Validation

Sales uses the active Customer tax status, exemption evidence, delivery jurisdiction, Product tax classification, and transaction date. Expired or unverified exemption evidence blocks exempt treatment.

The Order stores tax calculation evidence or an authoritative calculation reference. Finance owns final invoice tax and accounting. Customer-required PO numbers, billing references, invoice preferences, and bill-to arrangements are validated before release.

## 18. Credit and Payment Controls

Normal terms are Net 30. Approved governmental, school, healthcare, or contract accounts may receive Net 45. New or higher-risk Customers may be prepaid, COD, or restricted.

Finance evaluates exposure, limit, overdue invoices, returned payments, advance-payment requirements, and credit holds. A credit decision may approve, reject, require payment, or authorize a defined exception for a specific amount/order/effective period.

Sales may request review but cannot release a Finance hold. An active Customer on credit hold may place a prepaid order only when Finance policy permits and payment evidence is confirmed.

## 19. Availability and Allocation Boundary

Sales submits validated demand to Inventory. Inventory determines available-to-promise, eligible lots/locations, FEFO/FIFO, remaining shelf life, reservations, and allocations.

Allocation normally follows scheduled delivery and order release while considering safety/contract obligations, Customer priority/service commitments, approved substitutes, fair distribution, and route feasibility.

Held, quarantined, damaged, expired, recalled, or below-required-life stock is unavailable. Allocation is not physical movement. Cancellation/reduction releases unused allocation through Inventory controls.

## 20. Shortages, Substitutions, and Backorders

For an unavailable quantity, Sales/Customer Service may:

- Use a preapproved equivalent allowed by Customer policy
- Obtain explicit Customer approval for a material substitution
- Ship available quantity and backorder the remainder
- Move the remainder to the next scheduled delivery
- Cancel the unavailable quantity with Customer notice

Institutional specifications override general preferences. Brand, size, formula, allergen, dietary, pack, or specification differences require the appropriate Customer and, where applicable, Quality approval.

A Substitution Decision records original/substitute Product, unit/pack difference, quantity, price effect, availability, approval requirement, decision, contact/Principal, and time. A substitute becomes a distinct Order Line linked to the original; history is preserved.

A Backorder records originating Order/Line, outstanding quantity, promised or review date, status, Customer decision, and resulting fulfillment/cancellation. Backorders do not retain Inventory outside authorized allocation.

## 21. Holds and Exception Ownership

Order holds include incomplete Customer/location/contact data, invalid Product/unit, pricing/margin, minimum order, tax/billing, credit/payment, Inventory shortage, substitution approval, delivery feasibility, contract requirement, and operational restriction.

Each hold records type, scope, owner, reason, opened time, required resolution, status, evidence, decision, approver, and released/closed time. Only the owning authority may resolve the hold. All blocking holds must be released or validly rejected before Order release.

## 22. Changes, Revisions, and Cancellation

Before warehouse release, authorized users may revise an Order with preserved change history and full revalidation. After release, Customer Service and Operations must approve changes affecting Product, quantity, delivery, staging, or loading. Pricing, credit, tax, and route controls are rerun as applicable.

Special-order products and unavoidable committed costs may create an approved cancellation charge. Cancellation identifies Customer request, reason, effective quantity, allocation release, Warehouse impact, supplier/committed-cost impact, approval, and communication.

Dispatched demand is not cancelled as though unfulfilled; the delivery/return/credit process applies.

## 23. Release to Fulfillment

An Order may become `RELEASED` only when:

- Customer, ordering authority, delivery location, and standing requirements are valid
- Product, sell unit, quantity, and Customer/Product restrictions are valid
- Prices, margins, minimums, taxes, terms, and required references are established
- Credit/payment requirements are satisfied
- Scheduled delivery and route/service feasibility are approved
- Inventory is allocated or an accepted shortage resolution exists
- Required substitution, contract, and exception approvals are recorded

Release creates an immutable release snapshot and transfers controlled demand to Warehouse. It does not authorize undocumented additions to a truck.

## 24. Fulfillment Coordination

Sales Order quantities reconcile across ordered, allocated, picked, short, staged, loaded, delivered, refused, backordered, cancelled, and otherwise resolved states. Warehouse and Transportation own the execution facts; Sales consumes them.

Warehouse exceptions that change the Customer commitment return to Customer Service for resolution. Customer Service records communication and decision before revised fulfillment proceeds when approval is required.

No Order is Closed while unexplained quantity, active allocation, unresolved Backorder, active hold, delivery exception, or required billing instruction remains.

## 25. Predeparture Invoice Boundary

After load reconciliation, Sales supplies the approved Customer, billing, Order, loaded-quantity, price, tax, term, and reference evidence needed by Finance/Billing.

Finance prepares a permanent-numbered invoice before truck departure. It accompanies delivery paperwork and remains `PENDING_DELIVERY`. Accepted delivery permits finalization and posting. Shortage, refusal, damage, return, or other post-departure difference uses a linked credit memo, debit memo, supplemental invoice, or permitted pre-posting adjustment.

Sales and drivers cannot alter a finalized invoice or promise an unauthorized credit.

## 26. Customer Service Cases and Returns

A Customer Service Case may cover shortage, substitution, late/missed delivery, wrong Product, damage, temperature concern, pricing/billing question, complaint, return, or credit request. It records Customer, contact, Order/Delivery/Invoice references, owner, severity, promise/target time, facts, communication, resolution, and status.

Returns require authorization except an immediate driver-recorded refusal. A Return Authorization records original Order/Delivery/Invoice line, Product/lot where known, requested quantity, reason, pickup/disposition instructions, approval, and status.

Returned stock enters unavailable Inventory pending Warehouse/Quality inspection. Customer Service may recommend a billing outcome; Finance approves and issues financial documents. Material or unusual credits require management approval.

## 27. Logical Structures

| Structure | Natural primary key |
|---|---|
| Price List | `price_list_code` |
| Price List Version | `price_list_code + effective_from` |
| Price List Item | `price_list_code + effective_from + product_number + sell_unit_code + quantity_break` |
| Customer Price Agreement | `customer_number + agreement_code` |
| Agreement Price | `customer_number + agreement_code + product_number + sell_unit_code + effective_from` |
| Standing Order Template | `standing_order_template_number` |
| Template Line | template number + line number |
| Sales Order | `sales_order_number` |
| Sales Order Line | sales order number + line number |
| Order Revision | sales order number + revision number |
| Order Status History | sales order number + status time + status code |
| Order Hold | sales order number + hold sequence |
| Order Price Evidence | sales order number + line number + price decision sequence |
| Substitution Decision | sales order number + line number + decision sequence |
| Backorder | originating sales order number + line number + backorder sequence |
| Release Snapshot | sales order number + release sequence |
| Customer Service Case | `customer_service_case_number` |
| Case Activity | case number + activity sequence |
| Return Authorization | `return_authorization_number` |

Line and sequence values are governed within their parent transaction. No table receives a surrogate key.

## 28. Integrity Rules

- Effective price/contract rows for the same governed scope cannot overlap ambiguously.
- Order quantities, statuses, and monetary extensions reconcile.
- A released snapshot is immutable.
- A blocking hold prevents release.
- Price or quantity changes trigger applicable revalidation.
- Allocated, picked, loaded, delivered, returned, cancelled, and backordered quantities cannot exceed ordered/revised quantity.
- Substitute lines preserve the original demand and approval chain.
- Cancellation cannot erase fulfilled or dispatched facts.
- Return authorization cannot exceed eligible delivered quantity net of prior returns.
- Final-state correction uses linked forward records.

## 29. Reports and Measures

- Orders by status, delivery date, Customer, segment, Sales representative, and channel
- Held orders by reason, owner, value, and age
- Orders approaching/missing cutoff or release deadline
- Sales and margin by Product, Customer, segment, Order, route, and Sales representative
- Price exceptions and below-floor approvals
- Below-minimum and expedited orders/charges
- Split-pack sales and premium realization
- Fill rate, shorts, substitutions, Backorders, and cancellations
- Order revisions after release
- Customer-service cases, response time, resolution, returns, and requested credits
- Contract utilization and expiring price agreements
- Order-to-Inventory, fulfillment, delivery, and billing reconciliation

## 30. Security and Audit

Sales may maintain authorized prices and Orders within delegated limits. Customer Service may coordinate routine orders, changes, cases, and returns. Finance controls credit, below-margin concurrence, invoice/credit issuance, tax exceptions, and accounting. Operations controls post-release fulfillment changes. Quality controls safety decisions.

Released Orders, decisions, status history, price evidence, communications, and audit events are append-only. Sensitive credit, tax, and payment data remains in Finance. `PUBLIC` receives no domain access.

## 31. Simulation

Simulation creates and updates ordinary Price, Order, Hold, Allocation reference, Backorder, Case, and Return Authorization records using normal controls. It does not create parallel Sales masters or add simulation identifiers to business keys.

A simulated day/week may be reset externally for another scenario, but while a run exists the operational and accounting tables behave as the real business would. Sales history, margin comparison, AR, and related reporting derive from actual domain tables.

## 32. Remaining Configuration

Opening price lists, margin floors, discount limits, Customer-specific agreements, small-order and expedited charges, approval thresholds, order-channel details, standing templates, reason codes, and service targets are configuration—not unresolved architecture.

## 33. Next Step

Next design deliverable: **Sales and Order Management PostgreSQL Build Specification**. It will define normalized structures, natural keys, constraints, functions, privileges, verification, and tests without executable SQL.
