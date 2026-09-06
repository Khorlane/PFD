# Transportation and Delivery PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0083`–`0098`  
**Depends on:** Cumulative design through `0082`; Transportation and Delivery Domain Specification

## 1. Purpose

Define PostgreSQL structures and controls for vehicles, compartments, operating documents, inspections, maintenance, fuel, drivers, Route Patterns, daily Routes, Stops, appointments, assignments, manifests, dispatch, Deliveries, proof, temperature, exceptions, incidents, returned custody, reporting, and audit. This remains design only.

## 2. Required Outcome

- Six opening owned, financed, multi-temperature trucks are supported; five normally operate routes and one remains a usable spare.
- Truck Number is the permanent primary key; VIN is unique but not the key.
- Unsafe, unavailable, unsuitable, undocumented, or improperly assigned resources cannot dispatch.
- Stable Route Patterns and independently controlled daily Routes coexist.
- Every Route Stop and Delivery has an explicit outcome.
- Loaded, delivered, refused, returned, and unresolved quantities reconcile.
- Temperature, proof, custody, and exception evidence remains complete and immutable.
- Drivers cannot change prices, invoices, credits, Inventory, or Quality decisions.
- No surrogate, identity, serial, UUID, or hidden substitute keys are used.
- Simulation uses ordinary Transportation tables.

## 3. Platform and Package

PostgreSQL 15 or later; existing `core`, `party`, `customer`, `product`, `inventory`, `warehouse`, `quality`, `sales`, `transportation`, `finance`, `audit`, and `reporting` schemas; cumulative manifest `8.0.0`; immutable changes `0001`–`0082`; transactional changes `0083`–`0098` through the standard runner.

Finance, HR/Payroll, and Quality references not yet physically present use governed business references and documented deferred constraints. Their owning packages must validate and activate the constraints.

## 4. Standards

Use lowercase `snake_case`, uppercase governed codes, `numeric(19,6)` quantities, `numeric(19,4)` weight/volume/fuel/monetary values, `numeric(12,3)` distance/odometer values, `date` for business dates, and `timestamptz` for events/effective periods. Coordinates, if retained, use explicit datum/precision metadata.

Mutable rows use standard Principal/timestamp audit columns and positive `row_version`. Events, confirmations, status histories, proof, temperature readings, custody records, and audit rows are append-only.

Natural business numbers/codes or governed composites are primary keys. Foreign keys repeat complete natural keys. Nullable references are not replaced with artificial values.

## 5. Controlled Numbers

Change `0083` adds:

| Sequence | Example |
|---|---|
| `TRUCK` | `TRK000001` |
| `MAINTENANCE_WORK_ORDER` | `MWO00000001` |
| `ROUTE` | `RTE00000001` |
| `DELIVERY` | `DLV00000001` |
| `DELIVERY_EXCEPTION` | `DEX00000001` |
| `TRANSPORTATION_INCIDENT` | `TIC00000001` |
| `OFFLINE_DOCUMENT` | `OFD00000001` |
| `OFFLINE_ENTRY_BATCH` | `OFB00000001` |
| `TRANSPORTATION_AUDIT_EVENT` | `TAE0000000001` |

Core allocation provides permanent, nonreusable values. Parent-relative Stop, line, outcome, proof, appointment, assignment, authorization, and event sequences are governed within the parent transaction.

## 6. Reference Data

