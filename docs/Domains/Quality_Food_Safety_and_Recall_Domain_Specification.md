# Quality, Food Safety, and Recall Domain Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Business and logical domain design; executable SQL not included  
**Depends on:** Design through the Workforce and Payroll PostgreSQL Build Specification

## 1. Purpose

Define how the simulation prevents, detects, contains, investigates, corrects, and communicates food-quality and food-safety problems from Supplier receipt through Customer delivery and return. The domain must protect people first, preserve authoritative evidence, and support rapid, defensible withdrawal or recall action.

## 2. Required Outcomes

- Unsafe, suspect, damaged, expired, or nonconforming Product cannot enter or remain in available Inventory.
- Receipt, storage, handling, and transportation conditions remain traceable to responsible people, locations, equipment, Lots, and times.
- Product Holds take effect immediately across Purchasing, Inventory, Warehouse, Sales, and Transportation.
- The simulation can determine affected on-hand stock, inbound commitments, staged/loaded stock, and Customer exposure quickly.
- Required lot-level traceability is exact; other Products use the best supportable exposure window unless risk or contract requires more.
- Recall communication, effectiveness checks, product accounting, disposition, and corrective action remain complete and auditable.
- Quality decisions do not rewrite Supplier, Inventory, Delivery, Customer, or Finance source facts.
- Simulation uses ordinary Quality and Recall records.

## 3. Business Context

The business is a regional broadline food-service distributor operating from \<business address>. Its Customers include Restaurants, Hospitals, Schools, Correctional Institutions, and Hotels across routes toward Statesville, Monroe, Rock Hill, and Gastonia.

The assortment includes shelf-stable, frozen, refrigerated, fresh produce, meat, dairy, eggs, deli, paper, disposable, and related nonfood Products. The business does not manufacture or repackage food. It normally sells fixed Supplier cases or approved split packs and performs no warehouse catch-weight pricing.

Food safety takes priority over Sales, availability, Supplier convenience, schedule performance, and avoidance of loss.

## 4. Scope

This domain owns:

- Quality and food-safety policies, specifications, hazards, and control requirements
- Supplier and Product quality approval evidence
- Receiving, storage, handling, sanitation, and transportation-quality criteria
- Inspections, temperature observations, samples/tests, nonconformances, Holds, quarantine, release, and disposition decisions
- Customer complaints and suspected illness/escalation cases
- Traceability classification, required data completeness, and exposure analysis
- Market withdrawals, stock recoveries, regulatory/public-health alerts, and recalls
- Recall notices, responses, effectiveness checks, reconciliation, closure, mock recalls, and corrective/preventive action
- Food-safety training requirements and regulatory/document calendars

It does not own Purchase Orders, Receipts, physical Inventory balances/movements, Orders, Deliveries, Customer/Supplier masters, Employee masters, or financial postings.

## 5. Governance and Authority

The authorized Operations and Purchasing executive role owns food safety and quality. The business appoints a qualified Food Safety Leader and a trained backup with documented authority to:

- Place immediate Product, Lot, location, vehicle, Supplier, or process Holds
- Stop receiving, picking, loading, dispatch, or delivery when safety is uncertain
- Require quarantine, investigation, notification, withdrawal, or recall action
- Approve or deny safety-critical release and disposition

The General Manager coordinates major cross-department response. Legal/regulatory advice and government direction supersede ordinary internal authority. No commercial employee may override a safety Hold.

## 6. Domain Boundaries

| Fact | Authoritative owner |
|---|---|
| Product identity, storage class, declared attributes | Product |
| Supplier relationship and approval to purchase | Purchasing |
| Purchase commitment and appointment | Purchasing/Receiving |
| Accepted/rejected Receipt quantity | Receiving |
| Lot, expiration, location, quantity, and movement | Inventory/Warehouse |
| Quality criteria, inspection, Hold, release, disposition | Quality |
| Vehicle/route conditions and delivery result | Transportation |
| Customer shipment history | Sales/Transportation |
| Employee training completion | Workforce |
| Credits, reserves, write-offs, and financial loss | Finance |

Quality records reference source business keys and versions. A Quality decision changes eligibility/status through controlled domain transactions; it never edits the originating operational fact.

## 7. Regulatory and Standards Basis

The business maintains an effective-dated obligation register covering applicable FDA, USDA-FSIS, state/local, customer-contract, Supplier, insurance, and adopted industry requirements.

