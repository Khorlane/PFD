# \<business name>
# Transportation and Delivery Domain Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Design baseline  
**Depends on:** PFD Party/Customer, Inventory, Warehouse Operations, and Sales/Order Management designs

## 1. Purpose

Define how PFD manages delivery vehicles, route patterns, daily routes, drivers, dispatch, temperature-controlled transportation, delivery execution, proof of delivery, exceptions, returned-product custody, and fleet performance. This is business and logical-data design, not PostgreSQL implementation.

## 2. Scope

Transportation and Delivery owns:

- Operational vehicle, compartment, availability, inspection, maintenance, registration, and insurance status
- Driver transportation qualifications and route assignments
- Standard Route Patterns and daily Route Plans
- Stop sequencing, delivery appointments, capacity/time feasibility, and dispatch
- Departure, travel, arrival, service, and route completion events
- Delivery quantities, exceptions, receiving acknowledgment, and proof of delivery
- Temperature, mileage, fuel, breakdown, accident, and route-performance facts
- Custody of refused, damaged, or undelivered goods until controlled return handoff

It does not own Customer locations/standing requirements, Sales demand/prices, Inventory balances/lots, Warehouse loading, invoice/AR/GL, employee/payroll masters, Quality disposition, or fixed-asset/debt accounting.

## 3. Operating Baseline

PFD begins with six owned, financed, multi-temperature delivery trucks. Five are normally dispatched and one is maintained as a spare for breakdowns, planned maintenance, and peak demand. “Spare” is an operating role, not a permanent restriction; any safe, available, suitable truck may serve a route.

Each delivery truck supports ambient, refrigerated, and frozen products in appropriately controlled compartments. Transportation normally serves approximately 40–45 weekday stops across about 80 opening Customer locations.

## 4. Service Territory

The route hub is \<business address>. Principal service corridors extend toward:

- Statesville, North Carolina
- Monroe, North Carolina
- Rock Hill, South Carolina
- Gastonia, North Carolina

The territory includes locations along reasonably direct paths to those endpoints. It is not a simple radius. Transportation consumes Customer service-lane eligibility and approved exceptions.

Expansion beyond the territory requires management review of route time, capacity, cost, Customer density, legal/insurance requirements, and service reliability. An isolated distant stop is not accepted merely because a truck could physically reach it.

## 5. Governing Decisions

1. Every truck has one permanent Truck Number; its VIN is a required unique external identifier, not its primary business key.
2. An unavailable, unsafe, improperly insured/registered, or unsuitable truck cannot be dispatched.
3. Preventive maintenance is planned; the spare truck does not justify deferred maintenance.
4. Stable Route Patterns support familiarity and planning, while each operating day receives an independently controlled Route Plan.
5. Daily planning considers geography, delivery windows/appointments, service commitments, travel/service time, driver eligibility, load/compartment capacity, traffic, and departure time.
6. A route is not overloaded merely to avoid using the spare truck or another approved trip.
7. Customer receiving appointments and restrictions are controlled commitments.
8. Dispatch requires a reconciled Warehouse Load, suitable truck/compartments, qualified driver, route documents, invoices, and required readiness checks.
9. Every stop records an outcome; undelivered stops cannot disappear from an otherwise completed route.
10. Delivery results distinguish accepted, refused, short, damaged, wrong, temperature-affected, and undelivered quantities.
11. Proof of delivery identifies the recipient when available and preserves the required evidence.
12. Drivers may document facts but cannot change prices, promise credits, or alter Finance documents.
13. Returned goods remain segregated and unavailable until Warehouse/Quality disposition.
14. Posted route, delivery, temperature, and custody events are immutable; corrections use linked reversals or superseding events.
15. Simulation uses the same Transportation records as normal operation.

## 6. Ownership Boundaries

