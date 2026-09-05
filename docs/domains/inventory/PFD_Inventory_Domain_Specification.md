# \<business name>
# Inventory Domain Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Design baseline  
**Depends on:** PFD Core, Product, Supplier/Purchasing, and future Warehouse transaction boundaries

## 1. Purpose

Define how PFD accounts for physical stock from receipt through allocation, movement, shipment, return, adjustment, and disposition. This is business and logical-data design, not PostgreSQL implementation.

## 2. Scope

Inventory owns:

- Perpetual stock quantities and immutable inventory events
- PFD lot and pallet identity
- Supplier/manufacturer lot and product-date traceability
- Stock status and ownership
- Quantity by Product, lot, pallet, and warehouse location
- Available-to-promise and allocation
- FEFO/FIFO selection
- Transfers and status changes
- Physical count, reconciliation, and approved adjustment
- Expiration, recall, damage, quarantine, and disposition control
- Inventory costing source facts and Finance interface

Warehouse owns physical location design, receiving/picking labor, movement execution, and shipment loading. Sales owns demand; Purchasing owns supply commitments; Quality owns safety disposition; Finance owns valuation policy and accounting entries.

## 3. Governing Decisions

1. Inventory is perpetual: every quantity change is an immutable event.
2. Current balances are maintained atomically from those events and must reconcile to them.
3. `inventory_lot_number`, `pallet_number`, `inventory_transaction_number`, and `inventory_allocation_number` are permanent business keys.
4. No surrogate keys are used.
5. Inventory may not become negative through normal processing.
6. Product base stocking unit is the inventory accounting unit; transaction units retain exact conversion evidence.
7. Lot/date-controlled Products require lot and applicable date capture at receipt.
8. FEFO governs date-sensitive stock; FIFO otherwise, subject to approved exceptions.
9. Multiple lots may occupy one picking slot, but the selected lot is depleted before the next unless an authorized override is recorded.
10. Date/time placed in and removed from a picking slot is retained for every lot/pallet placement.
11. A Product expiring in two days is not automatically shippable. Product/customer remaining-life rules and Quality approval control disposition.
12. Holds make quantity unavailable immediately without erasing physical stock.
13. Count differences require review and an adjustment transaction; counts never directly overwrite balances.
14. Simulation uses the same Inventory records and controls as normal operation.

## 4. Inventory Identity

### 4.1 PFD Inventory Lot

Every lot-controlled receipt receives a PFD Inventory Lot Number. It links:

- Product
- Supplier and ship-from source
- Purchase Order and Receipt
- Supplier and manufacturer lot numbers
- Received date/time
- Manufacture/pack, best-by, use-by, and expiration dates as applicable
- Initial accepted quantity
- Quality and traceability status

Supplier lot is not the PFD key because formats may repeat across Suppliers or Products.

### 4.2 Pallet

A pallet or warehouse license plate receives a permanent Pallet Number. It identifies the physical handling unit and its current composition. A pallet may be full, partial, mixed-Product, or mixed-lot only where warehouse and Product policy permit.

Changing pallet contents creates inventory movement events; it does not change pallet identity.

## 5. Stock Status

Opening statuses:

| Status | Available for allocation? |
|---|---:|
| `RECEIVING` | No |
| `AVAILABLE` | Yes |
| `QUARANTINED` | No |
| `QUALITY_HOLD` | No |
| `RECALL_HOLD` | No |
| `DAMAGED` | No |
| `EXPIRED` | No |
| `RETURN_PENDING` | No |
| `DISPOSITION_PENDING` | No |
| `DISPOSED` | No |

Allocated quantity remains physically `AVAILABLE` but is committed through an allocation record. This avoids confusing physical condition with commercial commitment.

## 6. Ownership

Opening ownership is `PFD_OWNED`. The model may later support approved consigned or customer-owned stock, but such ownership must remain separately identifiable and must not enter PFD inventory value without Finance policy.

Ownership transfer occurs only through a defined business event, normally accepted receipt or shipment confirmation according to agreed terms.

## 7. Inventory Balance

The logical balance grain is:

`Product + PFD Lot + Pallet + Warehouse Location + Stock Status + Ownership`

The balance stores:

- On-hand quantity in Product base unit
- Allocated quantity
- Available quantity
- Last inventory transaction
- Last movement time
- Row version

Available equals eligible on-hand less active allocations. It cannot be negative. A zero balance may be retained briefly for traceability and then archived under controlled retention; the event history remains permanent.

## 8. Inventory Transactions

