# \<business name>
# Sales and Order Management PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0069`–`0082`  
**Depends on:** Cumulative design through `0068`; Sales and Order Management Domain Specification

## 1. Purpose

Define PostgreSQL structures and controls for Sales pricing, order capture, standing orders, validation, revisions, holds, shortages, substitutions, backorders, release, fulfillment status, customer-service cases, return authorization, reporting, and audit. This remains design only.

## 2. Required Outcome

- Every Sales Order has one permanent business number and governed line numbers.
- Effective standard, Customer, and contract prices resolve deterministically.
- Order price, quantity, tax, terms, Customer instructions, and approval evidence remain reproducible.
- The 4 PM cutoff, $500 normal delivery minimum, and 15% standard split-pack premium are controlled rules.
- Credit decisions remain under Finance authority.
- Inventory reservations and allocations remain under Inventory authority.
- Released demand is immutable; later changes create approved revisions or forward corrections.
- Substitutions, backorders, cancellations, and returns preserve the original demand chain.
- No warehouse catch-weight or price-at-weigh fields exist.
- No surrogate, identity, serial, UUID, or hidden substitute keys are used.
- Simulation uses ordinary Sales tables.

## 3. Platform and Package

PostgreSQL 15 or later; existing `core`, `party`, `customer`, `product`, `inventory`, `warehouse`, `quality`, `sales`, `transportation`, `finance`, `audit`, and `reporting` schemas; cumulative manifest `7.0.0`; immutable changes `0001`–`0068`; transactional changes `0069`–`0082` through the standard runner.

Where Finance or Transportation structures are not yet physically present, the package records governed business references and documented deferred constraints. The owning-domain package must validate and activate those constraints.

## 4. Standards

Use lowercase `snake_case`, uppercase governed codes, `numeric(19,6)` quantities, `numeric(19,4)` monetary values, `char(3)` ISO currency codes, `date` for business/delivery dates, and `timestamptz` for events/effective periods. Mutable rows use standard Principal/timestamp audit columns and positive `row_version`. Monetary calculations use explicit rounding rules.

Natural business numbers/codes or governed composites are primary keys. Foreign keys carry complete natural keys. Nullable references are not forced into keys with fake values. Released revisions, decisions, status history, communications, and audit events are append-only.

## 5. Controlled Numbers

Change `0069` adds:

| Sequence | Example |
|---|---|
| `SALES_ORDER` | `SO0000000001` |
| `STANDING_ORDER_TEMPLATE` | `SOT00000001` |
| `CUSTOMER_SERVICE_CASE` | `CSC00000001` |
| `RETURN_AUTHORIZATION` | `RMA00000001` |
| `SALES_AUDIT_EVENT` | `SAE0000000001` |

Numbers use the Core allocation service, are permanent, and are never reused. Order lines, revisions, hold sequences, price decisions, substitution decisions, backorders, release snapshots, case activities, and return lines use governed sequence numbers within their parent business transaction.

## 6. Reference Data

| Reference | Opening codes |
|---|---|
| Order type | `STANDARD`, `STANDING_RELEASE`, `BACKORDER_FULFILLMENT`, `EMERGENCY`, `REPLACEMENT`, `NO_CHARGE_REPLACEMENT` |
| Order channel | `SALES_REP`, `CUSTOMER_SERVICE`, `ELECTRONIC`, `OTHER_AUTHORIZED` |
| Order status | `ENTERED`, `VALIDATING`, `HELD`, `READY`, `RELEASED`, `IN_FULFILLMENT`, `LOADED`, `DISPATCHED`, `DELIVERY_EXCEPTION`, `DELIVERED`, `CANCELLED`, `CLOSED` |
| Line status | `REQUESTED`, `PRICED`, `HELD`, `ALLOCATED`, `RELEASED`, `PARTIALLY_FULFILLED`, `FULFILLED`, `BACKORDERED`, `SUBSTITUTED`, `CANCELLED`, `CLOSED` |
| Hold type | `CUSTOMER_DATA`, `PRODUCT_UNIT`, `PRICE_MARGIN`, `MINIMUM_ORDER`, `TAX_BILLING`, `CREDIT_PAYMENT`, `INVENTORY_SHORTAGE`, `SUBSTITUTION_APPROVAL`, `DELIVERY_FEASIBILITY`, `CONTRACT_REQUIREMENT`, `OPERATIONAL` |
| Price source | `CONTRACT`, `CUSTOMER`, `STANDARD`, `PROMOTIONAL`, `AUTHORIZED_OVERRIDE` |
| Charge type | `SMALL_ORDER_DELIVERY`, `EXPEDITED_DELIVERY`, `CANCELLATION`, `OTHER_SERVICE` |
| Shortage decision | `APPROVED_SUBSTITUTE`, `PARTIAL_AND_BACKORDER`, `NEXT_DELIVERY`, `CANCEL_QUANTITY` |
| Case type | `SHORTAGE`, `SUBSTITUTION`, `LATE_OR_MISSED_DELIVERY`, `WRONG_PRODUCT`, `DAMAGE`, `TEMPERATURE`, `PRICING_BILLING`, `COMPLAINT`, `RETURN`, `CREDIT_REQUEST` |
| Return status | `REQUESTED`, `AUTHORIZED`, `DECLINED`, `PICKUP_PLANNED`, `RECEIVED`, `INSPECTION_PENDING`, `RESOLVED`, `CANCELLED` |