| Information/process | Owner | Transportation responsibility |
|---|---|---|
| Customer location, lane, receiving window, standing requirements | Customer | Use current approved facts; preserve route snapshot |
| Sales Order and Customer commitment | Sales | Schedule only released deliverable demand |
| Inventory quantity/lot/status | Inventory | Reference loaded/delivered/returned facts; never edit balance |
| Load construction and reconciliation | Warehouse | Accept only approved Ready load |
| Route, vehicle, driver, dispatch, delivery | Transportation | Authoritative operational owner |
| Invoice/AR/revenue/COGS | Finance | Return accepted-delivery evidence; never post accounting |
| Safety/temperature disposition | Quality | Hold affected goods and request decision |
| Employee identity/payroll | HR/Finance | Reference active Principal and transportation eligibility |
| Truck asset, debt, depreciation | Finance | Supply usage, maintenance, and disposition evidence |

## 7. Vehicle Identity and Status

Each Vehicle records permanent Truck Number, VIN, make/model/year, ownership status, acquisition/in-service references, gross/cargo capacities, dimensions, refrigeration capability, fuel type, odometer basis, home facility, operating role, and lifecycle status.

Opening operating roles are `NORMAL_ROUTE` and `SPARE`. Status distinguishes Available, Assigned, In Service, Maintenance Due, Out of Service, Unsafe, and Retired. Status changes retain reason, authority, effective time, and source inspection/maintenance/incident.

A retired Truck Number and historical VIN remain permanent. Replacement vehicles receive new Truck Numbers.

## 8. Compartments and Equipment

Each truck contains one or more governed compartments. A Compartment records code, storage class, temperature range, volume/weight/pallet capacity, access sequence, partition configuration, monitoring device, and active period.

Truck equipment may include liftgate, pallet jack, hand truck, load restraints, seals, temperature recorder, communication device, and safety equipment. Required equipment derives from Customer/location and Product/load requirements.

Compartment configuration used for a Route is snapshotted. Mid-route configuration changes require an event and cannot invalidate already transported Product conditions.

## 9. Registration, Insurance, and Operating Authority

Transportation retains effective-dated evidence for registration, inspection, insurance, permits, and other operating authority required for the truck, driver, territory, and cargo. Crossing between North Carolina and South Carolina must be supported by the applicable approved operating profile.

Each document records type, issuing party/jurisdiction, identifier, effective/expiration dates, verification, status, and evidence location. Expired or missing mandatory evidence blocks dispatch. Finance may own policy payment; Transportation owns operational eligibility.

## 10. Vehicle Inspection and Safety

A required pre-trip inspection occurs before dispatch and a post-trip inspection occurs at route completion or shift handoff. Inspections record odometer, refrigeration, tires, brakes, lights, fluids, liftgate, restraints, safety equipment, visible damage, defect severity, and inspector/time.

A safety-critical defect immediately places the vehicle Out of Service. Lesser defects create assigned corrective work with a due time. A driver or dispatcher cannot override an Out-of-Service decision without authorized maintenance/safety release.

Accident, injury, cargo-security, spill, contamination, and roadside events enter a controlled incident process and preserve evidence, notifications, custody, and required follow-up.

## 11. Preventive Maintenance and Repair

Maintenance plans may use calendar time, mileage, engine hours, refrigeration hours, inspection findings, or manufacturer requirement. Plans generate work before due thresholds where practical.

A Maintenance Work Order records vehicle, maintenance type, trigger, scheduled/out-of-service period, vendor or internal provider, work performed, parts/cost evidence, odometer/hours, inspection/release, and completion.

Completed maintenance history is immutable. A later correction or warranty action links forward. Transportation provides cost/use evidence to Finance but does not determine capitalization, depreciation, payable, or debt treatment.

## 12. Fuel, Mileage, and Utilization

Each Fuel Event records Truck Number, date/time, odometer, quantity, unit, fuel type, vendor/location, amount, purchaser/card reference, and exception. Odometer entries cannot normally decrease; correction requires authority and an audit trail.

Route start/end odometers, miles, engine/refrigeration hours where available, fuel, idle time, capacity used, stops, and service time support vehicle utilization and route-cost analysis. Estimated values remain identified as estimates.

## 13. Driver Eligibility