| Reference | Opening codes |
|---|---|
| Vehicle operating role | `NORMAL_ROUTE`, `SPARE` |
| Vehicle status | `AVAILABLE`, `ASSIGNED`, `IN_SERVICE`, `MAINTENANCE_DUE`, `OUT_OF_SERVICE`, `UNSAFE`, `RETIRED` |
| Compartment storage class | `AMBIENT`, `REFRIGERATED`, `FROZEN` |
| Document type | `REGISTRATION`, `INSURANCE`, `INSPECTION`, `PERMIT`, `OPERATING_AUTHORITY` |
| Inspection type | `PRE_TRIP`, `POST_TRIP`, `MAINTENANCE_RELEASE`, `SPECIAL` |
| Route status | `PLANNED`, `READY`, `DISPATCHED`, `IN_PROGRESS`, `RETURNED`, `EXCEPTION`, `COMPLETED`, `CLOSED`, `CANCELLED` |
| Delivery status | `PLANNED`, `LOADED`, `DISPATCHED`, `ARRIVED`, `IN_SERVICE`, `COMPLETED`, `EXCEPTION`, `UNDELIVERED`, `CANCELLED`, `CLOSED` |
| Delivery outcome | `ACCEPTED`, `REFUSED`, `SHORT`, `DAMAGED`, `WRONG_PRODUCT`, `TEMPERATURE_REJECTED`, `UNDELIVERED` |
| Route event type | `DEPARTED`, `ARRIVED_STOP`, `SERVICE_STARTED`, `SERVICE_COMPLETED`, `DEPARTED_STOP`, `DELAYED`, `RESEQUENCED`, `RETURNED_FACILITY`, `ROUTE_COMPLETED`, `REVERSED` |
| Exception type | `LATE_DEPARTURE`, `LATE_ARRIVAL`, `MISSED_APPOINTMENT`, `CUSTOMER_UNAVAILABLE`, `ACCESS_SECURITY`, `SHORTAGE`, `REFUSAL`, `WRONG_PRODUCT`, `DAMAGE`, `TEMPERATURE`, `BREAKDOWN`, `ACCIDENT`, `DOCUMENT_POD`, `UNSAFE_CONDITION` |
| Custody event | `CUSTOMER_REFUSAL`, `DRIVER_RETURN`, `CARGO_TRANSFER`, `WAREHOUSE_HANDOFF`, `CUSTODY_REVERSAL` |

Reference tables follow the Core active/effective/audit pattern.

## 7. Vehicle Master

`transportation.vehicle` uses `truck_number` as PK and stores VIN, make, model, model year, ownership code, acquisition/Finance reference, in-service date, home Warehouse, operating role, fuel type, gross/cargo capacities, dimensions, refrigeration capability, odometer basis, lifecycle status, and audit columns.

VIN is required and unique. Truck Number is never reused; a replacement vehicle receives a new number. Opening trucks are configured as five `NORMAL_ROUTE` and one `SPARE`, but dispatch functions may assign any suitable Available truck.

`transportation.vehicle_status_event` PK `truck_number + event_time + vehicle_status_code`; records prior/new status, reason, authority, inspection/maintenance/incident reference, and correlation. Only one current operational status is projected from immutable events.

## 8. Compartments and Vehicle Equipment

`transportation.vehicle_compartment` PK `truck_number + compartment_code + effective_from`; stores effective-to, storage class, setpoint/range, weight/volume/pallet capacity, access sequence, partition arrangement, and active status. Effective rows cannot overlap.

`transportation.vehicle_equipment` PK `truck_number + equipment_code + effective_from`; records type, capability, serial/asset reference where applicable, inspection requirement, installed/removed dates, and status.

`transportation.route_compartment_snapshot` PK `route_number + truck_number + compartment_code`; preserves capacity, temperature, configuration, monitoring device, and assignment used for the Route. Mid-route change creates a new configuration event and affected-cargo review.

## 9. Registration, Insurance, and Authority

`transportation.vehicle_document` PK `truck_number + document_type_code + document_identifier`; stores issuer/jurisdiction, effective/expiration dates, status, verified time/Principal, evidence reference, and applicable territory/cargo scope.

`transportation.driver_document` PK `principal_code + document_type_code + document_identifier`; uses the same effective/verification pattern for driver-controlled documentation.

`transportation.operating_profile` PK `operating_profile_code + effective_from`; stores permitted jurisdictions, vehicle/cargo restrictions, and required document types. `transportation.vehicle_operating_profile` and `transportation.driver_operating_profile` use full parent keys plus effective-from.

Dispatch eligibility views identify missing, expired, unverified, or scope-incompatible evidence, including North Carolina/South Carolina operation.

## 10. Vehicle Inspection and Defects

`transportation.vehicle_inspection` PK `truck_number + inspection_time + inspection_type_code`; stores Route, odometer, refrigeration, tires, brakes, lights, fluids, liftgate, restraints, safety equipment, visible condition, overall result, inspector, and audit evidence.