Reference tables follow the Core active/effective/audit pattern.

## 7. Price Lists and Versions

`sales.price_list` uses `price_list_code` as PK and stores name, price-list class, currency, precedence class, applicability, active status, and audit columns.

`sales.price_list_version` PK `price_list_code + effective_from`; stores effective-to, approval status, rounding rule, responsible Principal, approved time, and notes. Effective periods for the same list cannot overlap.

`sales.price_list_item` PK:

`price_list_code + effective_from + product_number + sell_unit_code + quantity_break`

It stores fixed unit price or governed pricing basis, minimum quantity, split-pack handling rule, margin classification, and audit data. Product/unit and quantity conversion must be valid for the effective period.

## 8. Customer and Contract Pricing

`sales.customer_price_agreement` PK `customer_number + agreement_code`; stores agreement type, contract/bid reference, currency, priority, effective period, minimum/fee exceptions, approval status, responsible Sales Principal, and audit data.

`sales.customer_agreement_price` PK:

`customer_number + agreement_code + product_number + sell_unit_code + effective_from`

It stores effective-to, unit price or price basis, quantity conditions, split-pack rule, margin evidence requirement, and approval. Overlapping rows for the same governed scope are rejected.

An agreement may apply to governed child accounts or delivery locations only through explicit effective-dated scope rows. Parent relationships do not silently extend prices.

## 9. Price Authority and Margin Policy

`sales.price_authority` PK `principal_or_role_code + authority_code + effective_from`; stores allowed price-list classes, discount range, margin floor, amount/duration limit, required concurrence, and effective period.

`sales.margin_policy` PK `margin_policy_code + effective_from`; stores calculation basis, floor/target, scope, and approval requirements. Cost evidence is referenced from authoritative Product/Inventory/Finance sources; Sales does not alter it.

Below-floor approval requires separate Sales and Finance decisions. Material long-term exceptions additionally require General Management. Self-approval is rejected where concurrence is required.

## 10. Standing Order Templates

`sales.standing_order_template` uses `standing_order_template_number` as PK and stores Customer/location, schedule rule, ordering contact, confirmation requirement, effective period, status, and audit columns.

`sales.standing_order_template_line` PK template number + line number; stores Product, sell unit, expected quantity, allowed variance, substitution/backorder preference, and instructions.

`sales.standing_order_occurrence` PK template number + scheduled delivery date; records due/confirmed/skipped/created outcome and resulting Sales Order Number.

Template generation creates an ordinary Sales Order through controlled functions. It never creates price, credit, allocation, or delivery exceptions automatically.

## 11. Sales Order Header

`sales.sales_order` uses `sales_order_number` as PK and stores order type/channel, received timestamp, business date, Customer Number, ordering contact, delivery location, billing arrangement, requested/scheduled delivery dates, fulfillment cycle, Customer PO/reference, agreement reference, terms/tax snapshot references, assigned Sales Principal, route-feasibility reference, status, current revision, totals, and row version.