A Driver is an active workforce Principal authorized for Transportation work. Driver eligibility includes license class/status/expiration, required endorsements, medical or safety qualifications where applicable, vehicle/equipment qualification, training, territory restrictions, and effective availability.

Transportation records qualification evidence and assignments but does not duplicate employee identity, compensation, benefits, or payroll. An expired, suspended, unavailable, insufficiently qualified, or hours-restricted driver cannot be assigned for dispatch.

Driver schedules and actual route time provide downstream timekeeping/compliance evidence. Transportation does not silently alter payroll time.

## 14. Standard Route Patterns

A Route Pattern describes a stable geographic operating plan: Route Pattern Code, corridor/service lane, normal delivery days, typical departure/return, geographic sequence, expected miles/time, vehicle requirements, and active period.

Pattern stops identify typical Customer locations and preferred sequence but do not create deliveries. A Customer may participate in multiple patterns when schedule or capacity requires it.

Daily Route Plans reference but do not overwrite the Pattern. Pattern changes are effective-dated and preserve prior route history.

## 15. Daily Route Planning

A Route Plan is created for a specific fulfillment cycle and planned delivery date. It records permanent Route Number, Pattern, warehouse, planned departure/return, route status, planner, assigned truck/driver, load reference, miles/time/capacity estimates, and exception state.

Planning considers:

- Released Sales demand and Warehouse Load readiness
- Customer geography, receiving days/windows, appointments, and access/security rules
- Contract and service priority
- Stop service time and travel time
- Truck/compartment weight, cube, pallet, temperature, equipment, and access constraints
- Driver availability and eligibility
- Planned departure, traffic, weather information when available, and return feasibility

Planning identifies overload, time-window conflict, excessive deviation/time, unavailable resource, and late-departure risk. An approved daily change does not rewrite the standard Pattern.

## 16. Route Stops and Delivery Appointments

Each Route Stop has a permanent sequence within the Route and references Customer Number, delivery location, Delivery Number, Sales Orders, receiving window/appointment, planned arrival/service time, special requirements, and load/compartment location.

Stop order may change before dispatch with recorded reason and revalidation. After departure, a resequence records planned-versus-actual order and why the change occurred.

Where a Customer requires an appointment, the appointment records scheduled window, confirmation, contact, status, and changes. PFD trucks do not arrive whenever convenient; an unscheduled or missed-window delivery is an exception requiring documentation.

## 17. Load Acceptance and Route Manifest

Warehouse owns load construction and declares a reconciled Load Ready. Transportation validates the load/route relationship, truck compartments, total weight/cube/pallet capacity, stop sequence, temperature zones, seals, and unresolved exceptions.

The Route Manifest identifies truck, driver, load, stops, handling units, orders, temperature zones, delivery instructions, invoices, and required documents. Only Warehouse-confirmed contents appear as cargo.

Transportation cannot add undocumented Product to a truck. A load correction returns through Warehouse controls and preserves both the original and corrected events.

## 18. Dispatch Readiness

Dispatch requires:

- Route approved and all deliverable stops resolved
- Warehouse Load Ready and reconciled
- Suitable Available truck and compartments
- Active qualified driver and assignments
- Successful required vehicle/temperature inspections
- Current registration, insurance, and operating authority
- Route Manifest, pending-delivery invoices, and delivery documents
- Required seals, equipment, and communication capability
- No blocking safety, vehicle, driver, load, or route exception

Dispatch Authorization records responsible dispatcher, readiness evidence, scheduled/actual departure, odometer, seal, temperature, and Route status. Departure changes the Route to Dispatched; invoices remain pending delivery.

## 19. Spare Truck and Breakdown Contingency

If the assigned truck becomes unavailable before departure, Dispatch may assign the spare or another suitable truck after capacity, compartment, document, inspection, and load compatibility validation. The original and actual assignments remain visible.

An in-route Breakdown records time/location, symptoms, safety/cargo condition, assistance, delay estimate, and disposition. Response may include repair, replacement truck, load transfer, route split, Customer notification, or return to PFD.

A cargo transfer preserves seal, temperature, handling-unit, custody, and Inventory traceability. The route is not overloaded or operated unsafely merely to avoid a second trip.