`transportation.vehicle_inspection_defect` PK vehicle-inspection key + defect_sequence; stores component, severity, description, immediate action, corrective-work reference, and release state.

Safety-critical defects atomically create an `OUT_OF_SERVICE` or `UNSAFE` status event. Dispatchers/drivers cannot release that status. `transportation.vehicle_safety_release` PK truck + release sequence; references resolved defects, Maintenance/Safety authority, inspection evidence, and release time.

## 11. Maintenance

`transportation.maintenance_plan` PK `truck_number + maintenance_plan_code + effective_from`; stores effective-to, trigger basis, calendar/mileage/hour interval, warning threshold, service specification, and active status.

`transportation.maintenance_work_order` uses `maintenance_work_order_number` as PK and stores truck, plan/defect/incident trigger, maintenance type, scheduled dates, out-of-service period, provider, status, odometer/hours, work summary, parts/cost evidence, warranty reference, inspection, authorized release, and audit data.

`transportation.maintenance_work_order_activity` PK work order + activity sequence; is append-only. Completion does not itself release a critical vehicle unless the required safety release exists.

## 12. Fuel, Odometer, and Utilization

`transportation.fuel_event` PK `truck_number + event_time + fuel_ticket_reference`; stores odometer, fuel quantity/unit/type, vendor/location, amount/currency, purchaser/card reference, source, and exception. A manual event uses a controlled fuel-ticket reference rather than a null or fake key.

`transportation.odometer_event` PK `truck_number + event_time + event_type_code`; stores reading, source, Route/work order, and correction reference. Lower readings are rejected except through an authorized correction event.

`transportation.vehicle_usage_summary` PK `truck_number + business_date`; stores derived miles, engine/refrigeration hours, fuel, Route count, stops, capacity utilization, downtime, and source-completeness indicator. It is reproducible from authoritative facts and not a substitute for events.

## 13. Driver Eligibility and Availability

`transportation.driver_qualification` PK `principal_code + qualification_code + effective_from`; stores effective-to, license class/status, endorsement/restriction, evidence, verification, and authority.

`transportation.driver_availability` PK `principal_code + available_from + availability_type_code`; stores available-through, reason, source schedule/leave reference, hours/compliance status reference, and audit data.

`transportation.driver_vehicle_qualification` PK `principal_code + vehicle_class_code + effective_from` records allowed vehicle/equipment classes. Transportation references workforce identity; it does not store compensation, payroll, benefits, or sensitive HR data unrelated to dispatch.

## 14. Route Patterns

`transportation.route_pattern` uses `route_pattern_code` as PK and stores name, service-lane/corridor reference, home Warehouse, status, and audit columns.

`transportation.route_pattern_version` PK `route_pattern_code + effective_from`; stores effective-to, normal delivery weekdays, planned departure/return, expected miles/time, vehicle/compartment requirements, approval, and status. Versions cannot overlap.

`transportation.route_pattern_stop` PK `route_pattern_code + effective_from + stop_sequence`; stores Customer Number/location, typical arrival/service duration, receiving-window reference, preferred sequence, and requirements. Pattern Stops plan service but do not create Deliveries.

Opening Pattern configuration supports the Statesville, Monroe, Rock Hill, and Gastonia corridors and practical intervening locations.

## 15. Daily Route and Stops

`transportation.route` uses `route_number` as PK and stores fulfillment cycle, planned delivery date, Route Pattern version, warehouse, planned departure/return, planner, current truck/driver/load, estimated miles/time/capacity, current status, exception state, and row version.

`transportation.route_stop` PK `route_number + stop_sequence`; stores Delivery Number, Customer Number/location, planned arrival/service/departure, receiving-window reference, service priority, special-requirement snapshot, load-access instruction, current status, and row version.

`transportation.route_stop_sales_order` PK route + stop sequence + Sales Order Number links all Orders served by the Stop without duplicating Sales facts.

Geographic/time/capacity checks expose overload, window conflict, excessive deviation/time, territory exception, and late-departure risk.

## 16. Customer Delivery Appointments

