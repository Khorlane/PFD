# \<business name>
# Supplier and Purchasing PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0033`–`0044`  
**Depends on:** Cumulative design through `0032`

## 1. Purpose

Define the PostgreSQL structures and controls for Supplier qualification, approved Product sources, replenishment, quotations, Purchase Orders, acknowledgments, inbound appointments, discrepancies, returns, performance, and audit. This remains design only.

## 2. Required Outcome

- `supplier_number` is Supplier Master's primary key.
- `purchase_order_number` is Purchase Order's primary key.
- Other keys are controlled business numbers or meaningful composites.
- No surrogate, identity, serial, UUID, or hidden substitute keys.
- Issued PO revisions and Supplier acknowledgments are immutable.
- Inbound delivery is appointment-controlled.
- Warehouse Receipt observations remain authoritative.
- Disputed and undisputed amounts remain separate.
- Simulation uses the operational tables.

## 3. Platform and Package

PostgreSQL 15 or later; existing `core`, `party`, `product`, `purchasing`, `warehouse`, `quality`, `finance`, `audit`, and `reporting` schemas; cumulative manifest `4.0.0`; immutable changes `0001`–`0032`; new transactional changes `0033`–`0044` executed by the standard build runner under `pfd_database_owner`.

## 4. Standards

Use lowercase `snake_case`; uppercase governed codes; `numeric(19,6)` quantities; `numeric(19,4)` money; `date` for business dates; `timestamptz` for events/effective instants. Mutable rows use standard Principal/timestamp audit columns and positive `row_version`. Effective periods are half-open, nonoverlapping, and historically retained.

## 5. Controlled Numbers

Change `0033` adds:

| Sequence | Example |
|---|---|
| `SUPPLIER` | `000001` |
| `REPLENISHMENT_RECOMMENDATION` | `RR0000000001` |
| `REQUEST_FOR_QUOTE` | `RFQ00000001` |
| `PURCHASE_ORDER` | `PO00000001` |
| `INBOUND_APPOINTMENT` | `IA0000000001` |
| `PURCHASING_DISCREPANCY` | `PD0000000001` |
| `SUPPLIER_RETURN` | `SR0000000001` |
| `PURCHASING_AUDIT_EVENT` | `PAE0000000001` |

Allocation uses `core.allocate_business_number`; values are permanent and never reused.

## 6. Reference Data

Reference tables follow the Core pattern. Opening codes:

| Reference | Codes |
|---|---|
| Supplier status | `PENDING_APPROVAL`, `APPROVED`, `CONDITIONAL`, `PURCHASE_HOLD`, `QUALITY_HOLD`, `SUSPENDED`, `INACTIVE` |
| Supplier class | `FOOD_MANUFACTURER`, `FOOD_PROCESSOR_PACKER`, `PRODUCE_GROWER_SHIPPER`, `DISTRIBUTOR`, `PAPER_SUPPLIER`, `CLEANING_SANITATION_SUPPLIER`, `OTHER_FOOD_SERVICE_SUPPLIER` |
| Contact role | `SALES_REPRESENTATIVE`, `ORDER_DESK`, `ACKNOWLEDGMENT`, `APPOINTMENT_SCHEDULING`, `QUALITY_RECALL`, `CLAIMS_RETURNS`, `REMITTANCE`, `MANAGEMENT_ESCALATION` |
| Location type | `CORPORATE`, `ORDERING`, `SHIP_FROM`, `REMITTANCE`, `CLAIMS` |
| Source status | `PENDING_APPROVAL`, `APPROVED`, `CONDITIONAL`, `QUALITY_HOLD`, `INACTIVE` |
| Recommendation decision | `PENDING`, `ACCEPTED`, `ADJUSTED`, `DEFERRED`, `REJECTED`, `COMBINED` |
| RFQ status | `DRAFT`, `ISSUED`, `RESPONSES_DUE`, `EVALUATION`, `AWARDED`, `CLOSED`, `CANCELLED` |
| PO status | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `SENT`, `ACKNOWLEDGED`, `PARTIALLY_RECEIVED`, `RECEIVED`, `CLOSED`, `CANCELLED` |
| Appointment status | `REQUESTED`, `CONFIRMED`, `RESCHEDULED`, `ARRIVED`, `COMPLETED`, `REFUSED`, `CANCELLED`, `NO_SHOW` |
| Discrepancy type | `SHORTAGE`, `OVERAGE`, `DAMAGE`, `WRONG_PRODUCT`, `WRONG_UNIT`, `PRICE_VARIANCE`, `TERMS_VARIANCE`, `QUALITY_FAILURE`, `TEMPERATURE_FAILURE`, `SHELF_LIFE_FAILURE`, `DOCUMENT_FAILURE`, `UNAPPROVED_SUBSTITUTION` |
| Resolution | `ACCEPTED`, `SUPPLIER_CREDIT`, `REPLACEMENT`, `RETURN_TO_SUPPLIER`, `PRICE_ADJUSTMENT`, `QUANTITY_CORRECTION`, `SHARED_COST`, `REJECTED_NO_LIABILITY` |
| Freight terms | `PREPAID`, `COLLECT`, `PREPAID_ADD`, `DELIVERED` |
| Ordering method | `EMAIL`, `PORTAL`, `EDI`, `PHONE`, `OTHER` |