## 20. Route Execution

Route events include departure, travel, arrival, service start/end, stop departure, delay, resequence, return-to-facility, and route completion. Events retain planned and actual times, location when available, responsible Principal/device, and source.

Driver status communication must support dispatch visibility without treating a planned time as an actual event. Missing updates create an assigned exception rather than fabricated completion.

A Route completes only when every Stop has a final or explicitly unresolved status, returned cargo is handed off, documents are returned, and required post-trip activity is recorded.

## 21. Delivery Identity and Lifecycle

Every planned Customer delivery has one permanent Delivery Number, even when it includes multiple Sales Orders. Separate delivery identities are used when location, custody, appointment, or invoice treatment requires separate acceptance.

| Status | Meaning |
|---|---|
| `PLANNED` | Delivery assigned to a Route/Stop |
| `LOADED` | Approved cargo is on the assigned truck |
| `DISPATCHED` | Route has departed |
| `ARRIVED` | Driver reached Customer location |
| `IN_SERVICE` | Delivery presentation/unloading underway |
| `COMPLETED` | All lines have recorded outcomes and acknowledgment |
| `EXCEPTION` | Material issue remains assigned |
| `UNDELIVERED` | No quantity was accepted |
| `CANCELLED` | Delivery validly cancelled before dispatch |
| `CLOSED` | Custody, Customer Service, Inventory, and billing consequences reconcile |

Status changes are explicit and append-only.

## 22. Delivery Execution

At each Stop the driver:

1. Confirms actual location, arrival time, receiving availability, and appointment/window result.
2. Follows access, security, sanitation, dock, liftgate, and hand-unload requirements.
3. Protects frozen, refrigerated, ambient, food, and nonfood segregation.
4. Presents documented handling units/Product and confirms quantities.
5. Records accepted, refused, short, damaged, wrong, temperature-affected, or otherwise undelivered quantities.
6. Records recipient acknowledgment and required evidence.
7. Secures return cargo and documents a material exception.
8. Completes the Stop or leaves it in an assigned Exception status.

The driver cannot substitute undocumented Product, edit Sales price, change Invoice value, or authorize Customer credit.

## 23. Delivery Lines and Quantity Reconciliation

A Delivery Line references Delivery, Sales Order/Line, Invoice/Line when prepared, Product, unit, planned/loaded quantity, lot/handling-unit evidence, and temperature class.

Outcome quantities distinguish accepted, refused, Customer-short, damaged, wrong Product, temperature-rejected, and undelivered. Outcome components reconcile to the presented quantity and cannot exceed loaded quantity net of valid corrections.

An apparent shortage may be a Warehouse load variance, driver custody issue, Customer count difference, documentation issue, or true nondelivery. Transportation records facts; Customer Service/Inventory/Finance determine downstream resolution.

## 24. Proof of Delivery

Proof of Delivery records Delivery Number, completion time, receiving person/role when available, signature or approved electronic acknowledgment, document/image reference, accepted-with-exception statement, geolocation/device evidence when available, and driver.

Customer standing requirements determine required proof. If the recipient refuses or cannot provide normal proof, the driver records the alternate evidence and reason; required-proof failure creates an exception.

Proof confirms receipt facts but does not by itself authorize price change, credit, or unsafe Product acceptance. Corrections are linked and preserve the original evidence.

## 25. Temperature Control

Transportation preserves required Product temperatures from Load acceptance through delivery or return handoff. The Route retains predeparture compartment setpoint/actual readings, monitoring-device identity, readings/events during transit, delivery observations where required, and post-route results.

A reading outside the governed range creates an immediate exception and identifies affected compartment, time interval, handling units, Products/Lots, and Stops. The driver protects/separates affected cargo and requests Quality direction; the driver cannot declare questionable Product safe.

Missing readings are exceptions, not assumed compliance. Sensor correction/calibration history remains distinguishable from cargo readings.

## 26. Delivery Exceptions and Customer Notification