`transportation.delivery_appointment` PK `route_number + stop_sequence + appointment_sequence`; stores scheduled window, Customer contact, confirmation status/time, appointment reference, instructions, and current result.

`transportation.delivery_appointment_history` PK route + stop + appointment sequence + event sequence; records schedule, confirmation, reschedule, cancellation, missed-window, and actual-arrival facts.

Appointment requirements derive from Customer/location standing requirements. Missing required confirmation blocks Route readiness unless an authorized service exception exists.

## 17. Route Assignments and Load Acceptance

`transportation.route_assignment_history` PK `route_number + assignment_time`; stores planned/actual truck, driver, assigning Principal, reason, accepted time, and superseded assignment reference.

`transportation.route_load` PK `route_number + outbound_load_number`; references the Warehouse Load, Ready/reconciliation event, planned/actual truck, acceptance result, weight/volume/pallet totals, compartment validation, seal, and accepted time/Principal.

`transportation.route_handling_unit` PK route + handling unit number; stores Warehouse Load/Stop/compartment references and loaded/removed status. Only Warehouse-confirmed content is allowed. A correction returns through Warehouse functions.

`transportation.route_document_manifest` PK route + document type + document number links Invoice/delivery documents without copying or permitting updates to owning records.

## 18. Dispatch Authorization

`transportation.dispatch_authorization` PK `route_number + authorization_sequence`; stores readiness decision, truck, driver, load, pre-trip inspection, registration/insurance/authority evidence, compartment/temperature result, document-manifest result, blocking-exception result, dispatcher, scheduled/actual departure, odometer, seal, and status.

`transportation.dispatch_check` PK route + authorization sequence + check_code records each required result and source evidence. All required checks must pass or have an authorized non-safety exception.

Dispatch atomically posts Departure Route Event, current Route/Vehicle status, and Sales fulfillment notification. Invoices remain `PENDING_DELIVERY` under Finance control and unposted.

## 19. Route Events and Resequencing

`transportation.route_event` PK `route_number + event_time + event_type_code`; stores Stop when applicable, planned/actual time, location evidence, Principal/device/source, reason, reversal reference, and correlation.

`transportation.route_stop_resequence` PK `route_number + resequence_sequence`; stores prior/new sequence mapping, decision time, reason, authority, feasibility recheck, and Customer notification. The original plan remains intact.

Planned timestamps never stand in for actual events. Missing driver updates create an exception rather than a fabricated arrival/completion.

## 20. Breakdown, Cargo Transfer, and Incidents

`transportation.transportation_incident` uses `transportation_incident_number` as PK and stores incident type, Route/truck/driver, time/location, safety/cargo condition, description, evidence, notification, investigation owner, report status, and resolution.

`transportation.breakdown_response` PK incident number + response_sequence; stores assistance, repair, replacement truck, Route split, delay, Customer communication, and decision.

`transportation.cargo_transfer` PK incident number + transfer_sequence; stores source/destination truck/compartments, handling units, seal, temperatures, Inventory custody references, responsible Principals, and completion. Capacity, safety, document, and temperature validation is mandatory before the replacement truck proceeds.

## 21. Delivery Header and Order Links

`transportation.delivery` uses `delivery_number` as PK and stores Route/Stop, Customer Number/location, planned/actual arrival/service/completion, receiving requirement snapshot, current status, primary recipient evidence state, exception state, and row version.

`transportation.delivery_sales_order` PK `delivery_number + sales_order_number`; identifies Orders included in one delivery. Separate delivery identity is required for separate location, custody, appointment, or acceptance treatment.

`transportation.delivery_status_history` PK `delivery_number + status_time + delivery_status_code`; is append-only and references the authoritative event/Principal/reason.

## 22. Delivery Lines and Outcomes

`transportation.delivery_line` PK `delivery_number + line_number`; stores Sales Order/Line, Invoice/Line reference when available, Product, unit, planned/loaded quantity, temperature class, and source handling-unit/lot relationship.

`transportation.delivery_line_handling_unit` PK delivery + line + handling unit + Inventory Lot Number preserves lot/custody traceability.