Customer, contact, location, Product, and agreement foreign keys use their full natural keys. Imported source identity is protected by a unique channel + Customer + source-reference rule where the channel supplies a stable reference.

## 12. Sales Order Lines and Charges

`sales.sales_order_line` PK `sales_order_number + line_number`; stores Product, sell unit, requested quantity, base conversion evidence, substitution/backorder preference, current scheduled/fulfilled/cancelled quantities, tax classification reference, status, and row version.

`sales.sales_order_charge` PK `sales_order_number + charge_line_number`; stores governed charge type, basis, amount, currency, reason, authority, and tax classification. Charge lines remain separate from merchandise lines.

Header merchandise, charge, discount, tax-estimate, and total amounts are derived/reconciled from current approved line facts. Quantities are positive and valid for unit increments.

## 13. Order Revisions and Status History

`sales.sales_order_revision` PK `sales_order_number + revision_number`; stores reason, requested/approved Principals, created/approved times, pre/post-release indicator, status, and predecessor revision.

`sales.sales_order_revision_header` PK order + revision; captures immutable header facts. `sales.sales_order_revision_line` PK order + revision + line number; captures immutable merchandise and price facts. `sales.sales_order_revision_charge` uses order + revision + charge line.

`sales.sales_order_status_history` PK `sales_order_number + status_time + order_status_code`; records prior/new status, source domain/event, Principal, reason, and correlation. Released revisions and history reject update/delete.

## 14. Order Calendar and Fulfillment Cycle

`sales.order_calendar_rule` PK `calendar_code + effective_from`; stores business days, office hours, cutoff, next-delivery rule, holiday/calendar reference, and approval.

Opening rule supports Monday–Friday 8 AM–4 PM intake, 4 PM next-scheduled-day cutoff, no routine weekend intake, and Friday orders entering Sunday-night fulfillment for Monday delivery.

`sales.fulfillment_cycle` PK `warehouse_code + delivery_date + cycle_code`; stores order cutoff, release deadline, warehouse start, planned dispatch, status, and approved exception. Midnight-crossing work retains this key.

`sales.order_schedule_decision` PK order + decision sequence; records requested/scheduled date, cutoff result, service schedule, exception, authority, and reason.

## 15. Pricing Decisions and Evidence

`sales.order_price_decision` PK `sales_order_number + line_number + price_decision_sequence`; stores candidate/source precedence, source key/version, list/base price, quantity break, discount, premium, split-pack effect, override, final unit price, extension, currency, rounding, expected cost/margin evidence, authority, and decision time.

Exactly one approved decision is current per active line revision. Resolution order is contract, Customer-specific, then standard, subject to governed specificity. Ambiguous same-precedence candidates block pricing.

Released price decisions are immutable. Repricing creates a revision and new decision. No column accepts actual warehouse weight or post-pick price.

## 16. Split-Pack, Minimum, and Delivery Decisions

Split-pack pricing validates Product/Customer permission and defaults to a 15% per-unit premium over equivalent full-case unit price, subject to governed rounding and approved Product exception. The premium is included in unit price.

`sales.order_minimum_decision` PK order + decision sequence; stores eligible merchandise value, applicable threshold, agreement exception, outcome, charge, authority, and communication. Opening threshold is $500 per planned delivery.

`sales.order_delivery_service_decision` PK order + decision sequence; stores normal/emergency/off-schedule classification, service feasibility reference, expedited charge, Operations approval, and result.

Taxes, deposits, finance charges, and unrelated balances do not satisfy the minimum unless an applicable contract rule explicitly permits it.

## 17. Tax, Billing, and Terms Evidence

`sales.order_tax_evidence` PK `sales_order_number + revision_number + line_or_charge_type + line_number + tax_sequence`; stores jurisdiction, Product/charge tax class, exemption evidence reference, taxable basis, rate, estimated amount, source, and evaluation time.

`sales.order_billing_requirement_snapshot` PK `sales_order_number + revision_number + requirement_code`; stores Customer PO requirement, invoice reference, bill-to arrangement, delivery-document preference, and satisfied status.

`sales.order_terms_snapshot` PK order + revision; stores payment-term code and authoritative Customer/Finance decision reference. Finance owns final invoice tax, terms, and accounting.

