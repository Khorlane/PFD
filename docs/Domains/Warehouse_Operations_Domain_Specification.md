# Warehouse Operations Domain Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Design baseline  
**Depends on:** Product, Supplier/Purchasing, and Inventory designs

## 1. Purpose

Define how the business schedules and executes receiving, inspection, putaway, replenishment, picking, staging, loading, counting, and warehouse exception work. This is business and logical-data design, not PostgreSQL implementation.

## 2. Facility and Scope

The initial warehouse operates at **\<business address>**.

Warehouse Operations owns:

- Physical warehouse layout and location capability
- Dock and appointment capacity
- Receiving execution and condition observations
- Putaway and internal movement execution
- Slotting and picking-slot replenishment
- Work waves, assignments, picking, staging, and loading
- Warehouse equipment and labor availability
- Operational exceptions and productivity facts

Inventory owns quantities, lots, pallets, status, allocation, holds, and adjustments. Purchasing owns PO commitments and Supplier discrepancies. Transportation owns routes, vehicles, dispatch, and delivery. Quality owns safety acceptance and Quality/Recall Holds.

## 3. Operating Schedule

### 3.1 Standard Shifts

| Day | First shift, 7 AM–3 PM | Second shift, 3 PM–11 PM | Third shift, 11 PM–7 AM |
|---|---|---|---|
| Sunday | Not staffed | Preparation and early picking/loading | Primary picking/loading |
| Monday–Thursday | Receiving and inventory control | Preparation and early picking/loading | Primary picking/loading |
| Friday | Receiving and inventory control | Not staffed | Not staffed |
| Saturday | Not staffed | Not staffed | Not staffed |

First shift is normally light staffing, second shift medium staffing, and third shift full staffing. Exact headcount is a capacity plan, not a permanent design value.

Sunday work begins the fulfillment cycle for Friday orders delivering Monday. Order activity normally occurs Monday–Friday, 8 AM–4 PM; 4–5 PM is final validation, exception resolution, and release preparation.

Holiday or emergency schedules require an approved effective-dated exception. The calendar determines the actual operating day; weekday assumptions are not hardcoded into transactions.

## 4. Governing Decisions

1. Supplier and carrier arrivals require scheduled appointments.
2. Warehouse work is directed, timestamped, and assigned; material activity is not reconstructed from end-of-day totals.
3. Every receipt records actual Product, unit, quantity, lot/date, temperature, and condition facts.
4. Nonconforming stock is segregated and unavailable pending disposition.
5. Putaway validates location capacity, temperature, compatibility, and Product policy.
6. Picking uses the Inventory allocation and FEFO/FIFO sequence.
7. Multiple lots may share a picking slot; one lot is depleted before the next unless an authorized override is recorded.
8. The date/time each lot or pallet enters and leaves a picking slot is retained.
9. Split-pack picking is permitted only where authorized and remains undesirable as a normal practice.
10. The warehouse does not weigh an item, determine its selling price, send that price to the office, or revise the truck invoice.
11. Loading verifies the correct route, stop, customer, temperature zone, handling unit, and quantity.
12. Reversals and corrections create linked events; posted work history is not overwritten.
13. Simulation uses the same warehouse work and Inventory records as normal operation.

## 5. Warehouse Layout

The location hierarchy supports:

- Facility
- Temperature/operating zone
- Aisle
- Rack or floor area
- Level
- Position/bin

Opening location purposes:

- Receiving dock and receiving stage
- Ambient reserve and picking
- Refrigerated reserve and picking
- Frozen reserve and picking
- Outbound staging
- Quarantine and Quality Hold
- Damage and returns
- Supplier-return staging
- Disposal staging

Each location has a permanent Warehouse Location Code, capacity, supported storage class, pickability, replenishment method, access restrictions, and active status. Location codes are never reused.

## 6. Dock and Capacity Management

Each dock records inbound/outbound capability, vehicle restrictions, temperature access, operating calendar, and capacity. Appointments reserve dock/time capacity but do not prove arrival.

Warehouse may confirm, reschedule, refuse, or exceptionally accept an unscheduled arrival. Every deviation records reason, responsible Principal, and Supplier/carrier impact.

Capacity planning considers expected pallets/cases, unloading method, labor, equipment, temperature class, inspection requirements, and competing outbound work.

## 7. Receiving

Receiving begins with arrival/check-in and ends when all quantities are accepted, quarantined, rejected, or otherwise resolved for warehouse control.

Steps:

1. Validate appointment, Supplier/carrier, PO, seal, and delivery documents.
2. Record arrival, dock assignment, unload start/end, and departure.
3. Identify Product and ordered unit.
4. Count actual quantity without altering the PO.
5. Capture Supplier/manufacturer lot and required Product dates.
6. Record temperature and condition where required.
7. Compare Product, quantity, unit, shelf life, and documentation to PO/Product policy.
8. Assign accepted, quarantined, or rejected disposition.
9. Create Inventory receipt/lot/pallet events.
10. Create putaway work for accepted or segregated stock.

Partial receipt, overage, shortage, damage, wrong Product, date failure, temperature failure, and missing documentation remain explicit line-level facts.

## 8. Inspection and Quality Boundary

Warehouse records observable facts; Quality decides safety acceptance when policy or exception requires it. Required inspections may include temperature, packaging integrity, contamination, seal, lot/date, certification, and sample results.

Failed or uncertain stock moves to quarantine/hold. It cannot be allocated, picked, substituted, or blended with available stock. Quality release or disposition uses a controlled event.

## 9. Putaway

Putaway work identifies receipt/lot/pallet, quantity, source staging location, recommended destination, priority, equipment, and handling constraints.

The worker confirms actual destination and completion time. A different destination requires validation and, for material exceptions, a reason.

Putaway cannot exceed accepted quantity. It posts an Inventory movement atomically and records location placement. Temperature-incompatible or capacity-exceeding destinations are rejected.

## 10. Slotting

Slotting assigns Products to picking locations using velocity, cube, weight, temperature, compatibility, ergonomics, replenishment frequency, and split-pack needs.

A Product may have multiple approved pick slots, but one is identified as primary per storage class where practical. Slot changes are effective-dated. Reserve inventory remains distinguishable from pick-slot inventory.

## 11. Picking-Slot Replenishment

Replenishment may be demand-driven, minimum/maximum driven, or supervisor initiated. It selects eligible reserve stock using FEFO/FIFO and Product lot policy.

Completion records Product, lot, pallet, quantity, source/destination, placed-at time, worker/equipment, and rotation rank. If multiple lots occupy the slot, the active depletion sequence is clear.

## 12. Wave and Work Planning

Released Sales Orders are grouped into warehouse waves based on delivery date, route, temperature zone, cutoff, priority, equipment, and labor capacity.

A wave produces directed work such as replenishment, case pick, split-pack pick, pallet pick, staging, loading, count, or exception review. Work has priority, required completion, assigned shift, worker/team, status, dependencies, and timestamps.

The system may optimize sequence, but supervisors can reassign work with reason. No task is considered complete solely because its planned time passed.

## 13. Picking

The picker receives Product, unit, quantity, lot/location/pallet allocation, and destination staging reference. Confirmation records actual facts.

Controls include:

- Scan/verify location, Product, lot, and handling unit where identifiers exist
- Enforce allocated quantity and unit conversion
- Enforce FEFO/FIFO and remaining-life requirements
- Prevent held, damaged, expired, or quarantined stock
- Record short pick, over pick, damage, substitution request, and rotation override
- Post Inventory Pick transaction atomically

A short pick does not silently reduce the customer order. It creates an exception for Sales/Inventory resolution.

## 14. Split-Pack Work

Split-pack picking is allowed only for Products/units configured to permit it and Customer requirements that accept it. Work validates minimum quantity, increment, sanitation, traceability, labeling, repacking, and possible charge.

The original lot remains traceable. The process does not introduce catch-weight pricing. Repeated split demand should trigger commercial review because full packs/cases are preferred.

## 15. Staging

Picked goods are staged by route, stop, customer, temperature class, and load sequence. Staging records handling unit, Product/lot content, location, arrival/removal times, readiness, exceptions, and responsible Principal.

Ambient, refrigerated, frozen, food/nonfood, allergen, chemical, and security separation rules remain in force. A staged quantity is not shipped until load confirmation.

## 16. Loading

Loading requires an approved route/vehicle assignment from Transportation. Warehouse verifies:

- Vehicle and route
- Stop/customer association
- Handling unit and seal where used
- Product/lot/quantity
- Temperature zone
- Load sequence and weight/cube limits
- Required paperwork and proof-of-load

Load confirmation posts movement to truck/staged-for-shipment state. Shipment confirmation timing and ownership transfer follow Sales/Transportation/Finance policy. A load correction uses a reversal or new event.

## 17. Warehouse Exceptions

Exception types include appointment, receiving, putaway, capacity, inventory mismatch, replenishment, short/over pick, wrong Product/lot, damage, temperature, staging, loading, equipment, and labor exceptions.

Every exception has severity, source work/document, owner, opened time, required resolution time, status, evidence, resolution, and escalation. Safety/traceability exceptions stop affected work immediately.

## 18. Counts and Reconciliation