`transportation.delivery_line_outcome` PK `delivery_number + line_number + outcome_sequence`; stores outcome code, quantity/unit/base conversion, time, reason, recipient statement, driver, exception, and reversal reference.

Outcome quantities reconcile to presented/loaded quantity and distinguish Accepted, Refused, Short, Damaged, Wrong Product, Temperature Rejected, and Undelivered. A correction is a linked outcome event, not an edit.

## 23. Proof of Delivery

`transportation.proof_of_delivery` PK `delivery_number + proof_sequence`; stores completion time, receiving person/role when available, acknowledgment method, accepted-with-exception flag, driver, geolocation/device evidence where available, requirement result, and correction reference.

`transportation.proof_of_delivery_evidence` PK delivery + proof sequence + evidence sequence; stores evidence type, protected file/document reference, hash where required, captured time, and retention/security class.

Required-proof failure creates a Delivery Exception. Evidence storage follows File Standards; large signatures/images are not embedded indiscriminately in operational rows.

## 24. Temperature Control

`transportation.temperature_device` PK `device_code`; stores device type, serial, owner/assigned truck, calibration requirement, active status, and audit data.

`transportation.temperature_device_calibration` PK `device_code + calibration_time`; stores result, valid-through, provider, certificate/evidence, and status.

`transportation.temperature_reading` PK `route_number + device_code + reading_time`; stores truck/compartment, setpoint, actual temperature, unit, source, quality indicator, location/Stop, and exception reference.

`transportation.temperature_excursion` PK `route_number + compartment_code + excursion_sequence`; stores start/end, range, affected handling units/Products/Lots/Stops, immediate action, Quality decision reference, and resolution.

Missing required readings or expired calibration creates a blocking exception. A driver cannot release affected Product.

## 25. Delivery Exceptions and Notification

`transportation.delivery_exception` uses `delivery_exception_number` as PK and stores type/severity, Route/Stop/Delivery, event time/location, affected Product/quantity/handling unit, owner, facts/evidence, immediate action, required resolution, escalation, status, and row version.

`transportation.delivery_exception_activity` PK exception number + activity sequence; records assignment, Dispatch/Customer Service/Quality notification, Customer contact, promise, action, resolution, and outcome.

Material delivery exceptions require prompt Customer Service notification; safety/temperature exceptions additionally require Quality notification. Driver comments cannot become unauthorized credits, prices, or delivery promises.

## 26. Refused and Returned Custody

`transportation.return_custody_event` PK `delivery_number + handling_unit_number + event_time`; stores custody event, Product/Lot composition reference, quantity, truck/compartment, seal/temperature evidence, reason, source/destination custodian/location, and acknowledgment.

Loose refused goods must receive a physical Return Handling Unit before the first custody event; the identifier represents the actual controlled container, not a placeholder.

Immediate refusal references the Delivery outcome. A later return also references the Sales Return Authorization. Transportation custody remains open until Warehouse acknowledges handoff into an unavailable Inventory status/location.

## 27. Billing and Accounting Handoff

`transportation.delivery_billing_result` PK `delivery_number + result_sequence`; stores accepted/refused/undelivered/damaged quantity totals, proof state, Invoice reference, result time, Finance acknowledgment, and correction reference.

`transportation.route_cost_input` PK `route_number + cost_input_type_code + event_sequence`; stores mileage, fuel, toll, maintenance-use, driver-time, or other measured/estimated input with source and measurement basis.

Finance owns Invoice finalization, AR, revenue, COGS, credits/debits, route-cost allocation, fixed assets, debt, depreciation, insurance expense, and GL. Transportation records operational evidence only.

## 28. Route Close and Reconciliation

`transportation.route_close` PK `route_number + close_sequence`; stores completeness/reconciliation results, returned-cargo handoff, documents, odometer/fuel/temperature/post-trip state, open exceptions, Finance handoff, closer, and close time.

Required reconciliation views/functions prove:

- Every Stop has an outcome.
- Loaded handling units reconcile to delivered/returned/transferred custody.
- Delivery Line outcomes reconcile to presented quantities.
- Proof requirements are satisfied or assigned.
- Returned custody is acknowledged.
- Required route documents are accounted for.
- Temperature/inspection facts are complete.
- Remaining incidents/cases have an owner.