Compatibility tables govern status reasons and transitions.

## 7. Supplier Master

`purchasing.supplier` uses `supplier_number` (six digits) as PK and stores Organization Party, onboarding date, default currency, buyer Principal, ordering method, and audit columns. Multiple Supplier accounts may reference one Organization.

Effective structures:

- `supplier_name`: PK `supplier_number + effective_from`
- `supplier_status_history`: PK `supplier_number + effective_from`
- `supplier_classification`: PK `supplier_number + classification_code + effective_from`

Approved Suppliers require one current name, status, classification, buyer, and currency.

## 8. Locations, Contacts, and Documents

- `supplier_location`: PK `supplier_number + supplier_location_code`; name, type, timezone, active/audit data.
- `supplier_location_address`: PK location key plus address use and `effective_from`; references Party Address.
- `supplier_contact_assignment`: PK Supplier, role, Person Party, `effective_from`; optional location scope.
- `supplier_document`: PK Supplier, requirement type, document number; version, issue/expiration, verification, document reference, SHA-256 checksum, audit.

Every approved source requires an active `SHIP_FROM` location and current physical address. Required expired documents can place Supplier/source on hold.

## 9. Approved Product Sources

`supplier_product_source` PK:

`supplier_number + supplier_location_code + product_number + effective_from`

It stores Supplier/manufacturer item references, purchase unit, base conversion, minimum/increment, pallet quantity, lead days, cutoff, delivery pattern, receipt shelf-life minimum, lot/date requirements, substitution policy, priority, status, approval, and audit.

`supplier_product_terms` uses the source key plus `terms_effective_from`; it stores currency, unit cost, freight, surcharge/allowance, payment terms, early discount, rebate reference, return/restocking terms, and effective period.

`supplier_quantity_break` uses the source key plus `minimum_quantity + effective_from`. Break quantities and costs must be positive and ordered. Source periods and term periods cannot overlap.

## 10. Replenishment Recommendations

`replenishment_recommendation` PK `recommendation_number`; records Product, stocking location, proposed source, unit/quantity, base equivalent, need/receipt dates, projected supply/demand, safety stock, inbound supply, rounding, warnings, and generation facts.

`recommendation_decision` PK `recommendation_number + decision_at`; append-only buyer decision, quantity/date adjustments, reason, and PO-line link. Recommendations never become commitments automatically.

## 11. Requests for Quote

| Table | Primary key |
|---|---|
| `request_for_quote` | `request_for_quote_number` |
| `request_for_quote_line` | RFQ number + line number |
| `rfq_invited_supplier` | RFQ number + Supplier number |
| `rfq_response` | RFQ number + Supplier + response revision |
| `rfq_response_line` | Response key + RFQ line |
| `rfq_award` | RFQ number + line + Supplier |

Issued RFQs and submitted responses are immutable. Awards preserve price, terms, delivery, quality factors, selecting Principal, reason, and approval.

## 12. Purchase Orders

`purchase_order` is the stable header keyed by `purchase_order_number`; it stores Supplier, ship-from, destination, buyer, current status/revision, creation date, and audit data.

`purchase_order_revision` PK `purchase_order_number + revision_number`; stores currency, terms, freight, requested window, instructions, monetary components, approval, issuance, and revision reason.

`purchase_order_line` PK `purchase_order_number + revision_number + line_number`; stores Product, approved-source effective key, quantity/unit, base equivalent, unit cost, allowances/surcharges, extended amount, requested date, shelf-life/lot requirements, substitution permission, recommendation/RFQ links, and line status.

`purchase_order_status_history` PK `purchase_order_number + effective_from`.

Rules: positive nonreused line numbers; totals reconcile; approved/sent revisions are immutable; changes create complete new revisions; reductions cannot fall below accepted receipts; approval uses total commitment and delegated authority.

## 13. Supplier Acknowledgments

- `supplier_acknowledgment`: PK PO number + acknowledgment number
- `supplier_acknowledgment_line`: acknowledgment key + PO line
- `acknowledgment_exception`: acknowledgment key + PO line + exception type + sequence

They preserve acknowledged quantities, price, dates, backorder, substitution, terms, and exceptions. Records are append-only. Accepted differences require an approved PO revision.

