# Inventory PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0045`–`0056`  
**Depends on:** Cumulative design through `0044`; Inventory Domain Specification

## 1. Purpose

Define PostgreSQL structures and controls for perpetual inventory, lots, pallets, balances, events, placement, allocation, transfer, holds, counts, adjustments, disposition, cost evidence, reporting, and audit. This remains design only.

## 2. Required Outcome

- Immutable inventory events drive current balances.
- All inventory uses Inventory Lot identity, even when Supplier lot capture is unnecessary.
- Product base unit is the quantity-accounting unit.
- Fixed quantities are supported; warehouse catch-weight pricing and price-at-weigh fields are prohibited.
- Inventory never becomes negative through normal processing.
- FEFO/FIFO, holds, remaining-life rules, and location compatibility are enforced.
- Picking-slot placement/removal timestamps are retained by lot/pallet.
- No surrogate, identity, serial, UUID, or hidden substitute keys.
- Simulation uses ordinary inventory tables.

## 3. Platform and Package

PostgreSQL 15 or later; existing `core`, `product`, `purchasing`, `inventory`, `warehouse`, `quality`, `sales`, `finance`, `audit`, and `reporting` schemas; cumulative manifest `5.0.0`; immutable changes `0001`–`0044`; transactional changes `0045`–`0056` through the standard runner.

## 4. Standards

Use lowercase `snake_case`, uppercase governed codes, `numeric(19,6)` quantities, `numeric(19,4)` costs, `date` for Product dates, and `timestamptz` for events/effective periods. Mutable rows use standard Principal/timestamp audit columns and positive `row_version`. Transaction/event records are append-only.

## 5. Controlled Numbers

Change `0045` adds:

| Sequence | Example |
|---|---|
| `INVENTORY_LOT` | `LOT00000001` |
| `PALLET` | `PAL00000001` |
| `INVENTORY_TRANSACTION` | `ITX0000000001` |
| `INVENTORY_RESERVATION` | `RSV0000000001` |
| `INVENTORY_ALLOCATION` | `ALC0000000001` |
| `INVENTORY_HOLD` | `HLD0000000001` |
| `INVENTORY_TRANSFER` | `MOV0000000001` |
| `PHYSICAL_COUNT` | `CNT0000000001` |
| `INVENTORY_ADJUSTMENT` | `ADJ0000000001` |
| `INVENTORY_DISPOSITION` | `DSP0000000001` |
| `INVENTORY_AUDIT_EVENT` | `IAE0000000001` |

Allocation uses the Core number service; numbers are permanent and never reused.

## 6. Reference Data

| Reference | Opening codes |
|---|---|
| Stock status | `RECEIVING`, `AVAILABLE`, `QUARANTINED`, `QUALITY_HOLD`, `RECALL_HOLD`, `DAMAGED`, `EXPIRED`, `RETURN_PENDING`, `DISPOSITION_PENDING`, `DISPOSED` |
| Ownership | `COMPANY_OWNED` |
| Inventory transaction type | `RECEIPT_ACCEPT`, `RECEIPT_REJECT`, `PUTAWAY`, `REPLENISH_PICK_SLOT`, `TRANSFER`, `STATUS_CHANGE`, `ALLOCATE`, `DEALLOCATE`, `PICK`, `PICK_REVERSE`, `SHIP`, `SHIP_REVERSE`, `CUSTOMER_RETURN`, `SUPPLIER_RETURN`, `COUNT_ADJUST`, `DISPOSITION`, `HOLD`, `HOLD_RELEASE` |
| Lot date type | `MANUFACTURE_DATE`, `PACK_DATE`, `BEST_BY_DATE`, `USE_BY_DATE`, `EXPIRATION_DATE` |
| Hold type | `QUALITY`, `RECALL`, `DAMAGE`, `EXPIRATION_REVIEW`, `ADMINISTRATIVE` |
| Disposition type | `RELEASE`, `REWORK_REPACK`, `RETURN_TO_SUPPLIER`, `DONATE`, `DESTROY`, `OTHER_WRITE_OFF` |
| Count type | `CYCLE`, `LOCATION`, `PRODUCT_LOT`, `FULL_PHYSICAL` |
| Adjustment reason | `RECEIVING_CORRECTION`, `COUNT_VARIANCE`, `DAMAGE`, `EXPIRATION`, `UNIT_CONVERSION_CORRECTION`, `STATUS_CORRECTION`, `ADMINISTRATIVE_CORRECTION` |
| Reservation status | `ACTIVE`, `CONVERTED`, `EXPIRED`, `RELEASED`, `CANCELLED` |
| Allocation status | `ACTIVE`, `PARTIALLY_PICKED`, `PICKED`, `RELEASED`, `CANCELLED`, `SHIPPED` |
| Location type | `RECEIVING`, `RESERVE`, `PICKING`, `STAGING`, `QUARANTINE`, `DAMAGE`, `RETURN`, `DISPOSITION` |

