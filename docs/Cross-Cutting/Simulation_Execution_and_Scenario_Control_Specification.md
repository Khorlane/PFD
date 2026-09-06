# Simulation Execution and Scenario-Control Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Integrated application and data-control design; executable code not included  
**Depends on:** Business, domain, PostgreSQL build, and reporting/audit specifications through `0205`

## 1. Purpose

Define how business activity is simulated for a day or week using the same normalized business tables, controls, approvals, financial consequences, and reports that would support actual operation.

## 2. Governing Decision

A simulation is not a parallel business model. It is a controlled execution of ordinary business transactions against an isolated database copy.

Customer, Supplier, Product, Employee, Order, Inventory, Delivery, Payroll, Finance, Quality, and reporting tables contain no Simulation Session key. Within a run, those tables are the actual books and records of that simulated company.

## 3. Intended Use

Primary run horizons are:

- One business day
- One operating week
- A selected process/event sequence
- A focused exception or recovery exercise

This is not primarily designed to press a button and simulate the next six months. Longer horizons may be composed from controlled periods later, but they are not the opening design target.

## 4. Reset and Historical Meaning

If a simulated week follows the prior week in the same database copy, ordinary business tables preserve that history exactly as a real business would. Financial statements, Sales comparisons, Inventory, AR/AP, and other reports use those records.

If the user wants a fresh unrelated scenario, the environment is reset by restoring or cloning an approved baseline outside the business model. Reset does not delete selected transactions from a used database or add scenario partitions to business keys.

## 5. Isolation Model

Each active simulation runs in its own isolated PostgreSQL database/cluster or safely isolated complete environment copy. The controller assigns a Simulation Run Number only to controller records, logs, artifacts, and environment metadata.

Business services receive business time, Principal, source, and correlation context but do not receive a Run Number for storage in ordinary business rows.

## 6. Simulation Control Scope

The controller owns:

- Scenario definitions and versions
- Baseline/environment selection
- Run number, seed, clock, horizon, status, and checkpoints
- Scheduled synthetic event queue
- Workload and exception generators
- Decision-policy profiles for unattended execution
- Execution journal, diagnostics, assertions, and artifacts
- Pause, step, resume, stop, failure recovery, and completion

It does not directly update business tables.

## 7. Scenario Definition

A Scenario Definition identifies purpose, business horizon, baseline requirement, workload profiles, event generators, exception profiles, decision-policy profile, required assertions, expected reports, owner, and effective version.

Definitions may describe a normal day, normal week, heavy-demand day, Supplier short shipment, Employee absence, truck breakdown, quality Hold, recall, late Customer payment, cash stress, or combined exercise.

A version is immutable after approval. Parameter changes create a new version.

## 8. Baseline

A Baseline identifies the exact database backup/template, schema/change level, opening/reference-data version, business date/time, checksums, required services, and validation result.

The Grand Opening Baseline contains completed facility/fleet/Employee/Supplier/Customer/Product/Inventory/cash/capital setup and no inherited operational receivables/payables unless explicitly stated.

A scenario may explicitly select either the public repository's complete fictional sample baseline or an approved private local baseline held outside the repository. Both use identical schema, opening-data formats, validation, business tables, and transaction logic. The controller records the selected Baseline Code/version without copying private identity data into controller artifacts intended for publication.

A baseline cannot be used when its checksum, schema version, reference data, or validation differs from the Scenario requirement.

## 9. Environment Provisioning

Before a Run, the controller:

1. Allocates an isolated environment.
2. Restores/clones the selected Baseline.
3. Verifies database change checksums and configuration.
4. Applies permitted Scenario parameters outside business rows.
5. Starts services with the simulated clock and controlled identities.
6. Runs opening invariants and records results.

No business event executes until provisioning passes.

## 10. Business Clock

The controller provides an authoritative simulated clock in America/New_York. Business services obtain current business time through the established clock interface rather than the host wall clock.

The Run records host time separately for diagnostics. Business rows preserve simulated actual/event time and later recorded time when appropriate.

Clock modes are step-to-next-event, fixed increment, accelerated continuous, and paused. Time never moves backward within a Run.

## 11. Business Calendar

The controller uses the following operating calendar:

- Office/order activity Monday–Friday
- Normal order cutoff 4:00 PM
- Office hours 8:00 AM–5:00 PM
- Warehouse cycle Sunday afternoon through Friday afternoon
- Friday Orders fulfilled Sunday night for Monday Delivery
- Saturday normally closed
- Weekday receiving, routing, Delivery, banking, and Payroll/Finance calendars as configured

Holiday and exceptional calendars are versioned business configuration.

## 12. Deterministic Randomness

Each Run has one master random seed. Each event generator derives a stable independent stream from Run seed + generator code + governed occurrence sequence.

Adding an unrelated generator must not change prior generators' results. Every random draw records generator, stream, occurrence, distribution/version, input parameters, and selected outcome in controller evidence.

