# Warehouse Operations PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0057`–`0068`  
**Depends on:** Cumulative design through `0056`; Warehouse Operations Domain Specification

## 1. Purpose

Define the PostgreSQL structures and controls for warehouse calendars, docks, arrivals, receiving execution, inspection observations, putaway, slotting, replenishment, waves, directed work, picking, staging, loading, counting support, labor/equipment eligibility, exceptions, reporting, and audit. This remains design only.

## 2. Required Outcome

- Warehouse work is scheduled, directed, assigned, and timestamped.
- Purchasing appointments and Inventory locations are extended, not duplicated.
- Receipt observations remain distinct from purchasing commitments and Quality decisions.
- Every completed material movement posts the related Inventory transaction atomically.
- FEFO/FIFO, remaining-life, location compatibility, and one-lot-at-a-time depletion are enforced.
- Multiple lots may occupy one picking slot with explicit placement and rotation order.
- Split-pack work is controlled and traceable but not the preferred fulfillment method.
- Warehouse catch-weight pricing and price-at-weigh processing are prohibited.
- Posted confirmations and events are immutable and corrected by reversal.
- No surrogate, identity, serial, UUID, or hidden substitute keys are used.
- Simulation uses ordinary operational tables.

## 3. Platform and Package

PostgreSQL 15 or later; existing `core`, `product`, `purchasing`, `inventory`, `warehouse`, `quality`, `sales`, `transportation`, `audit`, and `reporting` schemas; cumulative manifest `6.0.0`; immutable changes `0001`–`0056`; transactional changes `0057`–`0068` through the standard runner.

The package may reference future Sales and Transportation business keys before those domains are physically installed only through documented deferred constraints. Those constraints become mandatory when the owning package is built.

## 4. Standards

Use lowercase `snake_case`, uppercase governed codes, `numeric(19,6)` quantities, `numeric(19,4)` weights/capacities, `date` for business dates, and `timestamptz` for events and effective periods. Mutable rows use standard Principal/timestamp audit columns and positive `row_version`. Execution confirmations, status history, and audit events are append-only.

Natural business numbers or governed composite keys are primary keys. Foreign keys carry the complete natural key. Nullable business references remain non-key attributes; fake values are prohibited.

## 5. Controlled Numbers

Change `0057` adds:

| Sequence | Example |
|---|---|
| `WAREHOUSE_ARRIVAL` | `ARR00000001` |
| `WAREHOUSE_RECEIPT` | `REC00000001` |
| `WAREHOUSE_WORK` | `WRK0000000001` |
| `WAREHOUSE_WAVE` | `WAV00000001` |
| `HANDLING_UNIT` | `HUN00000001` |
| `OUTBOUND_LOAD` | `LOD00000001` |
| `WAREHOUSE_EXCEPTION` | `WEX00000001` |
| `WAREHOUSE_AUDIT_EVENT` | `WAE0000000001` |

Numbers use the Core allocation service, are permanent, and are never reused. Receipt line, work step, wave line, handling-unit content, and load line use parent business number plus governed line number.

## 6. Reference Data

| Reference | Opening codes |
|---|---|
| Location purpose | `RECEIVING_DOCK`, `RECEIVING_STAGE`, `AMBIENT_RESERVE`, `AMBIENT_PICK`, `REFRIGERATED_RESERVE`, `REFRIGERATED_PICK`, `FROZEN_RESERVE`, `FROZEN_PICK`, `OUTBOUND_STAGE`, `QUARANTINE`, `DAMAGE`, `RETURN_STAGE`, `DISPOSAL_STAGE` |
| Work type | `RECEIVE`, `INSPECT`, `PUTAWAY`, `REPLENISH`, `PALLET_PICK`, `CASE_PICK`, `SPLIT_PACK_PICK`, `STAGE`, `LOAD`, `COUNT`, `EXCEPTION_REVIEW` |
| Work status | `PLANNED`, `READY`, `ASSIGNED`, `IN_PROGRESS`, `BLOCKED`, `COMPLETED`, `CANCELLED`, `REVERSED` |
| Arrival status | `SCHEDULED`, `CHECKED_IN`, `AT_DOCK`, `UNLOADING`, `COMPLETED`, `REFUSED`, `NO_SHOW`, `CANCELLED` |
| Receipt disposition | `ACCEPTED`, `QUARANTINED`, `REJECTED` |
| Wave status | `PLANNED`, `RELEASED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED` |
| Exception severity | `INFORMATIONAL`, `WARNING`, `WORK_STOP`, `CRITICAL` |
| Exception type | `APPOINTMENT`, `RECEIVING`, `QUALITY`, `PUTAWAY`, `CAPACITY`, `INVENTORY_MISMATCH`, `REPLENISHMENT`, `SHORT_PICK`, `OVER_PICK`, `WRONG_PRODUCT`, `WRONG_LOT`, `DAMAGE`, `TEMPERATURE`, `STAGING`, `LOADING`, `EQUIPMENT`, `LABOR` |
| Confirmation result | `CONFIRMED`, `SHORT`, `OVER`, `DAMAGED`, `REJECTED`, `REVERSED` |