Reference tables follow the Core active/effective/audit pattern.

## 7. Warehouse Location Foundation

`warehouse.location` uses `warehouse_location_code` as PK and contains name, location type, storage class, optional zone/aisle/rack/level/bin descriptors, capacity, pickable flag, active status, and audit columns.

This is the minimum location identity needed by Inventory. The later Warehouse design extends operational attributes without replacing the key.

Location compatibility considers Product storage class, temperature, food/nonfood segregation, handling requirements, and location status.

## 8. Inventory Lot

`inventory.inventory_lot` uses `inventory_lot_number` as PK and stores Product, Supplier/source, PO/Receipt references when applicable, received timestamp, initial accepted base quantity, current traceability status, and audit columns.

Every accepted stock quantity receives an Inventory Lot. For Products with lot method `NONE`, the lot still identifies receipt/cost provenance; Supplier/manufacturer lot fields remain null.

`inventory.inventory_lot_date` PK `inventory_lot_number + lot_date_type_code`; stores date, source, verification, and audit. Required dates follow the effective Product shelf-life policy.

Supplier/manufacturer lot identifiers are alternate traceability values, not keys.

## 9. Pallets and Composition

`inventory.pallet` uses `pallet_number` as PK and stores pallet status, current Warehouse Location, created/closed times, and audit data.

`inventory.pallet_composition` PK:

`pallet_number + product_number + inventory_lot_number + effective_from`

It stores base quantity and effective period. Changes close/open composition rows atomically. Mixed Product or mixed lot is allowed only when Product and Warehouse policy permit it.

## 10. Inventory Balance

`inventory.inventory_balance` PK:

`product_number + inventory_lot_number + warehouse_location_code + stock_status_code + ownership_code`

It stores on-hand base quantity, allocated base quantity, last transaction number/time, and row version. Available quantity is calculated as eligible on hand minus active allocation; it is not independently editable.

Physical design intentionally aggregates pallets within the same Product/Lot/Location/Status/Ownership bucket. Pallet Composition provides pallet-level detail and must reconcile to the bucket balance.

Checks prevent negative on-hand/allocated/available quantities and allocation against an ineligible status.

## 11. Inventory Ledger

`inventory.inventory_transaction` PK `inventory_transaction_number`; stores transaction type, event/effective times, source document type/number, reversal reference, responsible Principal, reason, approval, correlation code, and posting state.

`inventory.inventory_transaction_line` PK transaction number + line number; stores Product, lot, optional pallet, location, stock status, ownership, signed base quantity, transaction quantity/unit/conversion evidence, and optional source cost.

Rules:

- Lines total to zero for movements between buckets.
- External receipts/shipments use an explicit external counterparty side classification.
- Posted transactions are immutable.
- Reversal uses a new transaction referencing the original.
- Balance changes and ledger posting occur in one database transaction.

## 12. Picking-Slot Placement

`inventory.picking_slot_placement` PK:

`warehouse_location_code + product_number + inventory_lot_number + pallet_number + placed_at`

Columns include placed quantity, remaining quantity, removed/depleted time, rotation rank, responsible Principal, and override reason/approval.

If loose stock has no pallet, a Product/Lot placement uses `pallet_number` only in a separate `inventory.loose_picking_slot_placement` table keyed without Pallet. This avoids nullable primary-key components and fake pallet values.

Overlapping active placement of the same pallet is prohibited. Multiple lots may share a picking slot. FEFO/FIFO ranks the next eligible lot, and bypass requires an authorized reason.

## 13. Reservations and Allocations