## 18. Credit Evaluation and Holds

`sales.order_credit_evaluation` PK `sales_order_number + evaluation_sequence`; records requested amount, currency, Customer Credit Account reference, exposure/limit decision reference, prepaid/COD evidence, Finance decision, scope, approver, expiry, and time.

`sales.order_hold` PK `sales_order_number + hold_sequence`; stores hold type, optional line, blocking flag, owner role, reason, opened/required-resolution times, status, evidence, decision, approver, and close time.

Only the owning authority may resolve a hold. Sales cannot release `CREDIT_PAYMENT`, Finance-required `PRICE_MARGIN`, or tax holds. All active blocking holds prevent release.

## 19. Validation Results

`sales.order_validation_result` PK `sales_order_number + revision_number + validation_code`; records result, severity, evaluated time, governing rule/version, source reference, hold number when created, and sanitized detail.

Required validations cover Customer/account/location/contact, Product/unit, restrictions, price/margin, minimum/charge, tax/billing, terms/credit/payment, availability/allocation, substitution approval, contract, cutoff/schedule, route/service feasibility, and operational restrictions.

A `READY` result requires every mandatory validation to be successful or covered by a current authorized exception.

## 20. Shortages and Substitutions

`sales.shortage_decision` PK `sales_order_number + line_number + decision_sequence`; stores unavailable quantity, Inventory evidence, alternatives, Customer/Principal decision, communication, promised date, and outcome.

`sales.substitution_decision` PK `sales_order_number + line_number + decision_sequence`; stores original/substitute Product, units/packs, quantity, price effect, Product-relationship key, Customer preference, material-difference flags, required approvals, decision, and time.

An approved substitute creates a distinct Order Line linked through `sales.sales_order_line_relationship`, PK source order/line + target order/line + relationship type. The original line and decision remain immutable.

Institutional specifications and allergen/dietary/safety restrictions take precedence over general substitution permission.

## 21. Backorders and Cancellations

`sales.backorder` PK `originating_sales_order_number + originating_line_number + backorder_sequence`; stores outstanding base/sell quantity, promised/review date, Customer decision, status, resulting Order/Line, and audit data.

A resulting Backorder Fulfillment Order references its origin. Backorders do not reserve stock except through ordinary Inventory Reservation/Allocation.

`sales.order_cancellation` PK `sales_order_number + cancellation_sequence`; stores affected lines/quantities through child rows, requestor, reason, pre/post-release state, unavoidable-cost evidence, charge, Customer Service/Operations/Finance approvals as applicable, and time.

Cancellation releases unused allocation atomically. Dispatched quantity cannot be cancelled; delivery/return/billing correction applies.

## 22. Inventory Integration and Release Snapshot

Sales demand references Inventory Reservation and Allocation business numbers. Inventory remains authoritative for ATP, FEFO/FIFO, eligible stock, remaining life, lot/location/pallet selection, and nonnegative balance.

`sales.order_allocation_reference` PK `sales_order_number + line_number + inventory_allocation_number`; stores allocated quantity, active status, and last synchronized event. It is a relationship, not a copied Inventory balance.

`sales.order_release` PK `sales_order_number + release_sequence`; stores revision number, release time, fulfillment cycle, total/quantity control values, validation set, allocation state, releasing Principal, and status.

`sales.order_release_line` PK order + release sequence + line number; preserves immutable Product/unit/quantity/price/instruction/allocation evidence supplied to Warehouse. Release and required Inventory commitments commit together.

## 23. Fulfillment and Delivery Milestones

`sales.order_fulfillment_event` PK `sales_order_number + event_time + event_type_code`; records authoritative Warehouse/Transportation source key, quantities, status effect, correlation, and received time.

Events cover pick short, picked, staged, loaded, dispatched, delivered, refused, damaged, returned, and reversed outcomes. Sales cannot originate Warehouse/Transportation facts.

`sales.order_quantity_reconciliation` is a controlled view/materialized operational projection, not editable truth. It reconciles ordered/revised, allocated, picked, loaded, delivered, refused, returned, backordered, cancelled, and unresolved quantities.

## 24. Billing Handoff

`sales.billing_instruction` PK `sales_order_number + billing_instruction_sequence`; stores release/load reference, Customer/billing/terms/tax evidence, loaded quantities, prices, charges, readiness, and Finance acknowledgment.

