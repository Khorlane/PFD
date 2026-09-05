# \<business name>
# Management Reporting and Audit PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0187`–`0205`  
**Depends on:** Cumulative PFD design through `0186`; PFD Management Reporting and Audit Domain Specification

## 1. Purpose

Define normalized PostgreSQL structures, natural keys, controlled functions, privileges, indexes, views, reconciliation, and tests for PFD reporting, KPIs, alerts, management actions, data quality, formal snapshots, audit, access review, retention, and legal hold.

## 2. Required Outcome

- Definitions and results preserve purpose, version, source, time basis, and owner.
- Runs and snapshots reproduce what management saw.
- Summary results reconcile to authorized source facts and support drill-through.
- Missing/late/estimated/unreconciled data remains visible.
- Alerts and material exceptions become assigned actions.
- Audit is append-only, attributable, access-controlled, and distinct from application logging.
- Natural keys are used throughout; no business table contains a Simulation Session key.

## 3. Platform and Package

PostgreSQL 15 or later; existing schemas through `quality`; cumulative manifest `12.0.0`; immutable changes `0001`–`0186`; changes `0187`–`0205`. `reporting` owns report/KPI/action/quality/reconciliation records; `audit` owns Audit Events, access reviews, retention execution, and legal holds.

## 4. Standards

Use lowercase `snake_case`, singular tables, uppercase codes, `numeric(19,6)` measures, `numeric(19,4)` money, `date` for business dates, and `timestamptz` for requests/events/as-of cutoffs. Definition versions are effective-dated; results/snapshots/audit are append-only.

Business numbers/codes and governed composites are primary keys. Full natural keys propagate. Identity, serial, UUID, generic hidden IDs, nullable key placeholders, and Simulation Session columns are prohibited in ordinary records.

## 5. Controlled Numbers and Reference Data

Change `0187` adds permanent sequences:

| Sequence | Example |
|---|---|
| `REPORT_RUN` | `RPT00000001` |
| `FORMAL_REPORT_DOCUMENT` | `FRD00000001` |
| `ALERT` | `ALT00000001` |
| `MANAGEMENT_ACTION` | `MGA00000001` |
| `RECONCILIATION_RUN` | `RRN00000001` |
| `DATA_QUALITY_RUN` | `DQR00000001` |
| `AUDIT_EVENT` | `AUD0000000001` |
| `ACCESS_REVIEW` | `ACR00000001` |
| `LEGAL_HOLD` | `LGH00000001` |

References cover report/run/snapshot status, cadence, sensitivity, output format, KPI direction/status, alert severity/status, action status, reconciliation result, data-quality dimension/result, audit action/confidentiality, access-review result, retention disposition, and legal-hold status.

## 6. Report Definitions

`reporting.report_definition` PK report code + effective-from stores name, purpose, business owner role, sensitivity, cadence, source domains, time basis, retention class, active status, and effective-to.

`reporting.report_parameter_definition` PK report definition key + parameter code stores data type, required/default behavior, allowed source, validation, display order, and sensitivity.

`reporting.report_column_definition` PK report definition key + column sequence stores name, type/unit/currency, formula/source description, aggregation, visibility, drill-through, and sensitivity.

`reporting.report_control_definition` PK definition key + control sequence stores expected count/amount/relationship, tolerance, failure severity, and blocking behavior.

Approved definition versions are immutable and nonoverlapping.

## 7. Report Runs and Parameters

`reporting.report_run` uses `report_run_number` as PK and stores definition version, requestor/process, requested/as-of/source-cutoff times, business/accounting periods, timezone, status, started/completed times, warnings, row count, control status, and error.

`reporting.report_run_parameter` PK Run + parameter code stores typed value in one permitted typed column, source/default indicator, validation, and sensitivity. Type constraints prohibit ambiguous parallel values.

`reporting.report_source_snapshot` PK Run + source sequence stores schema/entity, source version/cutoff/checksum, included/excluded state, completeness, and warning.