The same Baseline, Scenario version, configuration, seed, and executable versions must reproduce the same business inputs and results, subject to documented external nondeterminism.

## 13. Scheduled Event Queue

Each synthetic event has Run Number, Event Number, event type, scheduled business time, priority, source generator, subject business key, payload version, dependency, status, attempt, correlation, and outcome reference.

Run Number is valid here because the queue is controller data, not a business master or transaction table.

Ordering uses scheduled time, safety/business priority, and Event Number. Simultaneous independent events may run concurrently only when deterministic outcome and database locking are preserved.

## 14. Event Sources

Events arise from:

- Fixed calendar schedules
- Business records and due dates
- Stochastic generators
- Consequences emitted by completed business transactions
- User-injected decisions or exceptions
- Recovery/retry processing

The controller schedules an intention. The applicable domain service validates whether the business event is permissible at execution time.

## 15. Customer Demand Generation

Customer demand uses active Customer locations, authorized schedule/order channels, segment, delivery cadence, standing templates, Product preferences, history/profile, seasonality, and Scenario demand factors.

Generated Orders use ordinary Sales pricing, minimum-order, split-pack, credit, allocation, substitution, cutoff, and approval controls. A generator cannot directly reserve Inventory or guarantee fulfillment.

## 16. Supplier and Receiving Generation

Supply events use Purchase Orders, Supplier lead-time/fill/quality profiles, appointment capacity, freight terms, and Scenario conditions. They may create on-time, early/late, short, damaged, temperature, documentation, or rejected outcomes.

Unscheduled Supplier arrival remains an exception requiring Receiving authorization; simulated carriers do not bypass appointments.

## 17. Workforce Generation

Workforce events use published schedules, assignments, qualifications, availability, leave, and configured absence/turnover profiles. Generated absence records reduce actual capacity and trigger normal coverage decisions.

Time, overtime, Payroll, and Finance consequences follow ordinary approvals. A generated attendance fact never edits an approved time/pay result directly.

## 18. Warehouse and Inventory Execution

Warehouse workload derives from actual released demand, Receipts, Inventory, replenishment, FEFO, Holds, staffing, equipment, and slot capacity. Task productivity uses configured distributions by activity and operating conditions.

Lot placement, movement, picking, staging, loading, shortages, damage, counts, and exceptions are ordinary transactions. Simulation cannot teleport stock, force negative quantity, or choose held/expired Product.

## 19. Transportation Execution

Route events use actual Orders/loads, stops, delivery windows, truck/driver readiness, capacity, travel profiles, weather/traffic Scenario factors, and hours restrictions.

Breakdown, delay, temperature, refusal, shortage, damage, return, and successful delivery use ordinary Transportation/Quality/Sales/Finance consequences. Five trucks normally dispatch and one remains spare when demand and readiness allow.

## 20. Customer Payment and Collections

Payment timing uses Invoice due dates, Customer segment/risk, payment behavior profile, disputes, and Scenario factors. Generated Receipts use ordinary remittance, application, unapplied cash, bank, AR, and reconciliation controls.

Late payment, returned payment, promise, dispute, collection, Hold, expected loss, and write-off remain distinct business decisions.

## 21. Finance and Payroll Execution

The controller schedules due accounting, cash, AP payment, Payroll, depreciation, accrual, close, and reporting work. Finance services enforce period, source, approval, cash, segregation, and exactly-once posting.

The controller cannot generate a balancing plug, bypass payment authority, or alter a closed period. Insufficient cash invokes the approved priority, forecast, and revolving-credit decision process.

## 22. Quality and Recall Execution

Quality generators may produce inspections, temperature excursions, damage, complaints, Supplier alerts, Holds, and Recall exercises. Safety authority and normal transaction blocking remain active.

Exact-lot and exposure-window traceability use the same operational evidence as normal business. A simulated Recall may be marked as an exercise in controller artifacts, but Quality business records in that isolated copy follow the normal process.

## 23. Decision Policy Profiles

Unattended Runs require approved Decision Policy Profiles for routine choices such as:

- Substitution within Customer preferences
- Overtime/coverage within authority
- Emergency replenishment
- Alternate Supplier use
- Small-order or delivery exceptions
- Collections escalation
- Discount/payment selection
- Spare-truck deployment

Policies state authority, conditions, priority, limits, rationale, and fallback. They never automate reserved owner decisions or safety-critical release without an approved rule explicitly allowing it.

## 24. Human Decisions

A Run may pause for a user decision. The prompt presents business facts, permitted choices, authority, consequences, and deadline. The response records Principal, business time, selection, and reason and invokes the normal domain decision.

If unattended policy has no authorized answer, the Run records an unresolved business exception and follows the Scenario's stop/continue rule.

## 25. Transaction Execution Contract

Each event invokes one named domain command/service with:

- Authorized Principal/service identity
- Business time and recorded host time
- Source Event Number and correlation
- Expected business record versions
- Governed business parameters

The domain commits all intended business consequences atomically or returns a classified failure. The controller never patches tables to make an event succeed.