`sales.billing_instruction_line` PK order + instruction sequence + line number; preserves Product/unit, loaded quantity, unit price, extension, tax evidence, and source Order Line.

Finance assigns Invoice Number and owns `PENDING_DELIVERY`, finalization, AR, revenue, COGS, credit/debit memo, supplemental invoice, and GL effects. Sales records Finance document references but cannot update Finance documents.

## 25. Customer Service Cases

`sales.customer_service_case` uses `customer_service_case_number` as PK and stores case type, severity, Customer/contact, Order/Delivery/Invoice references, owner, opened/target times, status, summary, resolution, and audit columns.

`sales.customer_service_case_activity` PK case number + activity sequence; stores activity type/time, Principal/contact, communication channel, commitment/next-action time, evidence, and outcome. Activities are append-only.

`sales.customer_service_case_relationship` PK source case + related case + relationship type prevents duplicate/ambiguous linking while allowing related incidents.

## 26. Return Authorization and Resolution Request

`sales.return_authorization` uses `return_authorization_number` as PK and stores Customer, delivery location, case, original Order/Delivery/Invoice references, reason, request/approval times, pickup instructions, status, and audit data.

`sales.return_authorization_line` PK return authorization + line number; stores original document line references, Product, lot if known, authorized quantity/unit, condition statement, and disposition/receipt references.

`sales.customer_resolution_request` PK case number + resolution sequence; stores requested credit/debit/replacement/no-change outcome, amount/quantity, reason, evidence, authority, Finance/Operations/Quality decision references, and final result.

Authorized return quantity cannot exceed eligible delivered quantity net of prior returns. Returned stock enters unavailable Inventory; Sales cannot release it or issue financial credit.

## 27. Controlled Functions

Required transaction-safe functions:

- `create_or_revise_price_list(...)`
- `create_customer_price_agreement(...)`
- `resolve_sales_price(...) returns price_decision`
- `create_or_revise_standing_order_template(...)`
- `generate_standing_order_occurrence(...) returns sales_order_number`
- `create_sales_order(...) returns sales_order_number`
- `add_or_change_sales_order_line(...)`
- `evaluate_order_schedule(...)`
- `evaluate_order_minimum_and_delivery(...)`
- `record_tax_terms_and_credit_evidence(...)`
- `place_or_resolve_order_hold(...)`
- `validate_sales_order(...)`
- `record_shortage_or_substitution_decision(...)`
- `create_or_resolve_backorder(...)`
- `cancel_sales_order_quantity(...)`
- `release_sales_order(...) returns release_sequence`
- `record_fulfillment_event(...)`
- `prepare_billing_instruction(...)`
- `open_or_update_customer_service_case(...)`
- `authorize_customer_return(...) returns return_authorization_number`
- `request_customer_resolution(...)`
- `reconcile_sales_order(...)`

Functions validate Principal/authority, lock rows deterministically, check expected row versions, enforce effective rules, call owning-domain functions, use safe `search_path`, and deny `PUBLIC` execution.

## 28. Integrity, Concurrency, and Reconciliation

- Effective price, authority, margin, template, and calendar periods cannot overlap ambiguously.
- Duplicate electronic/source orders are prevented.
- Line quantities and order monetary totals reconcile.
- One current approved price decision exists per active line revision.
- Blocking holds prevent release.
- Released revisions/snapshots and decisions reject update/delete.
- Release locks Order, lines, validations, price decisions, holds, and allocation references deterministically.
- Concurrent release cannot duplicate Warehouse demand or Inventory commitment.
- Allocation, fulfillment, cancellation, Backorder, return, and billing quantities cannot exceed revised ordered quantity.
- Post-release changes create a new approved revision and required downstream correction.
- Final corrections use linked forward records or reversals.

## 29. Audit

`audit.sales_event` PK `sales_audit_event_number`; records event type/time, Principal, Customer, Sales Order/Line/Revision, price/hold/decision/case/return references, source domain/document, reason/approval, correlation, and sanitized `jsonb` summary. It is append-only and supplements rather than replaces domain facts.

## 30. Indexes and Views