Exception types include late departure/arrival, missed appointment/window, Customer unavailable, access/security failure, shortage, refusal, wrong Product, damage, temperature excursion, breakdown, accident, documentation/POD failure, and unsafe condition.

Each exception records severity, Route/Stop/Delivery, time/location, affected Product/quantity/handling units, owner, facts/evidence, immediate action, Customer notification, required resolution, escalation, and status.

Material delivery exceptions promptly notify Dispatch and Customer Service. Safety/temperature events additionally notify Quality. Drivers document facts and commitments made only within their authority.

## 27. Refused, Damaged, and Undelivered Custody

Immediate Customer refusal does not require prior Return Authorization, but it requires a Delivery outcome and reason. Later Customer returns require the Sales/Customer Service Return Authorization.

Returned cargo is identified by Delivery, Product/Lot/handling unit, quantity, reason, temperature/custody evidence, truck compartment, and seal where applicable. It remains segregated from deliverable cargo and unavailable to normal Inventory.

Return-to-facility handoff records time, Warehouse recipient, location, quantity, condition, and custody exception. Inventory/Warehouse/Quality own receipt, quarantine, inspection, and disposition. Transportation custody does not end until the handoff is acknowledged.

## 28. Invoice and Accounting Boundary

Finance prepares permanent-numbered invoices before departure using reconciled loaded quantities. The invoice accompanies the Route and remains `PENDING_DELIVERY`.

Transportation supplies accepted/refused/undelivered/damaged results and proof evidence. Finance finalizes and posts accepted quantities, revenue, AR, and COGS. Post-departure differences use controlled billing adjustments, credit/debit memos, or supplemental invoices.

Transportation may record estimated route cost inputs such as mileage, fuel, tolls, maintenance use, and driver time. Finance owns cost allocation, asset accounting, debt, depreciation, insurance expense, and GL.

## 29. Route Close and Reconciliation

Route close requires:

- Every Stop has an outcome
- Delivery quantities reconcile to loaded quantities and returned custody
- Proof requirements are satisfied or assigned as exceptions
- Returned cargo is acknowledged by Warehouse
- Driver documents/invoices are accounted for
- Fuel, mileage, temperature, seal, and post-trip inspection facts are recorded as required
- Breakdown, accident, and Customer Service issues are assigned
- Finance receives delivery outcome evidence

Route closure does not force unresolved cases closed; it proves that each remaining matter has a responsible owner and traceable handoff.

## 30. Logical Structures

| Structure | Natural primary key |
|---|---|
| Vehicle | `truck_number` |
| Vehicle Compartment | truck number + compartment code |
| Vehicle Status Event | truck number + event time + status code |
| Vehicle Document | truck number + document type + document identifier |
| Vehicle Inspection | truck number + inspection time + inspection type |
| Maintenance Plan | truck number + maintenance_plan_code + effective_from |
| Maintenance Work Order | `maintenance_work_order_number` |
| Fuel Event | truck number + event time + vendor reference |
| Driver Qualification | Principal code + qualification code + effective_from |
| Route Pattern | `route_pattern_code` |
| Route Pattern Version | route pattern code + effective_from |
| Route Pattern Stop | route pattern code + effective_from + stop sequence |
| Daily Route | `route_number` |
| Route Stop | route number + stop sequence |
| Delivery Appointment | route number + stop sequence + appointment sequence |
| Route Assignment History | route number + assignment time |
| Dispatch Authorization | route number + authorization sequence |
| Route Event | route number + event time + event type |
| Delivery | `delivery_number` |
| Delivery Line | delivery number + line number |
| Proof of Delivery | delivery number + proof sequence |
| Temperature Reading | route number + device code + reading time |
| Delivery Exception | `delivery_exception_number` |
| Return Custody Event | delivery number + handling unit + event time |
| Transportation Incident | `transportation_incident_number` |

Governed parent-relative sequences are meaningful within their transaction. No surrogate keys are permitted.

## 31. Integrity Rules