## 8. Report Results and Drill-Through

`reporting.report_result` PK Run + result sequence stores governed grouping/dimension keys, display sequence, typed values or approved compact result payload, completeness, warning, and lineage sequence.

Known high-value standard reports use relational result tables/views rather than opaque JSON. JSON is permitted only for definition/parameter contracts or presentation payloads whose business facts remain in source tables.

`reporting.report_result_source` PK Run + result sequence + source sequence stores source domain/entity and complete serialized natural key, contribution type/amount, and access policy. Drill-through resolves the source through governed services/views.

## 9. Run Controls and Reconciliation

`reporting.report_run_control` PK Run + control sequence stores expected/actual values, difference, tolerance, pass/fail, evidence, resolver, and status.

A failed blocking control prevents formal publication. Nonblocking warning requires visible disclosure. No control record can be overwritten after publication.

## 10. Formal Snapshots and Distribution

`reporting.formal_report_snapshot` PK Run + snapshot sequence stores permanent document number, format, checksum, byte size, rendered/generated time, publisher/approver, publication status, superseded snapshot, and retention.

`reporting.report_distribution` PK snapshot key + distribution sequence stores recipient role/Party/contact/channel, sensitivity authorization, sent/delivered/failed times, acknowledgment requirement/time, and status.

Correction produces a new Run/snapshot or authorized superseding snapshot; published bytes/checksum remain immutable.

## 11. KPI Definitions and Targets

`reporting.kpi_definition` PK KPI code + effective-from stores name, purpose, owner, formula, numerator/denominator, source, unit, dimensions, time basis, target direction, completeness rule, and effective-to.

`reporting.kpi_target` PK KPI definition key + target-scope code + period start stores dimension scope, target/warning/critical values, approved Budget/plan source, authority, and period end.

`reporting.kpi_result` PK KPI definition key + result period/as-of + dimension type + dimension natural-key text stores actual/target, status, completeness, Report Run, explanation, and source checksum. Controlled `TOTAL` represents an intentionally undimensioned result.

## 12. Executive Scorecard

`reporting.scorecard_definition` PK scorecard code + effective-from; `scorecard_section` PK definition + section code; `scorecard_metric` PK definition + section + sequence links KPI/report, display/trend/alert behavior, and security.

`reporting.scorecard_snapshot` PK scorecard definition + as-of time + version stores source Runs, completeness, approved/published status, and checksum. It references KPI Results rather than copying mutable values.

## 13. Alerts and Notifications

`reporting.alert_rule` PK alert rule code + effective-from stores source event/KPI/control, condition, threshold/version, suppression/deduplication window, severity, owner/escalation, and effective-to.

`reporting.alert` uses `alert_number` as PK and stores rule version, source natural key/event, detected/due times, severity, assigned role/Principal, acknowledgment/resolution/closure states, and row version.

`reporting.alert_notification` PK alert + notification sequence stores recipient/channel, attempt, delivery/acknowledgment, failure, and escalation. Acknowledgment cannot close the Alert.

## 14. Management Actions

`reporting.management_action` uses `management_action_number` as PK and stores source KPI/Run/Alert/reconciliation/exception/audit key, action, owner, due date, expected result, priority, status, and row version.

`reporting.management_action_event` PK action + event sequence stores assignment, progress, extension, completion, verification, reopen, evidence, Principal, and time. Extensions preserve original due date and authority.

## 15. Reconciliation Definitions and Runs

`reporting.reconciliation_definition` PK reconciliation code + effective-from stores left/right sources, grouping/natural-key mapping, amount/quantity/count controls, timing treatment, tolerance, frequency, owner, and effective-to.

`reporting.reconciliation_run` uses `reconciliation_run_number` as PK and stores definition version, period/as-of/cutoff, preparer/reviewer, totals/difference, status, and row version.

`reporting.reconciliation_item` PK Run + item sequence stores left/right natural keys/values, difference, timing/explained/unexplained classification, owner, resolution source, and status.