Warehouse executes blind counts, recounts, cycle counts, and physical inventory directed by Inventory. Counters record observed Product, lot, pallet, location, status, and quantity.

Warehouse cannot overwrite Inventory Balance. Variances flow to investigation and approved Inventory Adjustment. Material differences use separate counter and approver.

## 19. Labor, Equipment, and Safety

Warehouse maintains shift assignments, worker qualifications, equipment availability, and task eligibility. Equipment includes forklifts, pallet jacks, scanners, dock equipment, and temperature devices.

Only qualified workers receive controlled equipment or restricted-area tasks. Safety incidents are referenced to the responsible work but owned by HR/Safety processes. Productivity measurement must not encourage bypassing food-safety, count, or scan controls.

## 20. Logical Structures

| Structure | Natural primary key |
|---|---|
| Warehouse Facility | `warehouse_code` |
| Warehouse Zone | `warehouse_code + zone_code` |
| Warehouse Location | `warehouse_location_code` |
| Dock | `warehouse_code + dock_code` |
| Operating Shift | `warehouse_code + shift_code + effective_from` |
| Inbound Arrival | `arrival_number` |
| Receipt | `receipt_number` |
| Receipt Line | receipt number + line number |
| Receipt Lot/Date | receipt line + lot/date type |
| Inspection | `inspection_number` |
| Putaway Task | `warehouse_task_number` |
| Product Slot Assignment | Product + location + effective-from |
| Replenishment Task | `warehouse_task_number` |
| Warehouse Wave | `warehouse_wave_number` |
| Wave Order | wave number + Sales Order number |
| Pick Task | `warehouse_task_number` |
| Pick Confirmation | task number + confirmation sequence |
| Staging Unit | `staging_unit_number` |
| Staging Unit Content | staging unit + Product + lot |
| Load Confirmation | route/load number + confirmation sequence |
| Warehouse Exception | `warehouse_exception_number` |
| Worker Shift Assignment | warehouse + shift occurrence + worker number |
| Equipment | `warehouse_equipment_number` |

## 21. Integrity Rules

- Receipt quantities reconcile to accepted, quarantined, and rejected disposition.
- Putaway cannot exceed accepted Receipt quantity.
- Task confirmation cannot exceed open task quantity without authorized exception.
- Location capacity and compatibility are checked before placement.
- Pick confirmation matches an active Inventory allocation.
- Staged content reconciles to picked content.
- Loaded content reconciles to staged content and route assignment.
- Every lot/pallet placement has a start and eventual removal/depletion time.
- Posted confirmations are immutable; corrections reference originals.
- Warehouse and Inventory events commit together where one action affects both.

## 22. Responsibilities

| Decision | Responsibility |
|---|---|
| Appointment/dock acceptance | Operations/Warehouse |
| Receipt observation | Receiving worker |
| Safety acceptance/hold | Quality |
| Putaway/slotting/replenishment | Warehouse supervision |
| Allocation | Inventory/Sales rules |
| Pick/stage/load execution | Warehouse |
| Route/vehicle/dispatch | Transportation |
| Count adjustment approval | Operations with Finance review when material |

## 23. Reports and Measures

- Appointment schedule, arrival compliance, and dock utilization
- Receiving volume, accuracy, damage, and dwell time
- Putaway cycle time and open work
- Location utilization and compatibility exceptions
- Pick-slot replenishment and stockouts
- Picking accuracy, shorts, overrides, and productivity
- Multiple-lot slots and lot dwell time
- Staging dwell time and load readiness
- Loading accuracy and departure readiness
- Open exceptions by severity/age
- Count accuracy and adjustment trends
- Work by shift, worker/team, and equipment

## 24. Security and Audit

Workers execute assigned tasks through controlled services. Supervisors assign/reassign work and approve ordinary exceptions. Quality controls Quality/Recall decisions. Warehouse cannot alter PO terms, Customer orders, Inventory balances, routes, invoices, or GL entries directly.

Receipt observations, work confirmations, exceptions, reversals, and audit events are append-only. `PUBLIC` receives no domain access.

## 25. Simulation

Simulation creates ordinary appointments, receipts, tasks, waves, picks, staging, loads, and exceptions according to the operating calendar and staffing/capacity rules. It does not create parallel warehouse masters or add simulation identifiers to operational keys.

## 26. Remaining Configuration

The exact floor plan, location codes/capacities, dock count, equipment roster, staffing headcount, productivity standards, wave size, replenishment thresholds, scan hardware, and holiday exceptions are configuration—not unresolved architecture.

## 27. Next Step

Next design deliverable: **Warehouse Operations PostgreSQL Build Specification**. It will define normalized structures, natural keys, constraints, functions, privileges, verification, and tests without executable SQL.
