# \<business name>
# Quality, Food Safety, and Recall PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0156`–`0186`  
**Depends on:** Cumulative design through `0155`; Quality, Food Safety, and Recall Domain Specification

## 1. Purpose

Define normalized PostgreSQL structures and controls for Quality Standards, Product/Supplier qualification, inspections, temperatures, Nonconformances, Holds, quarantine, disposition, sanitation, complaints, traceability, recalls, effectiveness checks, product accounting, mock recalls, CAPA, compliance, and audit.

## 2. Required Outcome

- Safety Holds block affected Inventory and operations transactionally.
- Lot/date, inspection, temperature, and disposition evidence remains immutable and traceable.
- Exact-lot Products retain required receiving/shipping Critical Tracking Event data.
- Other Products support explicit, confidence-rated exposure windows.
- Recall scope, notices, responses, effectiveness checks, and product accounting are versioned and reconcilable.
- Natural business keys and governed composites are the only primary keys.
- Simulation uses ordinary Quality tables without simulation-session columns.

## 3. Platform and Package

PostgreSQL 15 or later; existing schemas; cumulative manifest `11.0.0`; immutable changes `0001`–`0155`; transactional changes `0156`–`0186`. The `quality` schema owns domain records; `core`, `party`, `product`, `purchasing`, `inventory`, `warehouse`, `sales`, `transportation`, `workforce`, `finance`, `audit`, and `reporting` supply governed references.

## 4. Standards

Use lowercase `snake_case`, singular tables, uppercase governed codes, `numeric(19,6)` quantities, `numeric(9,3)` temperatures, `date` for business dates, and `timestamptz` for events. Mutable work uses Principal/timestamp audit columns and positive `row_version`; approved evidence and decisions are append-only.

Natural numbers/codes and governed composites are primary keys. Full natural keys propagate through foreign keys. Identity, serial, UUID, generic hidden ID, and nullable polymorphic-key designs are prohibited. Separate child scope tables represent different target types.

## 5. Controlled Numbers

Change `0156` adds permanent, nonreusable sequences:

| Sequence | Example |
|---|---|
| `QUALITY_INSPECTION` | `QIN00000001` |
| `TEMPERATURE_OBSERVATION` | `TMP000000001` |
| `MEASURING_EQUIPMENT` | `MEQ0000001` |
| `NONCONFORMANCE` | `NCF0000001` |
| `QUALITY_HOLD` | `QHD0000001` |
| `QUALITY_SAMPLE` | `SMP0000001` |
| `CUSTOMER_QUALITY_COMPLAINT` | `QCP0000001` |
| `TRACE_ANALYSIS` | `TRA0000001` |
| `PRODUCT_RECALL` | `RCL0000001` |
| `MOCK_RECALL` | `MRC0000001` |
| `CAPA` | `CPA0000001` |
| `CONTROLLED_DOCUMENT` | `QDC0000001` |
| `PEST_EVENT` | `PST0000001` |
| `QUALITY_AUDIT_EVENT` | `QAE000000001` |

Lines, versions, decisions, actions, checks, observations, and communications use governed parent-relative sequences.

## 6. Reference Data

Opening reference groups cover inspection type/result, severity, hazard class, temperature unit/result, Nonconformance source/status, Hold reason/status, disposition, traceability level, Critical Tracking Event, Key Data Element, confidence, recall type/status, notice channel/status, response status, effectiveness result, CAPA type/status, sanitation result, pest event, equipment/calibration status, obligation status, and document status.

## 7. Standards and Control Plans

`quality.quality_standard` PK quality standard code + effective-from stores scope/type, measurement, limits/result, sampling/evidence, escalation, authority, and effective-to.

`quality.control_plan` PK control plan code + version; `quality.control_plan_standard` PK plan/version + line sequence links exact Standard versions and conditional applicability. Approved versions are immutable.

## 8. Product Safety Profile

`quality.product_safety_profile` PK Product Number + effective-from stores storage class, temperature profile, lot/date requirements, shelf-life basis/minimum, traceability level, Food Traceability List determination, allergen/raw/ready-to-eat/chemical attributes, packaging criteria, risk tier, reviewer, and effective-to.

`quality.product_traceability_determination` PK Product + determination sequence records rule/list version, exemption analysis, decision, evidence, authority, review date, and effective range. Nonoverlap and required-review checks apply.

## 9. Supplier Quality Approval

`quality.supplier_quality_approval` PK Supplier Number + approval type + effective-from stores Product/category/storage scope, evidence, risk, restrictions, reviewer, expiration, status, and effective-to.