An unexplained difference cannot be converted to explained without evidence.

## 16. Data-Quality Rules and Runs

`reporting.data_quality_rule` PK rule code + effective-from stores domain/entity/field/scope, quality dimension, evaluation, severity, threshold, owner, report/business impact, and effective-to.

`reporting.data_quality_run` uses `data_quality_run_number` as PK and stores rule/version set, cutoff, started/completed times, counts, result, and status.

`reporting.data_quality_result` PK Run + rule code/version + result sequence stores affected natural key, observed/expected state, severity, impact, assigned owner, due time, resolution, and status.

## 17. Audit Events

`audit.audit_event` uses `audit_event_number` as PK and stores environment code, domain/schema/entity, full natural-key text, action code, actual/business/recorded times, Principal/process, source, correlation, prior/new controlled values, reason, approval reference, confidentiality, integrity checksum, and retention class.

`audit.audit_event_relationship` PK Audit Event + related event sequence links source/consequence/reversal/correction/security event without replacing business lineage.

Audit insertion uses tightly controlled security-definer functions/services. Update/delete is denied to all application roles.

## 18. Access Review and Protected Export

`audit.access_review` uses `access_review_number` as PK and stores scope, as-of time, reviewer/approver, due/completed times, totals, result, and status.

`audit.access_review_item` PK review + item sequence stores Principal/service role/object privilege, business owner, continued-need decision, segregation conflict, remediation, due/completed times, and evidence.

`audit.protected_data_export` PK export number + event sequence stores requestor, source Report/records, purpose, sensitivity, authorization, row/byte count, destination class, expiry, and Audit Event.

## 19. Retention and Legal Hold

`audit.retention_policy` PK retention code + effective-from stores record class, trigger, duration, archive/disposition rule, owner, authority, and effective-to.

`audit.retention_execution` PK retention code/version + execution time + batch sequence stores evaluated/held/disposed counts, evidence, operator/process, and result.

`audit.legal_hold` uses `legal_hold_number` as PK; normalized scope lines identify domains/entities/business keys/date ranges/Parties. Release requires authority and retains all execution evidence.

## 20. Standard Reporting Views

Governed views cover active exceptions/Holds; current Customer/Supplier/Product/Employee/Asset status; Order-to-cash; procure-to-pay; Inventory/Warehouse; route/Delivery; Quality/Recall; Workforce/Payroll; Finance statements/reconciliations; executive scorecard; overdue actions; and data-quality status.

Views use security barriers/row filtering where needed, expose as-of/source fields, and do not permit writes.

## 21. Materialized Results and Refresh

Materialized views are permitted only for performance where freshness, refresh ownership, failure visibility, and source reconciliation are defined. They are caches, not records of authority.

Concurrent/scheduled refresh records begin/end/cutoff, source versions, row/control totals, result, and failure. Stale results are labeled and may be blocked from formal publication.

## 22. Controlled Functions

Required transaction-safe functions include definition/version maintenance; request/execute/finalize Report Run; record source/control/result lineage; publish/supersede snapshot; distribute output; calculate KPI/scorecard; open/acknowledge/resolve Alert; create/complete/verify action; execute reconciliation/data-quality run; append Audit Event; conduct access review; authorize protected export; apply retention; and place/release legal hold.

Functions validate Principal, business-owner authority, sensitivity, effective version, source cutoff, row version, control totals, deterministic locks, and idempotency. `PUBLIC` execution is denied.

## 23. Integrity and Concurrency

- Definition effective ranges cannot overlap ambiguously.
- Runs reference one exact definition version and immutable parameters/cutoff.
- Published snapshots require passed blocking controls and authorization.
- KPI Results reference exact definitions/targets and unique time/dimension scope.
- Alerts deduplicate under the active rule without losing repeated occurrences.
- Management Actions retain extensions, completion, verification, and reopen history.
- Reconciliation/data-quality differences cannot be hidden.
- Audit Events and published results reject update/delete.
- Retention cannot dispose of legal-held or required source evidence.