Reference tables follow the Core active/effective/audit pattern.

## 7. Facility, Zones, Locations, and Docks

`warehouse.facility` uses `warehouse_code` as PK and stores name, address reference, time zone, operating status, and audit columns. Opening facility configuration identifies \<business address>.

`warehouse.zone` PK `warehouse_code + zone_code`; stores temperature/storage class, operating purpose, separation attributes, and active status.

The existing `warehouse.location` retains `warehouse_location_code` as PK. This package adds facility/zone references, aisle/rack/level/bin descriptors, purpose, capacity basis, replenishment method, access restrictions, and effective status without changing its key.

`warehouse.dock` PK `warehouse_code + dock_code`; stores inbound/outbound capability, temperature access, vehicle restrictions, and capacity. Location and dock codes are never reused.

## 8. Calendar, Shifts, and Capacity

`warehouse.operating_shift` PK `warehouse_code + shift_code + effective_from`; stores start/end local times, staffing class, operating purposes, and effective period.

Opening shifts are First 7 AM–3 PM, Second 3 PM–11 PM, and Third 11 PM–7 AM. `warehouse.operating_calendar` PK `warehouse_code + operating_date + shift_code`; records open/closed status, capacity adjustment, exception reason, and approval.

The calendar seeds the standard Sunday-through-Friday rhythm from the Domain Specification while permitting approved holiday/emergency exceptions. Capacity views combine docks, shifts, staffing, equipment, and scheduled appointments; they do not manufacture transactional facts.

## 9. Appointment Integration and Arrival

Purchasing remains owner of `purchasing.inbound_appointment`. Warehouse references its natural key and records execution separately.

`warehouse.inbound_arrival` uses `arrival_number` as PK and stores appointment number, Supplier/carrier, PO, check-in, dock assignment, seal/document observations, unload start/end, departure, status, and audit data.

An appointment can have multiple arrival attempts, but only one active dock occupancy. An unscheduled arrival requires an exception and supervisor authorization. Dock/time exclusion constraints prevent conflicting active occupancy beyond configured capacity.

## 10. Receipt and Receipt Lines

`warehouse.receipt` PK `receipt_number`; stores arrival, PO, Supplier/carrier, receiving start/end, overall status, responsible shift/team, and audit data.

`warehouse.receipt_line` PK `receipt_number + receipt_line_number`; stores PO line, Product, ordered and received unit, stated/observed quantities, base-unit conversion evidence, and line status.

`warehouse.receipt_lot_date` PK `receipt_number + receipt_line_number + supplier_lot_code + lot_date_type_code`. When a Supplier lot is not required, a separate `warehouse.receipt_line_date` keyed by receipt line plus date type avoids a fabricated Supplier lot.

Accepted, quarantined, and rejected quantities must reconcile to observed quantity. Receipt facts never revise the PO or Supplier acknowledgment.

## 11. Inspection Observations and Disposition

`warehouse.receipt_observation` PK `receipt_number + receipt_line_number + observation_type_code + observation_sequence`; stores measured/observed value, unit, acceptable range, device, observation time, Principal, evidence reference, and result.

Temperature, packaging, seal, contamination, documentation, certification, lot/date, and count observations remain warehouse facts. `warehouse.receipt_disposition` PK `receipt_number + receipt_line_number + disposition_sequence`; stores quantity, disposition, reason, Quality decision reference where required, decision Principal/time, and resulting Inventory transaction.