- VIN is unique while Truck Number remains the primary key.
- Effective qualifications, documents, capacities, and patterns cannot overlap ambiguously.
- Only one current operational status exists per vehicle.
- Unsafe/unavailable trucks and ineligible drivers cannot be dispatched.
- Route/stop load cannot exceed validated truck/compartment capacity.
- Each loaded handling unit belongs to one active Route/Load.
- A Delivery belongs to one active Route Stop at a time.
- Delivery outcome quantities reconcile to presented/loaded quantities.
- Accepted plus returned/undelivered custody reconciles to loaded cargo.
- Temperature excursions cannot be closed without affected-cargo resolution.
- Posted dispatch, route, delivery, proof, temperature, custody, and incident records are immutable.
- Corrections use linked reversal/superseding events.

## 32. Responsibilities

| Decision/action | Primary authority |
|---|---|
| Approve Route Pattern | Transportation/Operations |
| Approve out-of-territory route | General Management with Operations/Finance review |
| Assign truck/driver and dispatch | Dispatcher/Transportation supervisor |
| Place vehicle Out of Service | Driver, Maintenance, or Safety according to policy |
| Release vehicle after critical defect | Authorized Maintenance/Safety Principal |
| Record delivery facts/POD | Driver or authorized delivery Principal |
| Change delivery promise | Customer Service/Sales with Operations |
| Decide Product safety/disposition | Quality |
| Approve Customer credit/price adjustment | Finance/Sales according to authority |
| Accept returned custody | Warehouse |
| Post invoice/accounting result | Finance |

## 33. Reports and Measures

- Dispatch readiness and departure-risk board
- Route plan, manifest, and stop progress
- On-time departure, arrival, and delivery
- Missed windows/appointments and undelivered stops
- Delivery accuracy, refusal, damage, and exception rates
- Proof-of-delivery completeness
- Temperature compliance/excursions by truck, compartment, Route, Product, and Lot
- Returned-cargo custody and handoff status
- Truck/compartment capacity utilization
- Route miles, time, stops, fuel, cost inputs, and contribution references
- Vehicle availability, inspection defects, maintenance due/completed, and downtime
- Driver qualification/availability and route assignment
- Breakdown, accident, route transfer, and spare-truck use
- Delivery-to-Inventory/Sales/Finance reconciliation

## 34. Security and Audit

Dispatchers plan/assign Routes within authority. Drivers record inspections, events, delivery outcomes, proof, temperature, and custody facts for assigned work. Maintenance controls vehicle work/release. Customer Service views events and coordinates resolution. Finance and Quality perform their owned decisions.

Drivers cannot update prices, invoices, credit documents, Inventory balances, Quality dispositions, or vehicle safety release decisions. Posted events and audit records are append-only. Sensitive driver, incident, insurance, Customer-security, and recipient evidence receives role-limited access. `PUBLIC` receives no domain access.

## 35. Continuity and Offline Operation

If normal systems are unavailable, Dispatch may issue controlled manual Route Manifests, inspection forms, temperature logs, Delivery records, and proof documents. Each form carries a permanent or reserved business identifier.

Recovered transactions are entered through normal validation and marked with actual event time, entry time, source, and responsible Principal. Re-entry must not duplicate dispatch, delivery, Inventory, billing, or custody effects.

## 36. Simulation

Simulation creates ordinary Vehicles, Routes, assignments, dispatches, Deliveries, temperature readings, exceptions, and custody events using normal controls. It does not create parallel Transportation masters or add simulation identifiers to business keys.

Scenario setup may vary fleet availability, traffic, volume, failures, or weather assumptions. Business tables must still show exactly what a real operating day/week would show, and downstream Sales/Inventory/Finance behavior uses those facts.

## 37. Remaining Configuration

Truck numbers/specifications, VINs, compartment capacities, route patterns, stop/service-time standards, driver roster/qualifications, inspection checklists, maintenance intervals, sensor/device details, proof methods, exception thresholds, and legal/insurance document requirements are configuration—not unresolved architecture.

## 38. Next Step

Next design deliverable: **PFD Transportation and Delivery PostgreSQL Build Specification**. It will define normalized structures, natural keys, constraints, functions, privileges, verification, and tests without executable SQL.