## 14. Inbound Appointments

`warehouse.inbound_appointment` PK `appointment_number`; stores Supplier, optional carrier Party, receiving location/dock, scheduled window, expected pallets/cases, temperature classes, status, confirmation, contacts, instructions, exceptions, and audit.

- `inbound_appointment_purchase_order`: PK appointment + PO
- `inbound_appointment_status_history`: PK appointment + `effective_from`

Dock conflicts are rejected unless configured capacity permits them. Early, late, unscheduled, refused, rescheduled, and no-show events remain in history.

## 15. Receipt Boundary

The Warehouse build owns Receipt and actual quantity, lot, date, temperature, condition, and acceptance facts. Purchasing references permanent Receipt keys when available and never overwrites observations. Receipt-dependent functionality remains disabled until that domain exists, except isolated test fixtures.

## 16. Discrepancies and Returns

`purchasing.discrepancy` PK `discrepancy_number`; stores Supplier, PO/revision/line, optional Receipt/line, type, expected/actual quantity and value, disputed and undisputed amounts, evidence, owner, status, dates, and audit.

`discrepancy_resolution` PK `discrepancy_number + resolution_sequence`; immutable resolution type, quantity/value, credit/replacement expectation, settlement, approval, and timestamp.

`supplier_return` PK `supplier_return_number`; stores Supplier authorization, originating Receipt/lot, Product, quantity/unit, reason, disposition, expected credit/replacement, shipping responsibility, status, and audit.

`supplier_return_line` PK return number + line number. Cumulative returned quantity cannot exceed eligible received quantity net of earlier returns. Disputed plus undisputed value must reconcile to the affected amount.

## 17. Accounts Payable Boundary

Purchasing exposes PO commitments, revisions, accepted Receipts, discrepancies, returns, terms, discounts, and settlement expectations. Finance owns Supplier Invoice, matching, payable, payment, and General Ledger.

`purchasing.ap_match_evidence` is a read-only reporting view, not a duplicate AP table. It presents ordered, accepted, returned, disputed, and undisputed quantities/amounts. A dispute against one portion cannot automatically block the undisputed portion.

## 18. Supplier Performance

`supplier_performance_period` PK `supplier_number + performance_period_start`; stores period end and calculated acknowledgment, on-time delivery, fill, quantity/price accuracy, damage/rejection, shelf-life, documentation, Quality, and claim-resolution measures.

`supplier_performance_event` PK `supplier_number + event_type_code + source_document_type + source_document_number + event_at`; preserves calculation inputs. Recalculation creates a new calculation version rather than changing source facts. Scorecards inform—but do not automatically make—status decisions.

## 19. Controlled Functions

Required transaction-safe behavior:

- `create_pending_supplier(...) returns supplier_number`
- `set_supplier_status(...)`
- `add_supplier_location(...)`
- `record_supplier_document(...)`
- `approve_supplier_source(...)`
- `set_supplier_product_terms(...)`
- `record_replenishment_decision(...)`
- `create_request_for_quote(...) returns request_for_quote_number`
- `award_request_for_quote(...)`
- `create_purchase_order(...) returns purchase_order_number`
- `revise_purchase_order(...) returns revision_number`
- `approve_purchase_order(...)`
- `issue_purchase_order(...)`
- `record_supplier_acknowledgment(...)`
- `schedule_inbound_appointment(...) returns appointment_number`
- `record_purchasing_discrepancy(...) returns discrepancy_number`
- `resolve_purchasing_discrepancy(...)`
- `create_supplier_return(...) returns supplier_return_number`
- `close_purchase_order(...)`

Each validates Principal/authority, locks stable rows, checks expected `row_version`, preserves effective history, writes audit in the same transaction, fixes a safe `search_path`, and denies `PUBLIC` execution.

## 20. Approval and State Controls

Supplier approval requires organization, name, classification, locations, contacts, terms, required documents, and Quality review. Source approval requires active Supplier/Product, valid units/conversion, receiving shelf-life and traceability requirements, commercial terms, and approvals.

PO approval requires approved Supplier/source, current terms, valid quantities/dates, reconciled totals, capacity warnings reviewed, and authority for total commitment. A person cannot approve their own transaction above delegated authority. Quality Holds cannot be released by Purchasing.

## 21. Audit

`audit.purchasing_event` PK `purchasing_audit_event_number`, allocated from `PURCHASING_AUDIT_EVENT`. It records event type/time, Principal, Supplier, optional Product/PO/appointment/discrepancy/return, effective time, reason, approval, correlation code, and sanitized `jsonb` before/after summary.

The table is append-only. Audit JSON supports investigation but does not replace normalized or issued records.

## 22. Concurrency and Integrity