`inventory.inventory_reservation` PK `inventory_reservation_number`; stores demand document/line, Product, requested base quantity/date, expiration, priority, status, and audit.

`inventory.inventory_allocation` PK `inventory_allocation_number`; stores demand document/line, Product, lot, location, optional pallet, allocated base quantity, remaining-life evidence, rotation rank, substitution reference, status, and audit.

`inventory.reservation_allocation` PK reservation number + allocation number.

Allocation functions lock candidate balances in deterministic FEFO/FIFO order, prevent double allocation, respect Customer/Product restrictions and split-pack increments, and return an explicit shortage when demand cannot be filled.

## 14. Transfers

- `inventory.transfer_request`: PK `inventory_transfer_number`; reason, source/destination, priority, status, requester, approval.
- `inventory.transfer_request_line`: PK transfer number + line number; Product, lot, pallet, quantity/unit.
- Execution posts balanced Inventory Transactions.

Picking-slot replenishment respects capacity, compatibility, rotation, and current-lot-depletion policy.

## 15. Holds and Recall

`inventory.inventory_hold` PK `inventory_hold_number`; stores hold type, reason, initiating/approving Principal, effective/release times, status, external recall reference, and audit.

Scope tables use meaningful composites for Product, Supplier/manufacturer lot, lot, pallet, location, or quantity. Hold placement atomically moves affected available quantity to the correct hold status and identifies existing reservations/allocations for review.

Only Quality may release Quality or Recall Holds. Released quantity returns through a new status-change transaction.

## 16. Expiration and Remaining Life

Database views calculate remaining days from the governing lot date and business date. Allocation functions apply Product policy and stricter Customer/Product rules.

Expired quantity cannot be allocated. Below-threshold quantity requires a recorded exception; quantity expiring in two days is not automatically approved. Scheduled processing proposes status changes to `EXPIRED` or `DISPOSITION_PENDING`, but controlled functions post them.

## 17. Physical Counts and Adjustments

`inventory.physical_count` PK `physical_count_number`; count type/scope, snapshot time, blind-count flag, status, supervisors, and audit.

`inventory.physical_count_line` PK count number + line number; expected Product/lot/pallet/location/status/ownership, expected quantity, first count, recount, variance, counters, and timestamps.

`inventory.inventory_adjustment` PK `inventory_adjustment_number`; reason, count/source reference, status, value-impact estimate, approver, posting transaction, and audit.

`inventory.inventory_adjustment_line` PK adjustment number + line number.

Counts never overwrite balances. Approved adjustments post new ledger transactions. Material variances require a different approver than counter.

## 18. Customer Returns and Disposition

Returned stock first enters a Return/Quarantine location and unavailable status.

`inventory.inventory_disposition` PK `inventory_disposition_number`; stores Product/lot/pallet/location, quantity, disposition type, reason, Quality/Operations/Finance approvals, Supplier return or customer-return reference, expected value effect, and status.

`inventory.inventory_disposition_line` PK disposition number + line number. Posted disposition references an Inventory Transaction and cannot exceed eligible quantity.

## 19. Cost Evidence and Finance Boundary

`inventory.inventory_cost_source` PK:

`inventory_lot_number + receipt_number + receipt_line_number`

It stores accepted quantity, PO currency/unit cost, allowances, allocated freight/landed-cost components when supplied, and Finance posting reference. Inventory preserves source facts; Finance owns valuation method, reserves, period close, and GL.

Quantity and financial entries remain separately controlled and linked by source/correlation keys.

## 20. Controlled Functions

Required transaction-safe functions:

- `accept_received_inventory(...) returns inventory_lot_number`
- `create_or_update_pallet(...)`
- `post_inventory_transaction(...) returns inventory_transaction_number`
- `place_in_picking_slot(...)`
- `remove_from_picking_slot(...)`
- `reserve_inventory(...) returns reservation_number`
- `allocate_inventory(...) returns allocation results`
- `release_reservation_or_allocation(...)`
- `request_inventory_transfer(...) returns transfer_number`
- `post_inventory_hold(...) returns hold_number`
- `release_inventory_hold(...)`
- `create_physical_count(...) returns count_number`
- `record_count(...)`
- `approve_inventory_adjustment(...) returns adjustment_number`
- `record_returned_inventory(...)`
- `approve_inventory_disposition(...) returns disposition_number`
- `reconcile_inventory_balance(...)`