Route operational closure may coexist with assigned downstream cases; it cannot hide unexplained cargo or delivery quantity.

## 29. Offline Recovery

`transportation.offline_document_register` PK `offline_document_number`; uses Core-controlled reserved document ranges and stores document type, issued-to Principal/Route, issued time, return status, entry status, and source evidence.

`transportation.offline_entry_batch` PK `offline_batch_number`; stores operator, source document range, actual event interval, entry time, validation status, and reconciliation.

Recovered events use their actual event time plus later entry time. Idempotency keys combine reserved document identity and event identity. Recovery cannot duplicate dispatch, Delivery, Inventory, billing, temperature, or custody effects.

## 30. Controlled Functions

Required transaction-safe functions:

- `create_or_update_vehicle(...) returns truck_number`
- `record_vehicle_status(...)`
- `record_vehicle_document(...)`
- `record_vehicle_inspection(...)`
- `open_or_complete_maintenance_work_order(...)`
- `record_fuel_or_odometer_event(...)`
- `record_driver_qualification_or_availability(...)`
- `create_or_revise_route_pattern(...)`
- `plan_daily_route(...) returns route_number`
- `add_or_resequence_route_stop(...)`
- `record_delivery_appointment(...)`
- `assign_route_resources(...)`
- `accept_warehouse_load(...)`
- `authorize_and_dispatch_route(...)`
- `record_route_event(...)`
- `record_breakdown_incident_or_cargo_transfer(...)`
- `create_delivery(...) returns delivery_number`
- `record_delivery_outcome(...)`
- `record_proof_of_delivery(...)`
- `record_temperature_reading_or_excursion(...)`
- `open_or_resolve_delivery_exception(...)`
- `record_return_custody_and_handoff(...)`
- `record_delivery_billing_result(...)`
- `close_and_reconcile_route(...)`
- `ingest_offline_transportation_batch(...)`

Functions validate Principal/authority, lock rows deterministically, check row versions, enforce effective rules, call owning-domain functions, use safe `search_path`, and deny `PUBLIC` execution.

## 31. Integrity, Concurrency, and Reconciliation

- VIN and active vehicle-document identifiers are unique in governed scope.
- Effective compartments, equipment, qualifications, documents, profiles, and Route Pattern versions cannot overlap ambiguously.
- Vehicle, driver, Warehouse Load, and Route cannot receive conflicting active assignments.
- Dispatch locks Route, assigned resources, inspection, documents, Load, manifest, temperature, and exceptions deterministically.
- Concurrent dispatch cannot send one truck/driver/load on multiple incompatible Routes.
- Stop/Delivery/handling-unit membership is unique for the active Route.
- Capacity and temperature-class rules are enforced before dispatch and cargo transfer.
- Delivery outcomes, custody, and billing results cannot exceed loaded quantity.
- Route close rejects unexplained Stops, cargo, documents, proof, or temperature requirements.
- Posted operational records reject update/delete; correction uses forward events.

## 32. Audit

`audit.transportation_event` PK `transportation_audit_event_number`; stores event type/time, Principal, Truck, Driver Principal, Route/Stop/Delivery, Product/Lot/handling unit, inspection/work order/exception/incident references, source domain/document, reason/approval, correlation, and sanitized `jsonb` summary. It is append-only and supplements domain facts.

## 33. Indexes and Views

Indexes support vehicle status/document expiry; maintenance due/downtime; inspections/defects; fuel/odometer; driver qualification/availability; effective Route Patterns; Routes by date/status/truck/driver; Stop windows/progress; appointments; dispatch readiness; handling-unit custody; delivery status/outcomes; proof completeness; temperature readings/excursions; open exceptions/incidents; and audit correlation.

Required views:

- `reporting.transportation_dispatch_readiness`
- `reporting.transportation_route_progress`
- `reporting.transportation_route_manifest`
- `reporting.transportation_departure_risk`
- `reporting.transportation_on_time_delivery`
- `reporting.transportation_delivery_accuracy`
- `reporting.transportation_proof_completeness`
- `reporting.transportation_temperature_compliance`
- `reporting.transportation_return_custody`
- `reporting.transportation_route_reconciliation`
- `reporting.transportation_vehicle_availability`
- `reporting.transportation_maintenance_due`
- `reporting.transportation_driver_eligibility`
- `reporting.transportation_spare_truck_use`
- `reporting.transportation_route_cost_input`
- `reporting.transportation_cross_domain_reconciliation`

## 34. Privileges

`pfd_database_owner` owns objects; `pfd_change_executor` assumes ownership only during approved builds; `pfd_application` reads approved operational data and executes controlled functions; `pfd_reporting` reads approved views; `pfd_support_readonly` receives diagnostic read access; `PUBLIC` receives none.

Drivers may execute assigned inspection/Route/Delivery/proof/temperature/custody functions but cannot update price, Invoice, credit, Inventory Balance, Quality disposition, vehicle safety release, or unassigned Routes. Dispatch cannot override critical safety/document/qualification failures. Direct writes to events, proof, temperature, custody, history, audit, and number state are prohibited.

## 35. Change Order

| Change | Content |
|---|---|
| `0083` | Add Transportation business-number sequences and reference data |
| `0084` | Create Vehicle, status, Compartments, equipment, and configuration snapshots |
| `0085` | Create vehicle/driver documents, operating profiles, and eligibility views |
| `0086` | Create inspections, defects, safety releases, and status controls |
| `0087` | Create maintenance, fuel, odometer, and utilization structures |
| `0088` | Create driver qualification, vehicle qualification, and availability structures |
| `0089` | Create Route Patterns, versions, Stops, and corridor configuration |
| `0090` | Create daily Routes, Stops, appointments, and Sales Order relationships |
| `0091` | Create Route assignments, Load acceptance, handling units, and manifests |
| `0092` | Create dispatch authorization, checks, Route events, and resequencing |
| `0093` | Create breakdown response, cargo transfer, and incident structures |
| `0094` | Create Deliveries, lines, outcomes, status history, and proof |
| `0095` | Create temperature, exceptions, notifications, and return custody |
| `0096` | Create billing/cost handoff, Route close, reconciliation, and offline recovery |
| `0097` | Create controlled functions, audit, indexes, and reporting views |
| `0098` | Apply comments, privileges, deferred constraints, and final assertions |

## 36. Verification and Tests

Verification proves contiguous history/checksums through `0098`; required objects/codes; exact natural keys; unique VIN; validated/deferred constraints; effective-period controls; immutable events/proof/temperature/custody/audit; role separation; cross-domain reconciliation; no surrogate keys; and no simulation-session columns.

Disposable tests cover six-truck opening data; five normal/one spare without hard restriction; VIN uniqueness; expired insurance/registration; unsafe inspection; maintenance release; odometer correction; ineligible driver; Pattern revision; territory/window/capacity conflict; appointment requirement; duplicate resource assignment; Load acceptance; dispatch readiness; spare substitution; Route resequence; breakdown/cargo transfer; every-Stop outcome; partial/refused/damaged/undelivered quantity; POD requirement; temperature excursion/calibration; Customer Service/Quality notification; returned-cargo handoff; Route close rejection/success; offline idempotency; unauthorized driver action; concurrency; and ordinary-table simulation.

## 37. Acceptance Criteria

The eventual package must build cleanly and incrementally through `0098`, rerun as a no-op, and pass checksum, behavioral, concurrency, reconciliation, and privilege tests. It must demonstrate exact natural keys, dispatch safety, controlled capacity, complete Stop outcomes, lot/handling-unit custody, temperature/POD evidence, and clean Sales/Warehouse/Inventory/Finance boundaries.

## 38. Deferred Configuration

Opening Truck/VIN data, compartments/capacities, equipment, Route Patterns, stop/service standards, driver roster/qualifications, inspection checklists, maintenance intervals, devices/calibration, proof methods, exception thresholds, and legal/insurance requirements are configuration—not unresolved architecture.

## 39. Next Design Work

Next: **Finance and Accounting Domain Specification**. Executable Transportation and Delivery SQL remains deferred until we leave Design Land.