Warehouse may record and segregate uncertainty. Only Quality may release a Quality or Recall Hold.

## 12. Directed Work

`warehouse.work` uses `warehouse_work_number` as PK and stores work type, source document/line, warehouse, priority, required completion, assigned shift, status, current assignment, dependency state, and row version.

`warehouse.work_step` PK `warehouse_work_number + step_number`; stores planned source/destination, Product, lot, pallet, handling unit, quantity/unit, equipment/qualification requirements, and status.

`warehouse.work_dependency` PK `warehouse_work_number + predecessor_work_number`; cycles are rejected. `warehouse.work_assignment_history` PK work number + assigned-at; records worker/team, assigning Principal, reason, accepted/start/end times, and outcome.

Completion requires explicit confirmation; elapsed planned time never completes work.

## 13. Putaway

Putaway work references the Receipt, Inventory Lot, optional Pallet, source staging location, recommended destination, quantity, priority, and constraints. `warehouse.putaway_confirmation` PK `warehouse_work_number + confirmation_sequence`; records actual destination, quantity, time, Principal/equipment, variance reason, and Inventory transaction.

Confirmation validates accepted quantity, location capacity, storage class, temperature, compatibility, and hold status. The confirmation and Inventory movement commit together.

## 14. Slotting and Replenishment

`warehouse.product_pick_slot` PK `product_number + warehouse_location_code + effective_from`; stores storage class, primary flag, minimum/maximum base quantity, replenishment method, pick unit, split-pack authorization, priority, and effective period.

Only one primary active slot per Product/storage class is permitted. Effective rows cannot overlap.

Replenishment work selects eligible reserve stock through Inventory FEFO/FIFO rules. Completion calls the existing Inventory picking-slot placement process, preserves placed-at time and rotation rank, and records the Warehouse confirmation. Multiple lots are allowed; depletion proceeds one lot at a time unless an authorized rotation override is recorded.

## 15. Waves

`warehouse.wave` PK `warehouse_wave_number`; stores delivery date, warehouse, route reference when available, temperature class, cutoff, priority, release/completion times, status, and audit data.

`warehouse.wave_demand` PK `warehouse_wave_number + demand_document_type_code + demand_document_number + demand_line_number`; connects released demand without copying Sales detail.

`warehouse.wave_work` PK `warehouse_wave_number + warehouse_work_number`. Wave release validates demand release status, Inventory allocation, calendar, labor/equipment capacity, and staging availability.

## 16. Picking

Picking work carries the Inventory Allocation natural key and directed Product, lot, location, pallet/handling unit, unit, quantity, and staging destination.

`warehouse.pick_confirmation` PK `warehouse_work_number + confirmation_sequence`; stores actual Product, lot, location, pallet, handling unit, quantity/unit, result, scan evidence, time, Principal, reason/approval, and Inventory transaction.

Completion enforces FEFO/FIFO, remaining life, allocation, unit conversion, increment, and eligible status. A short pick opens an exception and does not silently reduce Sales demand. Over-pick, wrong Product/lot, held stock, and negative stock are rejected.

## 17. Split-Pack Work

`warehouse.split_pack_confirmation` PK `warehouse_work_number + confirmation_sequence`; stores original Product/lot/container, picked base quantity, resulting unit/quantity, sanitation/label verification, traceability label, waste, charge reference if applicable, and Principal/time.

Split-pack requires Product and pick-slot authorization, valid increments, and preserved lot traceability. No weight-derived selling price or warehouse-to-invoice price field exists. Repeated split-pack demand is exposed for commercial review.

## 18. Handling Units and Staging

`warehouse.handling_unit` PK `handling_unit_number`; stores type, warehouse, current location/status, route/stop/customer references, temperature class, parent handling unit where permitted, created/closed times, and audit data.

`warehouse.handling_unit_content` PK `handling_unit_number + content_line_number`; stores Product, Inventory Lot, optional Pallet, quantity/unit, source pick work, and effective status. Content must reconcile to confirmed picks less removals/reversals.

`warehouse.staging_event` PK `handling_unit_number + event_time + event_type_code`; stores source/destination, route/stop, readiness, temperature/segregation result, Principal, and work reference. Only one current physical location is allowed.