Functions validate Principal/authority, lock rows deterministically, check row versions, enforce Product/Customer/location rules, update balance and ledger atomically, use safe `search_path`, and deny `PUBLIC` execution.

## 21. Audit

`audit.inventory_event` PK `inventory_audit_event_number`. It records event type/time, Principal, Product, lot, pallet, location, source transaction/document, effective time, reason, approval, correlation, and sanitized `jsonb` summary. It is append-only and does not replace ledger facts.

## 22. Concurrency and Reconciliation

- Candidate balances lock in deterministic key/FEFO order.
- Concurrent allocation cannot consume the same quantity.
- Ledger and balance commit together.
- Pallet Composition reconciles to Inventory Balance.
- Placement remaining quantity reconciles to the applicable picking-location balance.
- Transfers and status changes balance to zero.
- Inventory never goes negative.
- Lot/date requirements match Product policy.
- Quantity-to-Finance reconciliation is produced by period without either domain changing the other's facts.

## 23. Indexes and Views

Indexes support balances by Product/location/status/lot date; FEFO/FIFO selection; pallet/location lookup; active picking-slot placements; demand reservation/allocation; open transfers/holds/counts/dispositions; expiration; Supplier/manufacturer lot traceability; and transaction/audit source lookup.

Required views:

- `reporting.inventory_on_hand`
- `reporting.inventory_available_to_promise`
- `reporting.inventory_expiration_exposure`
- `reporting.inventory_rotation_exception`
- `reporting.picking_slot_multiple_lots`
- `reporting.picking_slot_dwell_time`
- `reporting.open_inventory_hold`
- `reporting.open_inventory_allocation`
- `reporting.physical_count_variance`
- `reporting.inventory_transaction_reconciliation`
- `reporting.inventory_finance_reconciliation`
- `reporting.lot_traceability`

## 24. Privileges

`pfd_database_owner` owns objects; `pfd_change_executor` assumes ownership only for builds; `pfd_application` reads approved data and executes controlled functions; `pfd_reporting` reads approved views; `pfd_support_readonly` receives diagnostic read access; `PUBLIC` receives none.

Warehouse cannot release Quality/Recall Holds or approve material adjustments. Sales cannot directly update balance. Finance cannot alter physical quantity. Posted transactions and audit events reject update/delete.

## 25. Change Order

| Change | Content |
|---|---|
| `0045` | Add Inventory sequences and reference data |
| `0046` | Create Warehouse Location foundation and compatibility controls |
| `0047` | Create Inventory Lot, dates, Pallet, and composition |
| `0048` | Create Inventory Balance and immutable ledger |
| `0049` | Create picking-slot placement and transfers |
| `0050` | Create reservations and allocations |
| `0051` | Create holds, recall, expiration, and remaining-life controls |
| `0052` | Create physical counts and adjustments |
| `0053` | Create returned-stock, disposition, and cost evidence |
| `0054` | Create controlled functions and concurrency guards |
| `0055` | Create audit events, reconciliation, and reporting views |
| `0056` | Apply comments, privileges, and final assertions |

## 26. Verification and Tests

Verification proves contiguous history/checksums through `0056`; required objects/codes; natural keys; validated constraints; no surrogate keys; append-only ledger/audit; balanced transactions; nonnegative balances; FEFO/FIFO and remaining-life controls; placement timestamps; privilege separation; and no simulation-session columns.

Disposable tests cover lot/pallet allocation; non-lot Product receipt provenance; unit conversion; balanced posting/reversal; concurrent allocation; multi-lot picking slots; rotation override; two-day expiration rejection/approval; holds; transfers; count/recount/adjustment; returned-stock quarantine; disposition limits; pallet/balance reconciliation; unauthorized access; and ordinary-table simulation.

## 27. Acceptance Criteria

The eventual package must build cleanly and incrementally through `0056`, rerun as a no-op, and pass checksum, behavioral, concurrency, reconciliation, and privilege tests. It must demonstrate one permanent inventory truth, exact natural keys, no negative stock, complete lot traceability, and controlled expiration/hold/adjustment behavior.

## 28. Next Design Work

Next: **Warehouse Operations Domain Specification**. Executable Inventory SQL remains deferred until we leave Design Land.