## 26. Idempotency and Retry

Every event retains one permanent Event Number and source correlation. A retry uses the same identity. Domain source registries return the existing consequence or reject a conflicting replay.

Transient failures use bounded deterministic retry. Business rejection, missing authority, failed validation, or safety Hold creates a business exception rather than blind retry.

## 27. Checkpoints and Recovery

Controller checkpoints capture Run clock, event queue state, generator stream positions, service versions, database backup/checkpoint reference, and validation checksum.

After controller failure, recovery restores a consistent environment/checkpoint, compares already committed source consequences, and resumes only incomplete events. It never assumes an event failed merely because its response was lost.

## 28. Pause, Stop, and Cancellation

Pause completes in-flight transactions and prevents new event dispatch. Graceful stop records pending events and produces a partial-Run report. Emergency stop halts dispatch immediately while leaving committed business transactions intact.

Cancellation changes controller status; it does not reverse or delete business history. A fresh Scenario uses a new environment restore.

## 29. Assertions

Assertions run at provisioning, event boundaries where appropriate, day close, and Run completion. Required assertions include:

- No broken natural-key references
- No negative or impossible Inventory balances
- Held/expired Product not normally shipped
- Order/Receipt/Inventory/Delivery quantity reconciliation
- Balanced Journals and subsidiary-to-GL agreement
- Cash/AR/AP/Payroll/Asset/Debt consistency
- Workforce/driver/qualification eligibility
- Recall product accounting and unresolved scope visibility
- No unauthorized approvals or protected-data access

Assertion failure records severity and may pause or fail the Run.

## 30. Run Completion

A Run is complete when the horizon is reached, all due/in-flight events are completed or explicitly unresolved, required business close work is done, assertions pass or are accepted under test policy, and required reports/artifacts are produced.

Completion does not imply every business exception is resolved; unresolved items are part of the result.

## 31. Outputs and Comparison

Outputs include Run manifest, event execution summary, random-decision ledger, exception/assertion report, operational reports, financial statements where due, KPI scorecard, and source/configuration checksums.

Business comparisons use the ordinary tables and dates. Controller comparison may additionally compare Runs by Run Number without placing that number in the business data.

## 32. Natural Control Keys

| Controller structure | Natural key |
|---|---|
| Scenario Definition | scenario code + version |
| Baseline | baseline code + version |
| Simulation Run | `simulation_run_number` |
| Run Environment | Simulation Run Number + environment sequence |
| Scheduled Event | Simulation Run Number + event number |
| Random Draw | Simulation Run Number + generator code + occurrence sequence |
| Decision Request | Simulation Run Number + decision sequence |
| Execution Attempt | Simulation Run Number + event number + attempt number |
| Checkpoint | Simulation Run Number + checkpoint sequence |
| Assertion Result | Simulation Run Number + assertion code + occurrence sequence |
| Run Artifact | Simulation Run Number + artifact sequence |

These keys remain in the controller repository only.

## 33. Security and Audit

Roles separate Scenario authoring, approval, environment provisioning, Run operation, decision response, protected-data access, and result review. The controller receives no unrestricted table-write credentials.

Scenario/version, seed, clock changes, injected events, decisions, retries, checkpoint/restore, stop/cancel, assertion waivers, exports, and artifact checksums are append-only and audited.

## 34. Performance and Concurrency

Acceleration must not weaken transaction isolation or reorder dependent events. Concurrency is limited by domain locking, resource capacity, deterministic scheduling, and database/service limits.

Performance tests distinguish simulated business duration from host execution duration and identify the slowest domain commands, queries, and reports without changing business outcomes.

## 35. Decisions Established

- Normal Run horizon is one day or one week.
- Each Run uses an isolated full database environment.
- Business tables are the actual records for that simulated company copy.
- Simulation Run Number exists only in controller records/artifacts.
- Fresh unrelated scenarios restore an approved Baseline rather than deleting business history.
- Business time is authoritative and monotonic within a Run.
- Randomness is deterministic and independently streamed by generator.
- Synthetic events use the same commands, validations, approvals, and accounting as normal operation.
- The controller cannot directly update business tables or create balancing plugs.
- Business reporting derives from ordinary tables; cross-Run comparison occurs outside them.

## 36. Remaining Configuration

Opening Scenario catalog, baseline locations, demand/supply/payment/absence/travel/productivity distributions, holiday calendars, exception frequencies, decision-policy thresholds, event priorities, retry limits, checkpoint cadence, assertion severity, artifacts, acceleration, and resource limits are configuration.

## 37. Acceptance Criteria

The design is acceptable when the same approved Baseline/Scenario/seed reproduces the same inputs; every event uses normal domain behavior; retries do not duplicate consequences; pauses/recovery preserve committed facts; all core invariants are tested; and a fresh scenario can be created without polluting business keys.

## 38. Next Design Work

Next: **Opening Business Data and Grand-Opening Baseline Specification**.