Every quantity or status change creates one inventory transaction with balanced transaction lines. Transaction types include:

- Receipt acceptance
- Receipt rejection or quarantine
- Putaway
- Replenishment to picking slot
- Internal transfer
- Allocation and deallocation
- Pick confirmation and reversal
- Shipment confirmation and reversal
- Customer return receipt
- Supplier return shipment
- Status change or hold
- Count adjustment
- Damage, expiration, donation, or disposal
- Recall hold and release

Each transaction identifies source document, event time, effective time, responsible Principal, reason, approval when required, and before/after location/status quantities.

Movement between locations or statuses is balanced: quantity leaves one inventory bucket and enters another within one atomic transaction.

## 9. Receipt and Putaway

Warehouse records actual receipt facts. Inventory accepts only quantities approved by Receiving/Quality and creates the appropriate lot, pallet, status, and balance events.

Putaway records:

- Product, lot, pallet, quantity, and unit
- From and to locations
- Placement timestamp
- Worker/process Principal
- Product handling and location compatibility
- Rotation sequence

Unverified or nonconforming stock enters `QUARANTINED` or `QUALITY_HOLD`, not `AVAILABLE`.

## 10. Picking-Slot Placement

Each placement of a lot or pallet into a picking slot has a distinct effective period:

- Placed-at timestamp
- Removed/depleted-at timestamp
- Quantity placed and remaining
- Rotation rank
- Override reason if normal sequence is bypassed

Several lots may be present in one slot. Inventory identifies the active lot to deplete based on FEFO/FIFO and Product policy. Warehouse confirms actual execution.

## 11. Rotation and Expiration

For FEFO, the earliest qualifying expiration/use-by/best-by date is selected. Ties use receipt time and then PFD Lot Number. FIFO uses accepted receipt time and then PFD Lot Number.

Stock is excluded when:

- It will not meet Product shipment-life policy
- It will not meet a stricter Customer/Product requirement
- It is expired or on hold
- It cannot reasonably remain compliant through delivery and intended use

A below-threshold shipment requires explicit Quality/business approval and never overrides safety or legal limits. Expiration monitoring moves unusable stock to hold/disposition through controlled events.

## 12. Allocation and Available-to-Promise

Inventory distinguishes:

- Demand: requested Product/quantity/date from Sales
- Reservation: temporary protection of uncommitted availability
- Allocation: committed quantity, normally to a specific lot and location
- Pick: warehouse confirmation of removed stock
- Shipment: ownership/availability reduction at the defined shipping event

Allocation considers Product status, Customer rules, stock status, remaining shelf life, FEFO/FIFO, unit conversion, split-pack policy, location, and requested delivery date.

Concurrent orders cannot allocate the same quantity. Expired reservations release automatically under controlled rules. Allocation substitution requires Sales approval and Product substitution policy.

## 13. Transfers and Replenishment

Internal transfers preserve Product, lot, pallet, status, ownership, and quantity unless an authorized status change occurs. Transfers may move reserve stock to picking slots, between temperature zones, to staging, or to disposition areas.

Picking-slot replenishment is triggered by demand, minimum/maximum levels, or supervisor direction. It respects location capacity, compatibility, rotation, and current lot-depletion rules.

## 14. Holds, Recall, and Disposition

A hold records scope, type, reason, effective time, initiating Principal, approval, and release conditions. Scope may be Product, Supplier/manufacturer lot, PFD lot, pallet, location, or specific quantity.

Hold placement immediately prevents new allocation and picking. Existing allocations are identified for review. Quality controls Quality and Recall Holds.

Disposition options include release, rework/repack where permitted, return to Supplier, donation, destruction, or other approved write-off. Physical and financial consequences reference the same disposition decision.

## 15. Customer Returns

Returned goods do not reenter `AVAILABLE` inventory automatically. They enter a controlled return/quarantine location and status with Customer, shipment, Product, lot when known, quantity, condition, temperature concern, reason, and evidence.

Quality/Operations determines restock, hold, return, or disposal. Original lot identity is preserved when verified; otherwise a controlled traceability decision is required.

## 16. Physical Counts

Count programs include cycle counts, location counts, Product/lot counts, and full physical inventory.

The system records count scope, freeze/snapshot time, expected quantity protected from counters when blind counting is required, count teams, first/recount quantities, variances, investigation, approval, and resulting adjustment.

No count overwrites a balance. An approved adjustment transaction explains the difference. Material adjustments require separation between counter and approver.

## 17. Adjustments