Locks follow definition, Run, snapshot, KPI scope, Alert source, action, reconciliation, legal hold, then retention batch order.

## 24. Security and Privileges

Roles separate definition administration, report operation, publication, financial/regulatory approval, dashboard consumption, restricted Payroll/HR/credit/quality views, audit writing, audit review, access review, retention, and database administration.

Report privileges never broaden underlying data rights unless an explicitly approved aggregate/masked view provides safe access. Service identities receive only named functions and required views.

## 25. Indexes and Partitioning

Indexes support Run status/cadence/as-of, definition versions, KPI period/dimension, open Alerts/actions, reconciliation/data-quality exceptions, snapshot publication, distribution failure, Audit entity/key/time/Principal/correlation/confidentiality, access remediation, legal-hold scope, and all FKs.

High-volume Audit Events and Report Results may use time-based declarative partitioning while retaining their natural PK through partition-key design. Partition creation, validation, retention, and legal-hold protection are automated and audited.

## 26. Continuity and Simulation

Critical report definitions/templates are controlled and backed up. Recovered Runs identify missing/late source intervals and never masquerade as uninterrupted final output.

Reports query ordinary business tables in the current database copy. Simulation may initiate Runs externally; no ordinary reporting/audit primary key or source row includes Simulation Session.

## 27. Change Order

| Change | Content |
|---|---|
| `0187` | Add reporting/audit sequences and reference data |
| `0188` | Create Report Definitions, parameters, columns, and controls |
| `0189` | Create Report Runs, parameters, source snapshots, and controls |
| `0190` | Create Report Results and drill-through lineage |
| `0191` | Create Formal Snapshots and distribution |
| `0192` | Create KPI Definitions, targets, and results |
| `0193` | Create scorecards, sections, metrics, and snapshots |
| `0194` | Create Alert Rules, Alerts, notifications, and escalation |
| `0195` | Create Management Actions and immutable events |
| `0196` | Create Reconciliation Definitions, Runs, and Items |
| `0197` | Create Data-Quality Rules, Runs, and Results |
| `0198` | Create Audit Events and relationships |
| `0199` | Create Access Reviews, items, and protected exports |
| `0200` | Create Retention Policies/executions and Legal Holds/scope |
| `0201` | Create standard operational/management reporting views |
| `0202` | Create materialized-result refresh controls |
| `0203` | Create controlled functions and cross-domain reporting contracts |
| `0204` | Apply roles, privileges, indexes, partitions, comments, and audit protections |
| `0205` | Apply deferred constraints and final package assertions |

## 28. Verification and Tests

Verification proves contiguous checksums through `0205`; exact natural keys; normalized definitions/results; no Simulation Session columns; immutable audit/snapshots; effective versions; full-key FKs; security barriers; privileges; indexes/partitions; retention/legal hold; and standard views.

Disposable tests cover definition change/history; typed parameters; source cutoff; failed/passed controls; publication/supersession; restricted distribution; KPI/target versions; scorecard completeness; alert deduplication/escalation; action extension/reopen; cross-domain reconciliation; data-quality failure; audit immutability; protected export; access review; legal hold versus retention; stale materialized view; outage recovery; and ordinary-data simulation reporting.

## 29. Acceptance Criteria

The package must build incrementally through `0205`, rerun as a no-op, and demonstrate reproducible/as-of reporting, reconciled measures, immutable formal/audit evidence, visible data quality, controlled action follow-up, least-privilege distribution, and natural-key integrity.

## 30. Deferred Configuration

Opening definitions, parameters, report formats, KPIs/targets, alert thresholds/channels, recipients, schedules, reconciliation/data-quality rules, materiality, retention periods, access-review cadence, and dashboard layout are configuration.

## 31. Next Design Work

Next: **PFD Simulation Execution and Scenario-Control Specification**. Executable Reporting/Audit SQL remains deferred until PFD leaves Design Land.