`quality.supplier_quality_evidence` PK approval key + evidence sequence stores document/certification/license/audit/insurance/traceability/cold-chain evidence, issuer, dates, verification, protected document reference, and status.

## 10. Inspections and Observations

`quality.inspection` uses `inspection_number` as PK and stores inspection type, Control Plan/version, Receipt/load/Delivery/return/process reference, inspector, actual start/end, overall result, status, and row version.

Separate normalized subject tables—`inspection_receipt`, `inspection_inventory_lot`, `inspection_load`, `inspection_delivery`, `inspection_location`, and `inspection_process`—use inspection number plus the target's natural key. At least one subject is required.

`quality.inspection_observation` PK inspection + observation sequence stores Standard version, Product/Lot, sampling basis, observed value/code/text, expected limits, result, evidence, and time. Final observations are immutable.

## 11. Temperature Observations

`quality.temperature_observation` uses `temperature_observation_number` as PK and stores time, value/unit, expected range, Product/storage profile, instrument, observer/device, result, and Control Plan.

Normalized subject tables link the observation to Receipt Line, Inventory Lot/location, Warehouse zone, Truck compartment/load, Delivery, or return. A required subject and exactly one governing context are enforced. Excursion results create a durable Hold request in the same transaction.

## 12. Measuring Equipment and Calibration

`quality.measuring_equipment` uses `equipment_number` as PK and stores type, description, location/custodian, approved use, accuracy/tolerance, verification schedule, status, and row version.

`quality.equipment_calibration_event` PK equipment + event sequence stores due/performed times, method/reference standard, as-found/as-left results, performer/provider, certificate, status, and next due.

`quality.measurement_impact_assessment` PK failed calibration event + assessment sequence links affected observation/date scope, risk decision, Hold/Nonconformance, and resolution.

## 13. Nonconformance

`quality.nonconformance` uses `nonconformance_number` as PK and stores source type/key, Standard, severity, detection time, description, immediate containment, owner, due date, status, and row version.

Normalized scope tables link Product, Inventory Lot/balance, Receipt Line, location, load, Delivery Line, Supplier, equipment, sanitation task, or process. Scope quantities/units and from/to times are explicit. Related reports use `quality.nonconformance_relationship` PK parent + related + relationship type.

## 14. Quality Holds

`quality.quality_hold` uses `quality_hold_number` as PK and stores reason, severity, authority, opened/review times, source Nonconformance/Complaint/Recall, status, and row version.

Separate `hold_product`, `hold_lot`, `hold_inventory_balance`, `hold_location`, `hold_receipt`, `hold_order`, `hold_load`, `hold_delivery`, `hold_supplier`, and `hold_exposure_group` tables use Hold Number plus exact natural target key. At least one scope row is required.

Hold activation and scope expansion publish blocking events transactionally. Release cannot precede scope reconciliation or leave unresolved child scope accidentally available.

## 15. Investigation, Evidence, Samples, and Tests

`quality.investigation` PK source document type + source number + investigation sequence stores question, investigator, chronology, risk assessment, uncertainty, conclusion, approval, and status.

`quality.investigation_evidence` PK investigation key + evidence sequence stores evidence type/source natural key, observed time, document reference, relevance, verifier, and checksum.

`quality.sample` uses `sample_number` as PK; collection and custody tables preserve Product/Lot, location, quantity/unit, seal, conditions, transfers, requested analysis, and disposition.

`quality.test_result` PK sample + test sequence + result version stores method/version, laboratory, units/limits, preliminary/final/invalid state, interpretation, report, reviewer, and superseded result.

## 16. Disposition and Release

`quality.disposition_decision` PK Hold Number + decision sequence stores scope version, disposition, quantity/unit, restrictions, evidence, requestor, approver, effective time, Inventory/Finance action status, and reversal/supersession.

`quality.restricted_release_condition` PK decision key + condition sequence stores permitted Customer/use/date/location, informed acceptance reference, and verification.

Checks prohibit sell/donate outcomes for expired/unsafe Product. Physical movement and financial consequences reference the immutable decision rather than copying its authority.

## 17. Storage, Sanitation, Pest, and Facility Controls

`quality.storage_control_requirement` PK storage profile + effective-from defines environment, separation, monitoring, response, and effective-to.

`quality.sanitation_plan` PK plan code + version; `sanitation_plan_task` PK plan/version + task sequence; `sanitation_completion` PK plan/version + task + scheduled occurrence stores actual work, materials, result, verification, findings, and block state.

`quality.pest_event` uses `pest_event_number` as PK and stores observation/service type, location, time, provider/employee, finding, trend point, action, evidence, and status.