The FDA Sanitary Transportation rule addresses vehicle/equipment suitability, temperature and contamination controls, training, written procedures, agreements, and records for covered shippers, loaders, carriers, and receivers. The business therefore treats sanitary transportation requirements as explicit Product/load/route controls rather than informal practice. [FDA—Sanitary Transportation of Human and Animal Food](https://www.fda.gov/food/food-safety-modernization-act-fsma/fsma-final-rule-sanitary-transportation-human-and-animal-food)

The FDA Food Traceability Rule requires covered Food Traceability List Products to retain Key Data Elements for applicable Critical Tracking Events such as receiving and shipping and to provide requested information to FDA within 24 hours or another agreed reasonable time. As of this document date, Congress has directed FDA not to enforce the rule before July 20, 2028; the business designs for readiness before enforcement. [FDA—Food Traceability Final Rule](https://www.fda.gov/food/food-safety-modernization-act-fsma/fsma-final-rule-requirements-additional-traceability-records-certain-foods)

Regulatory status and dates are reviewed at least quarterly and before any policy version is approved. The system stores the adopted obligation and effective date rather than assuming an external webpage remains unchanged.

## 8. Quality Standards and Control Plans

A Quality Standard defines the requirement, scope, measurement method, acceptable range/result, sampling rule, evidence, responsible role, escalation, and effective dates. Standards may apply to Product, Product category, Supplier, storage class, facility zone, process, vehicle type, Customer contract, or jurisdiction.

A Control Plan assembles the applicable Standards for a Receipt, storage activity, sanitation task, load, Delivery, return, or investigation. The exact version used is preserved. Later policy changes do not alter prior decisions.

## 9. Product Safety and Traceability Profile

Each Product has an effective Safety Profile containing:

- Food/nonfood and storage classification
- Temperature requirements and excursion rules
- Lot/date-code availability and capture requirements
- Shelf-life basis and minimum remaining shelf life for normal shipment
- Food Traceability List applicability and exemption determination
- Allergen, raw/ready-to-eat, chemical, and segregation attributes
- Packaging/seal and damage criteria
- Recall/withdrawal risk tier
- Customer/contract-specific control requirements

Product is authoritative for stable commercial attributes; Quality owns the approved Safety Profile and supporting determination.

## 10. Supplier and Product Qualification

Quality participates in Supplier approval using licenses/registrations where applicable, insurance, food-safety programs, recall contacts, audit/certification evidence, complaint/recall history, traceability capability, cold-chain capability, corrective-action responsiveness, and Product specifications.

Supplier approval, Purchasing approval, and Product approval are distinct. A Supplier may be approved generally but restricted for a Product or storage class. Expired or unacceptable evidence creates a review, restriction, or Hold; it is not silently renewed.

Emergency sourcing requires documented risk review, General Management/Operations authority, inspection requirements, and prompt post-use qualification. Safety-critical requirements cannot be waived merely to fill demand.

## 11. Receiving Preconditions

Inbound trucks arrive by approved appointment; unscheduled arrival requires Receiving authorization. Before unloading, the business verifies Supplier/carrier, Purchase Order, vehicle identity, seal when applicable, prior-load/cleanliness evidence where required, required temperature condition, visible contamination risk, and Product documentation.

A failed precondition may cause refusal, segregated unloading for evaluation, or conditional Receipt under immediate Hold. Receiving status and Quality disposition remain separate.

## 12. Receiving Inspection

The receiving inspection links appointment, vehicle, Supplier, Purchase Order, Receipt, Product/Lot, inspector, Standard version, sampling basis, observation time, and result.

Checks may include identity, count, packaging, seal, labeling, lot/date code, expiration/best-by, remaining shelf life, temperature, pest/contamination evidence, odor/appearance, damage, thaw/refreeze evidence, and required documents.

Inspection coverage is risk-based but cannot omit a mandatory Standard. Accepted quantity remains a Receiving fact; Quality determines whether accepted Inventory is available, held, or restricted.

## 13. Temperature Control

Temperature requirements specify Product/storage/load context, target range, measurement location/method, instrument type, sampling frequency, excursion evaluation, and action.

Every observation retains actual time, Product/load/location, measured value/unit, instrument, person/device, expected limit, calibration status, source, and result. A missing or implausible observation is an exception, not assumed compliance.

An excursion immediately blocks affected Product pending evaluation. The decision considers magnitude, duration, Product characteristics, Supplier/manufacturer guidance, reliable evidence, and qualified authority.

## 14. Instruments and Calibration

Thermometers, probes, data loggers, scales used for quality control, and other measuring devices have permanent Equipment Numbers, approved use, accuracy/tolerance, location/custodian, calibration/verification schedule, status, and history.

Expired, failed, damaged, or unsuitable instruments cannot support an acceptance or release decision. A failed calibration triggers assessment of prior measurements since the last reliable check and may create related Nonconformances or Holds.

## 15. Package, Label, Lot, and Date Controls

The business records Supplier lot, traceability lot code when applicable, production/date codes, expiration/best-by date, and other identifying marks when supplied. This applies even to long-life shelf-stable Product.

Unreadable, missing, inconsistent, or mixed codes create an exception according to Product requirements. The business does not invent a Supplier lot. An internal handling lot or exposure group may organize evidence but cannot replace required Supplier/traceability identifiers.

The business never knowingly ships expired Product. Product below its minimum remaining shelf life is blocked from normal allocation and shipment.

## 16. Nonconformance

A Nonconformance records source, Product/Lot/location/load/process, quantity, Standard, observed failure, severity, detection time, detector, immediate containment, responsible owner, due date, evidence, and status.

Sources include Receipt inspection, storage/temperature monitoring, cycle count, picking, staging, loading, delivery, return, complaint, Supplier/regulatory notice, sanitation, pest activity, calibration, audit, and traceability review.

One event may affect multiple Products/Lots through explicit scope lines. Duplicate reports may be linked but not discarded until the common cause and full scope are confirmed.

## 17. Holds and Quarantine

A Quality Hold identifies its scope precisely: Product, Lot, Inventory unit, location, Receipt, load, vehicle, Supplier, Customer shipment, or defined exposure group. It records reason, risk, start time, authority, review deadline, and status.

An active Hold immediately makes affected stock ineligible for allocation, replenishment, picking, loading, dispatch, transfer outside controlled quarantine, or ordinary disposition. Existing Orders/loads become visible exceptions.

Quarantine is a controlled physical location/status, not merely a note. Movements into, within, and out of quarantine require authorization and remain Inventory transactions linked to the Hold.

## 18. Investigation and Risk Assessment

The investigation preserves question, scope, chronology, Product/Lot evidence, Suppliers, Receipts, Inventory movements, slot-placement times, temperatures, loads, Deliveries, Customers, complaints, tests, interviews, external notices, and alternative explanations.

Risk assessment considers hazard, severity, likelihood, susceptible Customers, distribution extent, remaining control, detectability, uncertainty, and regulatory/Supplier guidance. Hospitals, schools, and correctional institutions may require more urgent or explicit communication because of population and institutional controls.

Unknown information is recorded as unknown. Uncertainty expands containment until reliable evidence narrows it.

## 19. Samples and Tests

A Sample retains collection time/location, Product/Lot, quantity, method, collector, seal, chain of custody, storage/shipping condition, requested analysis, laboratory, and disposition.

A Test Result retains method/version, laboratory accreditation/evidence where required, result/unit, detection limits, interpretation, report, reviewer, and time. Preliminary, confirmed, invalid, and superseded results remain distinct.

A favorable sample does not automatically release an entire Lot unless the approved sampling/risk plan supports that conclusion.

## 20. Disposition and Release

Permitted dispositions include release, restricted release, Supplier return, rework by an authorized external party, discount sale with informed Customer acceptance, donation when safe/lawful, destruction/disposal, and other specifically approved action.

Expired or unsafe food cannot be sold or donated. Short-dated but safe Product may be discounted only with authorization and informed Customer acceptance. Restricted release identifies permitted Customers/use, quantity, time, and conditions.

Safety-critical release requires the Food Safety Leader or qualified backup and supporting evidence. Inventory executes the physical movement; Finance records credit, reserve, write-off, recovery, or other financial effect.

## 21. Storage and Handling Controls

Quality Standards cover dry/ambient, refrigerated, frozen, produce, nonfood, chemical, allergen, raw/ready-to-eat, returned, damaged, and quarantine zones.

Controls include temperature, humidity where applicable, sanitation, pest prevention, clearance, packaging integrity, chemical separation, allergen/cross-contact prevention, housekeeping, door/airflow discipline, and restricted access.

Warehouse records every Lot/pallet placement into a picking slot with actual date/time. Multiple Lots may occupy one picking slot when controlled. Picking normally depletes one Lot before the next, subject to FEFO, Product condition, exact-lot obligations, or Quality direction.

## 22. FEFO and Remaining Shelf Life

Physical rotation uses first-expiring, first-out. When expiration dates are equal, the Lot placed into the picking location earliest is selected first. Accounting valuation remains Finance FIFO and does not change physical selection.

Allocation checks the Product's minimum remaining shelf life at expected Customer delivery. A Product that would fall below the threshold is blocked before pick. Exceptions require safe Product, authorized commercial/Quality review, and informed Customer acceptance where appropriate.

FEFO overrides convenience and informal Sales reservation. A documented Quality decision may override FEFO to isolate risk or satisfy a stricter Customer specification.

## 23. Sanitation, Pest, and Facility Programs

Master Sanitation and Pest-Control Plans define areas/equipment, method/material, frequency, responsible role/vendor, prerequisite, verification, acceptable result, corrective action, and record retention.

Completed tasks record actual start/end, performer, chemicals/concentrations where relevant, preoperational release, findings, and verification. Missed or failed critical tasks can block affected areas or operations.

Pest sightings, evidence, service visits, trend points, corrective actions, and closure remain linked. Facility damage, condensation, drainage, refrigeration, door, dock, or contamination-control defects create assigned maintenance/Quality actions.

## 24. Allergen, Chemical, and Cross-Contamination Control

Business records declared allergens and handling/segregation requirements supplied with Product information. It preserves Supplier labels/specifications rather than making unsupported dietary or allergen guarantees.

Cleaning chemicals and other nonfood materials remain segregated from food in storage and transport. Raw Product, ready-to-eat Product, damaged/returned goods, allergens, and incompatible loads use defined separation and protection controls.

A label change, spill, package breach, co-loading conflict, or cleaning failure creates immediate assessment and Hold when safety may be affected.

## 25. Transportation Food Safety

Product/load requirements flow to Transportation before equipment assignment and loading. Preload verification covers vehicle suitability, cleanliness, odor/pest/contamination evidence, temperature capability, prior-load restrictions where applicable, compartment configuration, and instrument readiness.

Load controls cover Product compatibility, raw/ready-to-eat and chemical separation, airflow, door exposure, seal/security, temperature set point, loading sequence, and evidence transfer to the Driver.

Transportation owns vehicle, route, dispatch, in-transit observations, deviations, and Delivery condition. Quality owns the governing Standard and safety disposition. A temperature, seal, contamination, breakdown, or delay exception may require immediate stop, Hold, return, alternate storage, or Customer instruction.

## 26. Delivery Quality Exceptions

Delivery exceptions include Customer refusal, temperature concern, damage, shortage with safety implication, seal issue, contamination, late arrival affecting safe condition, and receiving-site rejection.

The Driver records actual time, Product/quantity, condition, Customer representative, evidence, and immediate action. Returned Product remains unavailable pending inspection. A Customer's acceptance does not override an objective business safety failure.

Revenue/credit treatment remains Finance/Sales policy; the Quality record determines safety eligibility and disposition.

## 27. Returns and Recovered Product

Returned food does not reenter available Inventory automatically. It is identified, segregated, and inspected using original shipment, elapsed time, custody, temperature, packaging, lot/date, reason, and tampering evidence.

Product outside the business control is normally unsuitable for resale unless an approved Product-specific policy and reliable evidence establish safety and integrity. Return authorization, physical receipt, Quality disposition, Inventory movement, Customer credit, and Finance effect remain distinct.

Stock recovery before Product leaves the business control is distinguished from market withdrawal and recall.

## 28. Customer Complaints and Suspected Illness

A Complaint records Customer/location/contact, Product, shipment, Lot/code if known, event/consumption dates, issue type, quantity, symptoms or injury allegation, remaining sample availability, photos/documents, urgency, responsible owner, and status.

Suspected illness, injury, allergen, foreign material, contamination, tampering, or multiple related complaints receive immediate Food Safety Leader escalation. The business provides no unsupported medical conclusion. Personal and medical details are restricted.

Complaint investigation links other Customers, Products, Lots, Receipts, Suppliers, and prior cases. Customer Service owns the relationship; Quality owns safety assessment; Finance/Sales owns credit after approved evidence.

## 29. Traceability Classification

Every Product/Lot is assigned an effective traceability level:

1. **Exact regulated lot** — required for covered Food Traceability List Products and any Product subject to comparable law.
2. **Exact contractual/risk lot** — required by Supplier, Customer contract, insurer, management risk decision, or active corrective action.
3. **Exposure-window trace** — normal method for other Products when exact outbound Lot capture is not required.

The level is determined before receiving/allocation and cannot be weakened after distribution. Product classification retains rationale, authority, obligation/contract reference, review date, and effective period.

## 30. Exact Lot Traceability

For exact-lot Products, the business captures the traceability lot code and required Key Data Elements at each applicable Critical Tracking Event, including receiving and shipping. The shipped Lot is recorded against the Delivery/Invoice Line or equivalent Customer shipment detail.

Supplier-provided traceability data is validated before covered Product becomes normally available. Picking/loading must preserve Lot identity through shipment confirmation. Mixed Lots are represented explicitly; inferred Lot assignment is not acceptable.

The business maintains a current Traceability Plan, location identifiers, Product descriptions, record-location explanation, and responsible contacts. Requested covered records must be exportable in the required sortable form within the applicable regulatory period; the bussiness' internal target is substantially faster.

## 31. Exposure-Window Traceability

For Products not requiring exact outbound Lot capture, the business uses:

- Supplier Receipt and Lot/date records
- Quantity and Inventory movement history
- Reserve-to-pick-slot placement date/time
- FEFO and one-Lot-before-next picking procedures
- Picking, staging, loading, Delivery, and Customer shipment times
- Remaining on-hand and disposed/returned quantities
- Known exceptions, adjustments, and count variance

The result identifies definite, likely, possible, and excluded Customer shipments with explained confidence and assumptions. The business does not describe an inferred Lot as exact.

## 32. Traceability Analysis and Product Accounting

A Trace Analysis begins from Supplier, Product, Lot/code, hazard, location, date range, Receipt, Customer complaint, or external notice. It traverses backward to source and forward to on-hand, staged, loaded, delivered, returned, transferred, donated, destroyed, and otherwise disposed quantities.

Product accounting reconciles total received/created exposure quantity to:

- Available/on-hold/quarantined on hand
- Shipped or otherwise transferred
- Returned to Supplier
- Destroyed, donated, or otherwise disposed
- Adjusted/count variance
- Unexplained difference

An unexplained difference is never forced to zero. It expands scope or remains an assigned Recall exception.

## 33. Withdrawal, Alert, and Recall Types

The business distinguishes:

- **Stock recovery:** controlled removal before Product leaves the business control
- **Market withdrawal:** correction/removal for a minor or nonregulatory issue
- **Public-health/regulatory alert:** external safety notice requiring assessment
- **Recall:** removal/correction of distributed Product because of a safety or regulatory problem

Classification records the source authority, hazard, scope, decision, decision time, responsible leader, and legal/regulatory review. The business may take protective action before final external classification.

FDA recall guidance addresses information supplied to the agency, Customer notification, recall monitoring, and documentation. The business maintains a reusable recall package aligned to that guidance. [FDA—Product Recalls, Including Removals and Corrections](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/product-recalls-including-removals-and-corrections)

## 34. Recall Initiation and Command

A Recall Case identifies Product/Lot/code, hazard, affected date/location range, Supplier/manufacturer/regulator source, recall type/classification when assigned, initiation time, Recall Coordinator, executive owner, legal/regulatory contacts, and status.

Activation immediately creates:

- Product/Lot/Supplier/Inventory/Order/load Holds as appropriate
- Trace analysis and product-accounting work
- Customer and regulator/Supplier communication work
- Inventory recovery/disposition tasks
- Effectiveness checks and management reporting cadence

The Food Safety Leader may initiate containment without waiting for owner approval. Scope reduction requires documented evidence and authorized review.

## 35. Recall Scope and Internal Targets

The business' internal target is to establish initial on-hand/in-process containment and a preliminary forward/backward trace within two hours of activation. It targets initial affected-Customer notification within four hours of the recall decision, or sooner when hazard severity or authority requires.

These are operating targets, not substitutes for a stricter legal, regulator, Supplier, or Customer requirement. Incomplete data does not delay protective notification; the notice identifies uncertainty and is updated.

The scope version records included/excluded Products, Lots, dates, locations, Receipts, shipments, Customers, and rationale. Every change preserves its prior version.

## 36. Inventory and Operational Containment

Recall containment searches available, allocated, reserve, picking, staged, loaded, in-transit, returned, damaged, quarantine, and pending-disposition stock. It also examines open Purchase Orders, inbound appointments, Customer Orders, substitutions, and planned Deliveries.

Warehouse and Drivers confirm physical count/location against the Hold. Sales prevents new commitment. Purchasing stops or controls inbound supply. Transportation stops or redirects affected loads. Finance preserves associated credit, reserve, and loss references.

Recovered Product is labeled, secured, counted, and moved only under Recall/Quality authority.

## 37. Customer Notification and Response

Recall Notices identify affected Product, package/size, Lot/code/date or exposure window, shipment/delivery references, hazard, required action, segregation/disposition instruction, urgency, response method, contact, and notice version.

Contacts use the Customer Location's approved emergency/receiving/food-safety contacts and multiple channels when warranted. Institutional Customers receive location-specific evidence adequate to control their own kitchens, units, patients, students, residents, or guests.

Each response records confirmed receipt, affected quantity, on-hand/used/disposed/transferred quantity, action, evidence, responder, time, follow-up, and unresolved status. No response is not treated as successful notification.

## 38. Supplier, Regulator, and Public Communication

Supplier/manufacturer communication preserves notice, scope, instructions, credits/recovery terms, requested data, responses, and changes. The business independently protects Customers even if commercial terms remain unresolved.

Regulatory communication records agency, jurisdiction, contact, report/submission, date/time, confirmation, requested information, response deadline, and provided dataset/version. FDA-regulated and USDA-FSIS-regulated Product paths remain distinguishable.

Only authorized spokespeople issue public statements. Public messaging must be accurate, timely, consistent with regulator/recalling-firm coordination, and version controlled.

## 39. Effectiveness Checks

Recall effectiveness checks verify that notices reached the correct Customer locations, affected Product was identified and controlled, instructions were understood, downstream transfers were addressed, and response evidence is credible.

The checking plan uses risk-based coverage, independent review where practical, attempt cadence, escalation, and completion criteria. Failed or unreachable checks create immediate follow-up and may expand communication.

Customer response supplied by a Salesperson is evidence but does not replace required Customer confirmation.

## 40. Recall Reconciliation and Closure

Recall reconciliation compares distributed exposure, Customer responses, recovered/destroyed/on-hand amounts, credits, outstanding Product, and unexplained variance. Quantity and status must reconcile without an unexplained plug.

Closure requires authorized determination that containment, notification, effectiveness checks, recovery/disposition, regulator/Supplier requirements, financial handoff, root cause, and corrective actions are completed or formally assigned.

The Recall Case and final report remain immutable. Later facts create an addendum or reopen event.

## 41. Mock Recalls and Readiness Tests

The business conducts at least two documented mock recalls each year, rotating dry, refrigerated/frozen, and produce/high-risk conditions. Once exact traceability applies, at least one annual exercise uses a covered Food Traceability List Product.

A drill measures containment time, backward/forward trace time, data completeness, Customer contact readiness, quantity reconciliation, staffing/backup readiness, export production, and corrective actions. Drill messages and records are clearly marked as exercises but use the same business process.

Failure to meet target creates Corrective Action; it is not erased by repeating the exercise.

## 42. Corrective and Preventive Action

A Corrective/Preventive Action case links Nonconformance, complaint, audit, incident, recall, Supplier, Product, process, or trend. It records containment, problem statement, root-cause method/result, correction, preventive action, owner, due date, evidence, effectiveness test, and closure.

Actions may change Supplier status, Product specification, inspection frequency, training, sanitation, storage, transportation, equipment, procedure, or commercial availability. Each owning domain executes its controlled change and reports completion.

Closure requires evidence that the action addressed the cause and did not create an unacceptable new risk.

## 43. Training and Competence

Quality defines training/competence requirements for Receiving, Warehouse, sanitation, loading, Drivers, Customer Service, Purchasing, managers, Recall Team members, and backups. Workforce owns Employee training and qualification records.

Requirements include role, content/version, initial/refresher cadence, practical demonstration where needed, expiration, and blocking effect. Transportation sanitary-practice training and recall responsibilities are explicit.

An expired qualification blocks affected safety-sensitive work. Attendance alone is not proficiency when a demonstration or assessment is required.

## 44. Documents, Agreements, and Regulatory Calendar

Controlled documents include policies, SOPs, Product/Supplier Standards, sanitation plans, transportation agreements, Traceability Plan, Recall Plan, emergency contacts, forms, regulator/Supplier instructions, and training materials.

Each document has owner, version, approval, effective date, superseded version, distribution/acknowledgment needs, and retention class. Only the effective version is available for routine work; prior versions remain immutable.

The compliance calendar assigns license, registration, inspection, audit, certification, calibration, training, plan review, mock recall, filing, and evidence-renewal work with owner, due date, backup, status, and escalation.

## 45. Logical Business Structures

| Structure | Natural business key |
|---|---|
| Quality Standard | `quality_standard_code` + effective from |
| Control Plan | `control_plan_code` + version |
| Product Safety Profile | Product Number + effective from |
| Supplier Quality Approval | Supplier Number + approval type + effective from |
| Inspection | `inspection_number` |
| Inspection Observation | Inspection Number + observation sequence |
| Temperature Observation | `temperature_observation_number` |
| Measuring Equipment | Equipment Number |
| Calibration/Verification | Equipment Number + event sequence |
| Nonconformance | `nonconformance_number` |
| Quality Hold | `quality_hold_number` |
| Hold Scope | Quality Hold Number + scope sequence |
| Investigation | Nonconformance/Complaint/Recall key + investigation sequence |
| Sample | `sample_number` |
| Test Result | Sample Number + test sequence + result version |
| Disposition Decision | Quality Hold Number + decision sequence |
| Sanitation Plan | `sanitation_plan_code` + version |
| Sanitation Task | Plan/version + task sequence |
| Pest Observation/Service | `pest_event_number` |
| Customer Complaint | `complaint_number` |
| Traceability Classification | Product Number + effective from |
| Trace Analysis | `trace_analysis_number` |
| Trace Scope/Result | Trace Analysis Number + version + line sequence |
| Recall Case | `recall_number` |
| Recall Scope | Recall Number + scope version + line sequence |
| Recall Notice | Recall Number + notice sequence + version |
| Recall Customer Response | Recall Number + Customer Location + response sequence |
| Effectiveness Check | Recall Number + check sequence |
| Recall Product Accounting | Recall Number + reconciliation version + line sequence |
| Mock Recall | `mock_recall_number` |
| Corrective/Preventive Action | `capa_number` |
| Controlled Document | `controlled_document_number` + version |
| Compliance Obligation | `compliance_obligation_code` + effective from |
| Compliance Task | Obligation code + due date + task sequence |

Parent-relative sequences are governed, permanent within the parent, and never reused. Natural business keys are mandatory; surrogate and simulation-session keys are prohibited.

## 46. Lifecycles and Integrity Rules

- Suspect safety immediately permits Hold before investigation is complete.
- Active Hold scope cannot be available, allocated, picked, loaded, dispatched, or ordinarily delivered.
- Release/disposition requires current evidence, authority, and full scope.
- Inspection and Test Result versions never overwrite prior evidence.
- Expired Product cannot receive a sell/donate disposition.
- Exact-lot Product cannot ship without required lot/KDE completion.
- Exposure-window analysis labels confidence and never claims inferred Lot certainty.
- Recall scope only narrows through authorized evidence-backed revision.
- Customer response and effectiveness check remain distinct.
- Product accounting cannot force unexplained difference to zero.
- Closed Recall and CAPA records cannot be altered; addendum/reopen records preserve change.

## 47. Events and Integration

Quality publishes Product Restricted, Hold Placed/Expanded/Released, Disposition Approved, Temperature Excursion, Qualification Changed, Recall Activated/Expanded/Closed, Customer Notice Required, and CAPA Due/Closed events.

Events carry actual/business time, recorded time, permanent source key/version, scope, reason, authority, and correlation. Consumers process idempotently and retain receipt/consequence. Publication failure never leaves a safety Hold effective only inside Quality; a transactionally durable outbox and exception escalation are required.

Inbound Supplier, Receipt, Inventory, Warehouse, Transportation, Sales, Customer Service, Workforce, and Finance events provide evidence and trigger evaluation without granting direct update authority.

## 48. Approvals and Segregation of Duties

| Activity | Required control |
|---|---|
| Immediate safety Hold | Food Safety Leader, backup, or trained authorized employee |
| Safety-critical release | Qualified Food Safety Leader/backup with evidence |
| Supplier/Product approval | Purchasing plus independent Quality review |
| Receipt acceptance under exception | Receiving evidence plus Quality disposition |
| Short-dated discount/donation | Quality safety approval plus commercial/Finance authority |
| Destruction/disposal | Quality authorization, witnessed quantity, Inventory movement |
| Recall activation | Food Safety authority; owners informed promptly |
| Recall scope reduction/closure | Evidence-backed independent review |
| Customer/regulator/public notice | Authorized Recall role and version approval |
| CAPA closure | Owner completion plus effectiveness review |

The person performing a safety-sensitive inspection does not approve an exception release without authorized independent review where staffing permits.

## 49. Reports and Measures

- Active Holds by Product/Lot/location/Supplier/load and affected demand
- Receiving inspection pass/fail, temperature, damage, and Supplier trend
- Short-dated/expired Product and remaining-shelf-life risk
- Storage/transport temperature exceptions and response time
- Sanitation, pest, calibration, and facility-control completion
- Complaints by Product/Supplier/Customer/reason/severity and repeat pattern
- Traceability classification and missing KDE/lot evidence
- Recall readiness, trace time, contact completeness, and quantity reconciliation
- Recall notices, responses, effectiveness checks, and unresolved exposure
- Supplier/Product restriction and CAPA aging/effectiveness
- Disposal, credit, recovery, and Quality-cost references
- Training/qualification readiness and expiring requirements

Safety metrics are not reduced to financial impact. Missing or late data remains visible rather than excluded from the denominator.

## 50. Security, Audit, and Retention

Access separates general Quality work, safety leadership, recall coordination, complaint medical details, regulatory communication, disposition approval, reporting, and audit. Customer medical/contact data and protected investigation information receive restricted access.

Audit records include actual/business/recorded times, Principal/process, permanent record key/version, action, prior/new status or controlled value, source, reason, approval, scope, and correlation. Direct update/delete of approved evidence, Holds, dispositions, notices, responses, reconciliations, and closure records is prohibited.

Retention follows the stricter applicable regulatory, contractual, insurance, tax/accounting, litigation-hold, and the business policy requirement. Traceability records must be locatable and exportable throughout retention; archived does not mean inaccessible.

## 51. Business Continuity and Simulation

During system outage, authorized personnel use controlled numbered Hold, inspection, temperature, movement, load, complaint, and recall forms. Safety Holds are communicated directly to affected operating leaders and later entered with actual and entry times.

Recovery reconciles Products, Lots, quantities, locations, Orders, loads, Deliveries, notices, and prior actions before normal availability resumes. Duplicate entry cannot release a Hold or send contradictory Recall scope.

Simulation creates ordinary Nonconformances, Holds, complaints, trace analyses, Recalls, notices, responses, dispositions, and CAPAs. Business time/randomness may be externally controlled, but no Quality/Recall primary key contains Simulation Session.

## 52. Decisions Established

- Food safety overrides Sales, availability, schedule, Supplier relations, and loss avoidance.
- The business designates a Food Safety Leader and qualified backup with stop/Hold authority.
- Lot and expiration/date codes are recorded when supplied, including shelf-stable Products.
- FEFO governs physical rotation; Finance FIFO governs valuation.
- Picking-slot placement date/time is recorded for every Lot/pallet.
- Multiple Lots may share a pick slot, but one Lot is normally depleted before the next.
- Expired Product is never sold or donated; short-dated safe Product requires controlled exception.
- Exact outbound Lot capture is required for regulated, contractual, or risk-designated Products.
- Other Products use an evidence-based exposure window without claiming false exactness.
- Internal recall targets are two hours for preliminary containment/trace and four hours for initial affected-Customer notice.
- The business performs at least two mock recalls annually.
- Safety Holds, release, Recall scope, and closure are authorized, versioned, and auditable.
- Natural business keys are mandatory; surrogate and simulation-session keys are prohibited.

## 53. Remaining Configuration

Opening Product safety profiles, Food Traceability List mapping/exemptions, Quality Standards/limits, sampling frequencies, minimum shelf-life thresholds, Supplier evidence, approved laboratories, equipment/calibration intervals, sanitation and pest plans, segregation map, Hold labels/locations, Recall Team contacts, notification templates/channels, regulatory contacts, CAPA thresholds, document retention, and report layouts are configuration—not unresolved architecture.

## 54. Acceptance Criteria

The design is acceptable when the business can prevent suspect Product from normal use; preserve Receipt-through-Disposition evidence; distinguish exact Lot from inferred exposure; identify affected stock and Customers rapidly; issue and confirm controlled notices; reconcile Product without forced balances; execute and close Recall/CAPA work with authority; and simulate the same process using ordinary records.

## 55. Authoritative External References

- [FDA Food Traceability Final Rule](https://www.fda.gov/food/food-safety-modernization-act-fsma/fsma-final-rule-requirements-additional-traceability-records-certain-foods)
- [FDA Food Traceability List](https://www.fda.gov/food/food-safety-modernization-act-fsma/food-traceability-list)
- [FDA Sanitary Transportation of Human and Animal Food](https://www.fda.gov/food/food-safety-modernization-act-fsma/fsma-final-rule-sanitary-transportation-human-and-animal-food)
- [FDA Product Recalls, Including Removals and Corrections](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/product-recalls-including-removals-and-corrections)
- [USDA-FSIS Recalls and Public Health Alerts](https://www.fsis.usda.gov/recalls)

External requirements are verified again during detailed configuration and before implementation or production use.

## 56. Next Design Work

Next: **Quality, Food Safety, and Recall PostgreSQL Build Specification**. It will define normalized PostgreSQL structures, natural keys, controlled functions, constraints, privileges, indexes, views, verification, and tests without executable SQL.