Indexes support effective price resolution; price agreement expiry; order source duplicate checks; orders by Customer/date/status/Sales Principal; fulfillment cycle; active holds/validations; shortages/substitutions/backorders; allocation references; released demand; fulfillment events; billing readiness; cases by owner/age/type; returns; and audit correlation.

Required views:

- `reporting.current_sales_price`
- `reporting.expiring_customer_price_agreement`
- `reporting.sales_order_status`
- `reporting.sales_order_hold`
- `reporting.sales_order_cutoff_exception`
- `reporting.sales_order_release_readiness`
- `reporting.sales_margin`
- `reporting.sales_price_exception`
- `reporting.below_minimum_order`
- `reporting.split_pack_sales`
- `reporting.sales_fill_rate`
- `reporting.sales_shortage_substitution_backorder`
- `reporting.sales_order_quantity_reconciliation`
- `reporting.sales_billing_readiness`
- `reporting.customer_service_case`
- `reporting.customer_return_status`

## 31. Privileges

`pfd_database_owner` owns objects; `pfd_change_executor` assumes ownership only during approved builds; `pfd_application` reads approved operational data and executes controlled functions; `pfd_reporting` reads approved views; `pfd_support_readonly` receives diagnostic read access; `PUBLIC` receives none.

Sales cannot approve its own Finance credit/tax decision, alter Inventory Balance/Allocation directly, create Warehouse/Transportation facts, or issue/post Finance documents. Customer Service cannot change approved price policy outside authority. Direct writes to release snapshots, decisions, events, history, activities, audit, and number state are prohibited.

## 32. Change Order

| Change | Content |
|---|---|
| `0069` | Add Sales business-number sequences and reference data |
| `0070` | Create Price Lists, versions, items, Customer agreements, and scope |
| `0071` | Create price authority, margin policy, and effective-period controls |
| `0072` | Create Standing Order Templates, lines, and occurrences |
| `0073` | Create Sales Order headers, lines, charges, revisions, and status history |
| `0074` | Create order calendars, fulfillment cycles, and schedule decisions |
| `0075` | Create price, split-pack, minimum, delivery, tax, billing, and terms evidence |
| `0076` | Create credit evaluations, holds, and validation results |
| `0077` | Create shortages, substitutions, line relationships, Backorders, and cancellations |
| `0078` | Create allocation references, release snapshots, and Warehouse handoff |
| `0079` | Create fulfillment events, reconciliation, and billing instructions |
| `0080` | Create Customer Service Cases, activities, returns, and resolution requests |
| `0081` | Create controlled functions, audit, indexes, and reporting views |
| `0082` | Apply comments, privileges, deferred constraints, and final assertions |

## 33. Verification and Tests

Verification proves contiguous history/checksums through `0082`; required objects/codes; approved natural keys; validated/deferred constraints; no surrogate keys; nonoverlapping effective prices; immutable release/decision/event/audit records; role separation; quantity/amount reconciliation; no catch-weight fields; and no simulation-session columns.

Disposable tests cover price precedence and ambiguity; Customer/contract scope; margin concurrence; standing-order generation; duplicate electronic order; office calendar/cutoff/Friday cycle; $500 minimum decisions; 15% split premium; tax/terms evidence; Finance hold authority; validation/readiness; Inventory shortage; approved/material substitution; Backorder; pre/post-release revision; cancellation/allocation release; concurrent release; Warehouse/Transportation event authority; billing instruction; case/return limits; unauthorized access; and ordinary-table simulation.

## 34. Acceptance Criteria

The eventual package must build cleanly and incrementally through `0082`, rerun as a no-op, and pass checksum, behavioral, concurrency, reconciliation, and privilege tests. It must demonstrate deterministic pricing, exact natural keys, controlled order release, immutable commercial evidence, complete shortage/substitution/backorder traceability, and clean owning-domain boundaries.

## 35. Deferred Configuration

Opening price lists, margin floors, discount limits, agreements, small-order/expedited charges, approval thresholds, channel details, standing templates, reason codes, tax provider/rules, and service targets are configuration—not unresolved architecture.

## 36. Next Design Work

Next: **Transportation and Delivery Domain Specification**. Executable Sales and Order Management SQL remains deferred until we leave Design Land.