`quality.facility_control_exception` PK facility/location/equipment key + exception sequence records defect, safety effect, maintenance link, Hold, due date, and closure.

## 18. Allergen and Compatibility Rules

`quality.handling_compatibility_rule` PK subject category + compared category + effective-from stores allowed/prohibited/conditional result, separation/cleaning requirement, rationale, approval, and effective-to.

`quality.load_compatibility_evaluation` PK Transportation Load Number + evaluation version stores Product/profile versions, compartment/separation plan, prior-load/cleanliness evidence, result, exceptions, evaluator, and time.

## 19. Transportation Quality Controls

`quality.transport_control_requirement` PK storage/product profile + effective-from defines vehicle suitability, cleanliness, temperature, separation, seal, observation, training, and response requirements.

`quality.transport_quality_evaluation` PK Load Number + evaluation sequence stores requirement version, preload/in-transit/delivery phase, vehicle/compartment, observations, result, Hold/Nonconformance, and disposition.

Transportation remains authoritative for vehicle/load/route/Delivery facts; Quality owns the Standard and safety decision.

## 20. Returns and Delivery Exceptions

`quality.return_quality_inspection` PK Return Receipt Number + inspection sequence links original Delivery/Line, Product/Lot if known, elapsed custody, package/seal/temperature/condition/tampering evidence, result, Hold, and disposition.

`quality.delivery_quality_exception` PK Delivery Number + Delivery Line + exception sequence records Driver/Customer observation, actual time, condition, evidence, immediate action, Hold/Nonconformance, and status.

Returned Product is unavailable until a permitted disposition transaction completes.

## 21. Customer Quality Complaints

`quality.customer_quality_complaint` uses `complaint_number` as PK and stores Customer/location/contact, Product/shipment, Lot/code if known, event/consumption times, complaint type/severity, urgency, owner, restricted-detail indicator, and status.

`quality.complaint_detail` PK complaint + detail sequence stores symptoms/injury allegation, foreign material, allergen, contamination, sample/evidence, and protected access classification. `quality.complaint_relationship` links related complaints and cases.

High-severity or repeated-pattern conditions require immediate Hold/investigation evaluation.

## 22. Traceability Requirements and Events

`quality.traceability_requirement` PK requirement code + effective-from stores Product/rule/contract/risk scope, required Critical Tracking Events and Key Data Elements, export/retention requirement, review, and effective-to.

`quality.traceability_event` PK Product Number + traceability Lot Code + Critical Tracking Event code + event sequence stores event time, location, quantity/unit, source business key, immediate source/recipient Party/location where required, and record status.

`quality.traceability_event_element` PK event key + KDE code stores value, source, validation, and correction reference. Exact-lot shipping events must link Delivery/Line and Customer Location before shipment completion.

## 23. Exposure Groups and Evidence Windows

`quality.exposure_group` PK Product Number + exposure-group number stores Inventory Lots, Receipt/time range, pick-slot placement/movement range, procedure version, and status.

`quality.exposure_group_lot` and `exposure_group_inventory_event` preserve evidence members. The group aids inference but never replaces Supplier or traceability Lot identity.

## 24. Trace Analyses

`quality.trace_analysis` uses `trace_analysis_number` as PK and stores starting fact, purpose, requested/target/completed times, analyst, status, and current version.

`quality.trace_analysis_version` PK analysis + version stores query scope, data cutoff/checksum, method, assumptions, completeness, backward/forward conclusions, reviewer, and superseded version.

`quality.trace_result` PK analysis/version + result sequence stores result type, exact/inferred indicator, Product/Lot, Receipt/Inventory/Shipment/Customer key, quantity, time range, confidence, inclusion/exclusion, and rationale.

## 25. Recall Cases and Scope

`quality.product_recall` uses `recall_number` as PK and stores type, hazard, initiating party/authority, initiated time, coordinator, executive owner, regulator classification/reference, status, and row version.

`quality.recall_scope_version` PK Recall + scope version stores effective time, Trace Analysis version, rationale, preparer/approver, expansion/narrowing indicator, and superseded version.

Separate scope lines identify Products, Lots/codes, date ranges, Receipts, Inventory, Deliveries/Lines, Customer Locations, Suppliers, and exposure groups. Scope reduction requires independent authorization and evidence.

## 26. Recall Actions and Containment

`quality.recall_action` PK Recall + action sequence stores action type, target domain/key, priority, responsible role/Principal, due/completed times, prerequisite, result/evidence, status, and escalation.

`quality.recall_containment_confirmation` PK Recall + target type + target key + confirmation sequence stores expected/physical quantity, location, confirmer, time, discrepancy, and follow-up.