## 19. Outbound Loading

`warehouse.outbound_load` PK `outbound_load_number`; stores warehouse, route/vehicle assignment references, planned/actual load times, temperature zones, seal, readiness, status, and audit data. Transportation remains owner of routes, vehicles, dispatch, and delivery.

`warehouse.outbound_load_stop` PK load number + stop sequence; stores route stop/customer references and required load sequence. `warehouse.outbound_load_content` PK load number + handling unit number; records verified placement, stop, temperature zone, loaded/reversed time, Principal, and proof reference.

Load confirmation validates route, stop, customer, vehicle restrictions, temperature, cube/weight limits, required paperwork, and handling-unit content. Loading movement and Inventory shipment/staged-for-shipment event commit atomically according to the later Sales/Transportation policy.

## 20. Exceptions

`warehouse.exception` uses `warehouse_exception_number` as PK and stores type, severity, source document/work, owner, opened/required-resolution times, status, evidence, escalation, resolution, and audit data.

`warehouse.exception_history` PK exception number + event time + event type; is append-only. Work-stop and critical safety/traceability exceptions block affected work until an authorized resolution is recorded. Resolution never erases the originating observation or confirmation.

## 21. Labor, Qualifications, and Equipment

`warehouse.worker_qualification` PK `principal_code + qualification_code + effective_from`; records certification, restrictions, expiry, and verification. It does not duplicate HR identity.

`warehouse.shift_assignment` PK `warehouse_code + operating_date + shift_code + principal_code`; stores role/team and availability.

`warehouse.equipment` PK `warehouse_code + equipment_code`; stores type, capability, status, inspection requirement, and active status. `warehouse.equipment_status_event` PK warehouse/equipment + event time; records availability and safety state.

Task assignment validates required qualification, shift availability, equipment capability, and restricted-area authority.

## 22. Counts and Inventory Boundary

Inventory owns Physical Count, Count Line, variance, Adjustment, and balance. Warehouse Work references the Inventory Physical Count natural key and directs blind count/recount execution.

Warehouse count confirmation records observed Product, lot, pallet, location, status, quantity, counter, and time through the Inventory controlled count function. Warehouse cannot overwrite expected quantity, Inventory Balance, variance approval, or Adjustment.

## 23. Controlled Functions

Required transaction-safe functions:

- `record_inbound_arrival(...) returns arrival_number`
- `start_and_complete_unloading(...)`
- `create_warehouse_receipt(...) returns receipt_number`
- `record_receipt_observation(...)`
- `record_receipt_disposition(...)`
- `create_warehouse_work(...) returns warehouse_work_number`
- `assign_or_reassign_work(...)`
- `start_or_block_work(...)`
- `confirm_putaway(...)`
- `configure_product_pick_slot(...)`
- `confirm_replenishment(...)`
- `create_and_release_wave(...) returns warehouse_wave_number`
- `confirm_pick(...)`
- `confirm_split_pack(...)`
- `create_or_update_handling_unit(...)`
- `confirm_staging(...)`
- `create_outbound_load(...) returns outbound_load_number`
- `confirm_load_or_reversal(...)`
- `open_or_resolve_warehouse_exception(...)`
- `record_equipment_status(...)`

Functions validate Principal/authority, lock rows deterministically, check row versions, enforce domain policies, call Inventory functions where quantities change, use safe `search_path`, and deny `PUBLIC` execution.

## 24. Integrity, Concurrency, and Reconciliation

- Appointment, dock occupancy, shift, and equipment conflicts use effective-time constraints.
- Work dependencies are acyclic; only eligible work becomes Ready.
- Receipt dispositions reconcile to observed quantity.
- Putaway, replenishment, pick, staging, and load confirmations cannot exceed eligible quantity.
- Warehouse confirmation and Inventory transaction commit or roll back together.
- Handling-unit content reconciles to pick, staging, and load events.
- One handling unit, pallet, or equipment item cannot occupy conflicting current locations/statuses.
- FEFO/FIFO and active-lot depletion use deterministic locking.
- Posted confirmations, status history, exception history, and audit events reject update/delete.
- Corrections use linked reversal events.

## 25. Audit