- Business numbers use locked Core allocation.
- Effective facts use GiST nonoverlap constraints.
- Stable records are locked before state/revision changes.
- Expected row version prevents lost updates.
- Only one current issued PO revision exists.
- Concurrent approvals cannot double-issue or overspend authority.
- Concurrent appointment changes cannot exceed dock capacity.
- PO totals equal line and header components.
- Supplier/source/document status is evaluated at commitment time.
- Issued revisions, acknowledgments, decisions, resolutions, and audit events are immutable.

## 23. Indexes and Views

Indexes support Supplier name/status/class/buyer; current locations/contacts/documents; sources by Product/Supplier/status/priority; expiring terms/documents; pending recommendations; RFQ status/deadlines; PO status/Supplier/buyer/delivery date; acknowledgment exceptions; appointment dock/time/status; open discrepancies/returns; and performance periods.

Required reporting views:

- `reporting.current_supplier`
- `reporting.current_supplier_source`
- `reporting.supplier_document_expiration`
- `reporting.product_source_coverage`
- `reporting.pending_replenishment_recommendation`
- `reporting.open_purchase_order`
- `reporting.purchase_order_exception`
- `reporting.inbound_appointment_schedule`
- `reporting.open_purchasing_discrepancy`
- `reporting.ap_match_evidence`
- `reporting.supplier_performance`

## 24. Privileges

| Role | Access |
|---|---|
| `pfd_database_owner` | Owns objects; `NOLOGIN` |
| `pfd_change_executor` | Assumes owner only during approved builds |
| `pfd_application` | Reads approved operational data and executes controlled functions |
| `pfd_reporting` | Reads approved views/reference data |
| `pfd_support_readonly` | Authorized diagnostic read access |
| `PUBLIC` | No domain access |

Application direct writes to issued commitments, acknowledgments, resolutions, performance source events, audit, or number state are prohibited. Sensitive banking/tax payment data remains in Finance.

## 25. Change Order

| Change | Content |
|---|---|
| `0033` | Add purchasing business-number sequences |
| `0034` | Create/seed Supplier and purchasing references |
| `0035` | Create Supplier Master, history, classifications, locations, contacts, documents |
| `0036` | Create Product sources, terms, and quantity breaks |
| `0037` | Create replenishment recommendations and decisions |
| `0038` | Create RFQ, response, and award structures |
| `0039` | Create PO, revisions, lines, and status history |
| `0040` | Create acknowledgments and exceptions |
| `0041` | Create inbound appointments and history |
| `0042` | Create discrepancies, resolutions, returns, and performance |
| `0043` | Create functions, audit, temporal guards, and reporting views |
| `0044` | Apply comments, privileges, reference assertions, and final verification metadata |

## 26. Verification

Read-only verification proves contiguous history/checksums through `0044`; required objects and exact reference codes; approved natural keys; validated FKs/checks/exclusions; no surrogate keys; immutable issued/audit records; reconciled PO amounts; controlled function and privilege rules; appointment controls; disputed/undisputed separation; and absence of simulation-session columns.

## 27. Behavioral Tests

Disposable-database tests must cover:

1. Supplier/PO and other business-number allocation.
2. Supplier/source approval prerequisites and Quality Hold authority.
3. Multiple Suppliers per Product and multiple accounts per Organization.
4. Effective-history overlap rejection.
5. Unit/conversion and minimum/increment validation.
6. Recommendation decisions without automatic commitment.
7. Immutable issued RFQs, responses, PO revisions, and acknowledgments.
8. PO revision and total reconciliation.
9. Acknowledgment differences requiring an approved revision.
10. Appointment requirement, dock conflict, reschedule, and no-show history.
11. Receipt facts remaining unmodified by Purchasing.
12. Discrepancy amount reconciliation and partial dispute.
13. Undisputed value remaining eligible for AP processing.
14. Return quantity not exceeding eligible receipts.
15. Fact-based performance recalculation.
16. Unauthorized access and audit immutability.
17. Concurrent number, PO-approval, and appointment operations.
18. Ordinary-table simulation behavior.

## 28. Acceptance Criteria

The eventual SQL package is accepted when clean and incremental builds reach `0044`, reruns are no-ops, and all checksum, verification, behavioral, concurrency, and privilege tests pass. It must demonstrate controlled natural keys, immutable commitments, scheduled receiving, authoritative Receipt facts, traceable discrepancy settlement, and separate disputed/undisputed values.

## 29. Deferred Configuration

Opening Suppliers/sources, prices, lead times, approval thresholds, match tolerances, dock capacity, document requirements, and performance targets are configuration—not unresolved architecture.

## 30. Next Design Work

Next: **Inventory Domain Specification**. Executable Supplier/Purchasing SQL remains deferred until we leave Design Land.