Dependency cycles are rejected. Recall activation creates required Hold and action records atomically.

## 27. Recall Notices and Recipients

`quality.recall_notice` PK Recall + notice sequence + version stores scope version, audience, approved message/template, instructions, urgency, issued time, approver, and superseded version.

`quality.recall_notice_recipient` PK notice key + recipient sequence stores Customer/Supplier/regulator/other Party and location/contact/channel, required response, sent/delivered/failed times, and status.

`quality.recall_customer_response` PK Recall + Customer Location + response sequence stores notice, responder, confirmed receipt, affected/on-hand/used/disposed/transferred/recovered quantities, action, evidence, time, and follow-up.

## 28. Effectiveness Checks and Product Accounting

`quality.recall_effectiveness_check` PK Recall + check sequence stores plan stratum, Customer/location, independent checker, attempts, result, evidence, failure/escalation, and completion.

`quality.recall_product_accounting_version` PK Recall + reconciliation version stores scope version, data cutoff, total exposure, on-hand, shipped, recovered, Supplier return, destroyed/donated/disposed, adjustment, unexplained quantity, reviewer, and status.

`quality.recall_product_accounting_line` PK Recall/reconciliation version + line sequence stores source/quantity/status evidence. Closure rejects unexplained quantity unless formally accepted as a continuing exception under authorized policy; no plug is permitted.

## 29. Mock Recalls and CAPA

`quality.mock_recall` uses `mock_recall_number` as PK and stores planned/actual dates, scenario, Product/storage/traceability type, coordinator, goals, status, and result.

`quality.mock_recall_measure` PK mock recall + measure code records target/actual, pass/fail, evidence, and explanation.

`quality.capa` uses `capa_number` as PK and stores source type/key, problem, containment, owner, due date, status, and row version. Root causes, actions, evidence, effectiveness tests, extensions, and approvals use governed child sequences.

## 30. Controlled Documents and Compliance Calendar

`quality.controlled_document` uses `controlled_document_number` + version as PK and stores type/title, owner, approval, effective/withdrawn dates, content/evidence checksum, storage reference, acknowledgment requirement, and superseded version.

`quality.compliance_obligation` PK obligation code + effective-from stores authority, jurisdiction, applicability, requirement, cadence, retention/export rules, owner, review date, and effective-to.

`quality.compliance_task` PK obligation code + due date + task sequence stores responsible/backup, evidence, result, completion, exception, and status.

## 31. Controlled Functions

Required transaction-safe functions include standard/profile maintenance; inspection/temperature recording; calibration impact assessment; Nonconformance/Hold scope and release; sampling/testing; disposition; sanitation/pest completion; complaint/escalation; trace event validation/export; exposure-window and Trace Analysis; Recall activation/scope revision/action/notice/response/effectiveness/reconciliation/closure; mock recall; CAPA; and compliance-task completion.

Functions validate Principal/authority, versions, full natural keys, source idempotency, deterministic locks, current Holds, scope totals, and cross-domain rules. `PUBLIC` execution is denied.

## 32. Integrity and Concurrency

- Active Safety Profile, Standard, approval, and obligation effective ranges cannot overlap ambiguously.
- Final inspection/test/decision/trace/recall records reject update/delete.
- Active Hold scope blocks affected operational eligibility.
- Expired/unsafe Product rejects sell/donate release.
- Exact traceability shipments require completed Lot/KDE evidence.
- Recall notices reference a specific approved scope version.
- Customer responses cannot exceed explained affected quantity without an exception.
- Product accounting reconciles source lines and exposes unexplained variance.
- CAPA/Recall closure requires completed critical dependencies.

Conflicts lock by Hold, Product/Lot, Inventory target, Trace Analysis, Recall, Customer Location, and CAPA in stable order.

## 33. Events and Idempotency

`quality.domain_event` and `quality.event_consumer_receipt` follow the established durable outbox/consumer-receipt pattern using complete natural source keys, event sequence, checksum, correlation, actual/recorded times, and consequence reference.

Hold placement/expansion/release and Recall activation/scope change are committed with their event rows. Reprocessing cannot duplicate a Hold, notice, Inventory restriction, Customer task, or Finance consequence.

## 34. Security and Audit

Roles separate inspection, Quality review, Food Safety authority, disposition, sanitation, complaint-restricted access, Recall coordination, regulator communication, reporting, and audit.

`audit.quality_audit_event` uses `quality_audit_event_number` as PK and stores entity/natural key/version, action, Principal/process, business/recorded times, prior/new controlled value/status, scope, source, reason, approval, confidentiality, and correlation.