`audit.warehouse_event` PK `warehouse_audit_event_number`; records event type/time, Principal, facility/location/dock, work, Receipt, Product/lot/pallet/handling unit, source document, Inventory transaction, reason/approval, correlation, and sanitized `jsonb` summary. It is append-only and supplements rather than replaces operational facts.

## 26. Indexes and Views

Indexes support active appointments/arrivals by dock/time; open Receipts and observations; ready/assigned/blocked work by shift/priority; source document lookup; pick slots and replenishment; FEFO work; waves by delivery/route; handling units by location/route/stop; load readiness; open exceptions; worker qualifications; equipment availability; and audit correlation.

Required views:

- `reporting.warehouse_operating_calendar`
- `reporting.warehouse_dock_schedule`
- `reporting.warehouse_arrival_compliance`
- `reporting.warehouse_receiving_status`
- `reporting.warehouse_receiving_exception`
- `reporting.warehouse_open_work`
- `reporting.warehouse_putaway_cycle_time`
- `reporting.warehouse_pick_slot_replenishment`
- `reporting.warehouse_pick_accuracy`
- `reporting.warehouse_split_pack_demand`
- `reporting.warehouse_staging_readiness`
- `reporting.warehouse_load_readiness`
- `reporting.warehouse_open_exception`
- `reporting.warehouse_shift_productivity`
- `reporting.warehouse_inventory_reconciliation`

## 27. Privileges

`pfd_database_owner` owns objects; `pfd_change_executor` assumes ownership only during approved builds; `pfd_application` reads approved operational data and executes controlled functions; `pfd_reporting` reads approved views; `pfd_support_readonly` receives diagnostic read access; `PUBLIC` receives none.

Warehouse cannot alter PO terms, Sales demand, Inventory Balance, route/vehicle masters, invoices, GL, or Quality/Recall release decisions. Direct application writes to confirmations, history, audit, and number state are prohibited.

## 28. Change Order

| Change | Content |
|---|---|
| `0057` | Add Warehouse business-number sequences and reference data |
| `0058` | Create Facility, Zone, extend Location, and create Dock structures |
| `0059` | Create operating shifts, calendars, and capacity controls |
| `0060` | Create Arrival, Receipt, line, lot/date, observation, and disposition structures |
| `0061` | Create directed Work, steps, dependencies, and assignment history |
| `0062` | Create putaway, slotting, and replenishment confirmations |
| `0063` | Create waves, picking, and split-pack confirmations |
| `0064` | Create Handling Units, content, and staging events |
| `0065` | Create outbound loads, stops, content, and loading verification |
| `0066` | Create exceptions, worker qualifications, shift assignments, and equipment |
| `0067` | Create controlled functions, audit, reconciliation, indexes, and reporting views |
| `0068` | Apply comments, privileges, deferred constraints, and final assertions |

## 29. Verification and Tests

Verification proves contiguous history/checksums through `0068`; required objects/codes; approved natural keys; validated constraints; no surrogate keys; correct extensions to Location/Appointment foundations; append-only confirmations/audit; Inventory atomicity; deferred-constraint inventory; privilege separation; and absence of simulation-session columns.

Disposable tests cover standard/exception calendars; appointment/dock conflict and unscheduled arrival; partial receipt; lot/date and temperature observations; accepted/quarantined/rejected reconciliation; compatible putaway; task dependency/assignment; multi-lot pick slots; replenishment placement time; FEFO/FIFO override; split-pack controls; short pick; handling-unit reconciliation; staging segregation; load/stop verification; reversal; count boundary; qualification/equipment checks; concurrent confirmation; unauthorized access; and ordinary-table simulation.

## 30. Acceptance Criteria

The eventual package must build cleanly and incrementally through `0068`, rerun as a no-op, and pass checksum, behavioral, concurrency, reconciliation, and privilege tests. It must demonstrate controlled scheduled receiving, directed immutable work, exact natural keys, atomic Inventory effects, complete lot/handling-unit traceability, and enforceable operational boundaries.

## 31. Deferred Configuration

Floor plan, location codes/capacities, dock count, equipment roster, staffing headcount, productivity standards, wave size, replenishment thresholds, scan hardware, and holiday exceptions are configuration—not unresolved architecture.

## 32. Next Design Work

Next: **Sales and Order Management Domain Specification**. Executable Warehouse Operations SQL remains deferred until we leave Design Land.