Adjustment reasons include receiving correction, count variance, damage, expiration, unit-conversion correction, status correction, and approved administrative correction.

An adjustment requires source evidence, quantity, value impact supplied to Finance, responsible Principal, reason, and authority. Backdating that would invalidate closed operational or accounting periods is prohibited; correcting events use current posting with appropriate business reference.

## 18. Cost and Finance Boundary

Inventory retains source cost facts by accepted receipt/lot and quantity consumption so Finance can value inventory consistently. Finance owns costing policy, General Ledger, period close, reserves, and write-off accounting.

Quantity events and accounting events are linked but not collapsed. Inventory cannot change cost to force a financial balance; Finance cannot change physical quantity to force an accounting balance. Reconciliation reports expose differences.

## 19. Purchasing Interface

Inventory supplies projected available quantity, safety stock, open demand, allocations, expiration exposure, and usable inbound quantities to replenishment planning. Purchasing supplies open PO quantities and expected dates.

Accepted Receipt increases on hand; an open PO does not. Rejected/quarantined Receipt quantities are visible but unavailable.

## 20. Logical Structures

| Structure | Natural primary key |
|---|---|
| Inventory Lot | `inventory_lot_number` |
| Lot Date | `inventory_lot_number + date_type_code` |
| Pallet | `pallet_number` |
| Pallet Composition | `pallet_number + product_number + inventory_lot_number + effective_from` |
| Inventory Balance | Product + lot + pallet + location + status + ownership |
| Inventory Transaction | `inventory_transaction_number` |
| Inventory Transaction Line | transaction number + line number |
| Picking-Slot Placement | location + Product + lot + pallet + placed-at |
| Reservation | `inventory_reservation_number` |
| Allocation | `inventory_allocation_number` |
| Hold | `inventory_hold_number` |
| Disposition | `inventory_disposition_number` |
| Transfer Request | `inventory_transfer_number` |
| Physical Count | `physical_count_number` |
| Physical Count Line | count number + line number |
| Inventory Adjustment | `inventory_adjustment_number` |
| Inventory Cost Source | lot + accepted Receipt line |

## 21. Integrity and Reconciliation

- Sum of transaction lines equals the balance movement.
- Transfers balance source and destination quantities.
- Allocation never exceeds eligible on hand.
- Pick never exceeds allocation without authorized exception.
- Shipment never exceeds picked/staged quantity.
- Return/disposition never exceeds eligible quantity.
- Lot/date requirements follow Product policy.
- Location/temperature compatibility is enforced.
- Inventory balance reconciles to immutable transactions.
- Inventory quantity reconciles to Finance inventory control accounts by period.
- All reversals reference the original transaction and use new events.

## 22. Responsibilities

| Decision | Responsibility |
|---|---|
| Receipt quantity/condition | Warehouse; Quality for acceptance restrictions |
| Lot/date capture | Warehouse with system validation |
| Putaway/movement/pick | Warehouse |
| Allocation | Sales/Inventory rules |
| Quality or Recall Hold | Quality |
| Count execution | Warehouse |
| Adjustment approval | Operations; Finance review for material value |
| Disposition | Quality/Operations; Finance for value treatment |
| Costing/accounting | Finance |

## 23. Reports

- On hand, allocated, available, held, and damaged inventory
- Inventory by Product, lot, pallet, location, status, and ownership
- Expiration and remaining-life exposure
- FEFO/FIFO exceptions
- Picking slots containing multiple lots
- Lot/pallet picking-slot dwell time
- Negative/invalid balance exceptions
- Open reservations, allocations, transfers, and holds
- Count accuracy and adjustment history
- Recall traceability from receipt through shipment
- Slow-moving, obsolete, and excess inventory
- Quantity-to-General-Ledger reconciliation

## 24. Security and Audit

Warehouse executes movements but cannot release Quality Holds or approve material adjustments. Quality controls safety status. Sales allocates only through controlled services. Finance reads quantity/cost evidence and controls financial posting.

Inventory transactions and audit events are append-only. Protected write functions require active Principal, authority, expected row version, reason, and correlation to source documents. `PUBLIC` receives no domain access.

## 25. Remaining Configuration

Opening stock, physical warehouse locations, location capacity, replenishment minimums, count classes/frequency, material adjustment thresholds, reservation expiration, costing method, and disposition approval thresholds are configuration—not unresolved architecture.

## 26. Next Step

Next design deliverable: **PFD Inventory PostgreSQL Build Specification**. It will define normalized tables, business keys, constraints, indexes, functions, privileges, verification, and tests without producing executable SQL.