Sensitive complaint/medical, investigation, Customer contact, regulator, and protected Supplier documents are restricted and masked.

## 35. Indexes and Views

Indexes support active Holds by every target; short-dated/expired Lots; failed inspections/temperatures/calibrations; open Nonconformances/complaints/CAPAs; trace events by Lot/location/time/source/recipient; Recall scope, recipients, failed notices, missing responses, failed effectiveness checks, and unexplained quantities; sanitation/pest/compliance due work; and all foreign keys.

Views provide current Product safety profile, Supplier qualification, held Inventory/demand, quality exceptions, short-date risk, cold-chain exceptions, exact traceability completeness, exposure candidates, Recall dashboard, Customer response, product accounting, CAPA aging, and compliance calendar. Views expose business keys/as-of time and do not become alternate masters.

## 36. Continuity and Simulation

Offline work uses reserved numbers, controlled forms, direct Hold communication, actual/entry times, and later reconciliation. Recovery checks prior scope/actions before any release or duplicate notice.

Simulation writes ordinary Quality tables. Core may control time/randomness, but no ordinary key or row includes Simulation Session.

## 37. Change Order

| Change | Content |
|---|---|
| `0156` | Add Quality business-number sequences and reference data |
| `0157` | Create Standards, Control Plans, and version links |
| `0158` | Create Product Safety Profiles and traceability determinations |
| `0159` | Create Supplier quality approvals and evidence |
| `0160` | Create Inspections, subject tables, and observations |
| `0161` | Create Temperature Observations and subject links |
| `0162` | Create measuring equipment, calibration, and impact assessment |
| `0163` | Create Nonconformances, relationships, and normalized scope tables |
| `0164` | Create Quality Holds and normalized scope tables |
| `0165` | Create investigations and evidence |
| `0166` | Create samples, custody, and test results |
| `0167` | Create disposition, restricted release, and execution status |
| `0168` | Create storage requirements, sanitation, pest, and facility controls |
| `0169` | Create compatibility and load evaluations |
| `0170` | Create transport controls/evaluations and Delivery/return exceptions |
| `0171` | Create Customer quality complaints and protected details |
| `0172` | Create traceability requirements, events, and KDEs |
| `0173` | Create exposure groups and evidence membership |
| `0174` | Create Trace Analyses, versions, and results |
| `0175` | Create Recall Cases, scope versions, and normalized scope lines |
| `0176` | Create Recall actions and containment confirmations |
| `0177` | Create Recall Notices, recipients, and delivery status |
| `0178` | Create Customer responses and follow-up |
| `0179` | Create effectiveness checks |
| `0180` | Create Recall product-accounting versions and lines |
| `0181` | Create mock recalls and measures |
| `0182` | Create CAPA, causes, actions, evidence, and effectiveness tests |
| `0183` | Create controlled documents, obligations, and compliance tasks |
| `0184` | Create controlled functions, durable events, and consumer receipts |
| `0185` | Apply security, audit, indexes, views, and retention controls |
| `0186` | Apply deferred cross-domain constraints, comments, and final assertions |

## 38. Verification and Tests

Verification proves contiguous checksums through `0186`, exact natural keys, normalized scopes, full-key FKs, effective-range exclusions, immutable evidence, Hold propagation, exact-lot completion, exposure confidence, Recall versioning/reconciliation, privileges, indexes, and views.

Disposable tests cover receiving/temperature/calibration failure; multi-target Hold; concurrent allocation/Hold; release/disposition; expired/short-dated Product; sanitation/pest; transport excursion; return/complaint; exact CTE/KDE shipment; exposure-window inference; Trace Analysis; Recall expansion/narrowing; notices and failed channels; Customer responses; effectiveness checks; unexplained quantity; closure rejection; mock recall; CAPA; outage recovery; and ordinary-table simulation.

## 39. Acceptance Criteria

The eventual package must build incrementally through `0186`, rerun as a no-op, and prove that suspect Product is blocked; evidence is immutable; exact and inferred traceability remain distinguishable; Recall scope and communications are controlled; quantities reconcile; and no surrogate or simulation-session keys exist.

## 40. Deferred Configuration

Opening Standards, profiles, FTL mappings, thresholds, Supplier evidence, sampling, instruments, sanitation/pest plans, segregation rules, Hold locations/labels, Recall Team/contacts/templates, regulator references, retention, and reports are configuration.

## 41. Next Design Work

Next: **Management Reporting and Audit Domain Specification**. Executable Quality SQL remains deferred until we leave Design Land.
