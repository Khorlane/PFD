# Management Reporting and Audit Domain Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Business and logical domain design; executable SQL not included  
**Depends on:** Design through the Quality, Food Safety, and Recall PostgreSQL Build Specification

## 1. Purpose

Define how the business converts authoritative operating and financial facts into timely reports, measures, alerts, management actions, formal snapshots, and audit evidence without creating competing versions of business truth.

## 2. Required Outcomes

- Owners and managers see the condition of the business at the right cadence and level.
- Every measure has a governed definition, source, owner, time basis, and reconciliation rule.
- Reports distinguish current operational status, historical business results, accounting periods, forecasts, and exceptions.
- Users can drill from summarized results to authorized source transactions.
- Formal reports and published snapshots are immutable and reproducible.
- Material exceptions become assigned actions with due dates and verification.
- Audit evidence shows who did what, when, why, under which authority, and with what result.
- Reporting and audit never become editable alternate masters.

## 3. Business Context

The business owner roster, ownership interests, and management assignments are effective-dated configuration. Required management responsibilities include General Management, Sales, Operations and Purchasing, and Finance and Administration, but the design does not assume a fixed owner count or percentage split.

Routine operating decisions belong to responsible departments. Cross-department decisions belong to General Management within policy. Reserved matters require the approvals defined by effective governance configuration. Reporting must show the applicable roster, thresholds, votes, and authority model as of the decision time.

## 4. Scope

The domain owns Report/KPI definitions, report requests/runs, governed parameters, derived results, formal snapshots, dashboard/alert presentation, management actions, data-quality/reconciliation results, audit evidence, access-review evidence, and report retention/distribution.

Each source domain owns its facts and domain-specific operational documents. Finance owns formal accounting records and financial-statement approval. Quality owns regulatory food-safety evidence. Workforce/Payroll owns protected employment/payroll details. Reporting uses those facts under governed access.

## 5. Reporting Principles

1. One authoritative source per business fact.
2. Definitions are versioned and effective-dated.
3. Every result states as-of time, business/accounting period, timezone, units, and filters.
4. Missing, late, excluded, estimated, and unreconciled data is visible.
5. Detail-to-total reconciliation is required.
6. Formal snapshots are immutable; corrections create a new version.
7. Reports do not update source transactions.
8. Access follows least privilege and business need.
9. Natural business codes/numbers identify all governed records.

## 6. Time and Comparison Bases

Reports explicitly distinguish:

- Actual event time and recorded time
- Business date and operating cycle
- Scheduled delivery date
- Payroll period and workweek
- Accounting date/period and fiscal year
- As-of snapshot time
- Prior day/week/month/year and budget/forecast comparison

Sunday warehouse activity may support Monday delivery while remaining on its actual calendar date. Financial results use posted accounting evidence; operational dashboards may include clearly labeled pending activity.

## 7. Information Layers

| Layer | Purpose |
|---|---|
| Transaction inquiry | Authorized view of one business record and lifecycle |
| Operational worklist | Current tasks, holds, due work, and exceptions |
| Operational dashboard | Current capacity, flow, service, and risk |
| Management report | Period performance, trend, cause, and action |
| Financial/regulatory report | Formally controlled domain result |
| Published snapshot | Immutable evidence of what was issued |

The layers may share governed definitions but cannot silently mix pending and posted data.

## 8. Report Definition

A Report Definition identifies report code/name, business purpose, owner, audience, data sources, parameter contract, result fields, calculation logic, time basis, refresh/run cadence, retention, sensitivity, drill-through, control totals, and effective version.

Material definition changes require owner review, comparison to the prior definition, effective date, and communication. Historical snapshots remain tied to their original definition.

## 9. Report Runs and Snapshots

A Report Run records definition/version, requestor, parameters, as-of/cutoff, source-version evidence, started/completed times, row/control totals, status, warnings, and failure reason.

A Formal Report Snapshot preserves output checksum, format, distribution version, publisher, publication time, superseded snapshot, and retention. Reissuing corrected content creates a linked new snapshot.

## 10. KPI Definition and Governance

A KPI defines purpose, formula, numerator/denominator, sources, inclusions/exclusions, unit, dimensions, time basis, target direction, target/threshold ownership, refresh cadence, data-quality requirement, and effective version.

KPI results retain actual, target, status, source Run, completeness, and explanatory notes. Definitions do not change merely to improve apparent performance.

## 11. Opening Executive Scorecard

The Owner scorecard covers:

- Sales, gross margin, Orders, average order, and Customer activity
- Fill rate, shorts, substitutions, Backorders, and service exceptions
- Inventory availability, turns, aging, short-date, spoilage, and count variance
- Supplier fill/on-time/quality performance and purchasing commitments
- Warehouse productivity, completion, replenishment, and capacity exceptions
- Route/Delivery completion, on-time service, miles, capacity, and exceptions
- Quality Holds, complaints, traceability readiness, Recalls, and CAPA
- Workforce coverage, absence, overtime, turnover, and qualification readiness
- Cash, AR/AP, borrowing, profitability, budget variance, and close status

Each metric provides trend and drill-through rather than a color alone.

## 12. Daily Management Cycle

Before daily execution, managers review demand, inventory/credit/quality Holds, receiving appointments, staffing/qualification, fleet readiness, weather/route constraints, and cash-critical exceptions.

During operations, worklists emphasize overdue or blocked receiving, replenishment, picking, loading, dispatch, Delivery, customer-service, temperature, and safety work.

After the delivery cycle, review uncompleted Orders, route/Delivery exceptions, returned Product, invoice effects, receipts/payments, labor usage, and required next-day action.

## 13. Weekly Management Cycle

Weekly review covers Sales/margin, Customer service, Supplier performance, demand/supply balance, Inventory health, warehouse/route productivity, overtime/absence, Quality trends, cash outlook, and unresolved actions.

The weekly comparison uses actual business dates and ordinary records. It does not depend on preserving a Simulation Session identifier.

## 14. Monthly and Annual Management Cycle

Monthly reporting integrates closed-period financial statements, AR/AP, Inventory valuation, cash, debt, capital, payroll, operational service, quality, and actual-versus-budget results. Material unfavorable variances require explanation, responsible owner, corrective action, due date, and follow-up.

Annual reporting supports budget/capital planning, performance review, Supplier/Customer strategy, insurance/regulatory review, capacity planning, and owner decisions.

## 15. Sales and Customer Reporting

Reports cover Orders/Sales/margin by Customer, location, segment, Product, category, Sales representative, route, price source, and time; minimum-order/small-order economics; split packs; contract usage; Customer activity/retention; credit Holds; service cases; returns; credits; and fulfillment reconciliation.

Sales reports distinguish ordered, released, shipped, accepted-delivered, invoiced, and posted revenue.

## 16. Purchasing and Supplier Reporting

Reports cover recommendations, Purchase Orders, open commitments, appointments, Receipts, fill rate, on-time performance, lead time, price/freight variance, inspection/rejection, disputes, credits, payment/discount status, alternate-source readiness, and Supplier scorecards.

## 17. Inventory and Warehouse Reporting

Reports cover quantity/status/location, allocation, Lot/date, FEFO, pick-slot placement, replenishment, aging, short-date/expired, damage/shrink, count variance, slow/nonmoving stock, cases/labor hour, wave/pick/load completion, congestion, and equipment/capacity exceptions.

Quantity and Finance FIFO value are reconciled but remain distinct measures.

## 18. Transportation and Delivery Reporting

Reports cover truck/driver readiness, maintenance/inspection due, route/load capacity, planned/actual miles/time/stops, departure, on-time delivery, delivered/refused/returned quantities, temperature/quality exceptions, fuel/route cost, Customer window performance, and spare-truck use.

## 19. Quality and Recall Reporting

Reports cover active Holds, failed inspections/temperatures, Supplier/Product restrictions, sanitation/pest/calibration, complaints, traceability completeness, Recall scope/notices/responses/effectiveness/product accounting, mock-recall performance, and CAPA aging.

Safety severity and missing evidence remain visible regardless of financial amount.

## 20. Workforce and Payroll Reporting

Reports cover active headcount/FTE, vacancies, assignments, staffing plan/schedule/actual capacity, absence, leave, overtime, temporary labor, qualification/training, time approval, Payroll controls, gross-to-net, payment exceptions, and Finance reconciliation.

Protected compensation, tax, benefit, medical, garnishment, and investigation details are restricted.

## 21. Finance Reporting

Finance supplies Trial Balance, Income Statement, Balance Sheet, Cash Flow Review/Statement, GL, AR/AP aging, Inventory valuation, bank reconciliation, cash forecast, debt/covenants, assets/depreciation, taxes, payroll liabilities, budget/forecast, and profitability.

Published Finance statements retain Finance approval and cannot be regenerated under a changed definition as though identical.

## 22. Cross-Domain Reconciliation

Required reconciliations include Order-to-allocation/pick/load/delivery/invoice; Receipt-to-Inventory/AP; Inventory quantity-to-FIFO value/GL; Delivery-to-revenue/AR; Customer Receipt-to-bank/AR; Supplier payment-to-bank/AP; Payroll Result-to-payment/liability/GL; Recall quantity accounting; and operational totals-to-management summaries.

Differences are assigned and explained. No report plug forces agreement.

## 23. Exceptions, Alerts, and Escalation

An alert derives from a governed threshold or event and identifies severity, business key, detected/due time, responsible role/Principal, current status, and escalation path.

Alerts consolidate duplicates and remain linked to source exceptions. Acknowledgment does not equal resolution. Safety, payroll, cash, regulatory, and Customer-service-critical conditions can use immediate out-of-band notification with later confirmation.

## 24. Management Actions

A Management Action links a KPI, report, variance, audit finding, reconciliation difference, or business exception to action, owner, due date, expected result, completion evidence, verifier, and status.

Extensions require reason and approval. Closure requires evidence and, for material actions, independent verification. Repeated actions are trendable by root cause.

## 25. Forecasts and Scenarios

Approved Budget remains the baseline. Forecasts preserve as-of assumptions and do not rewrite Budget or actual results. Operational what-if analysis is labeled and separated from business facts.

Simulation results are reported from the ordinary data in the active database copy. Comparisons use business dates and preserved source facts, not Simulation Session columns in Customer, Inventory, Finance, or other business tables.

## 26. Data Quality

Data-quality rules measure required-value completeness, valid references, timeliness, duplicate risk, effective-date coverage, unit/currency consistency, control-total reconciliation, and source-event consumption.

A failed rule identifies affected domain, records, severity, owner, due date, business/report impact, and resolution. Reports display material quality warnings and do not silently omit failed rows.

## 27. Drill-Through and Lineage

Every material summary result identifies Report Definition/version, Run, source cutoff, source domains, calculation, and source business keys sufficient for authorized drill-through.

Lineage preserves transformations and exclusions. JSON may describe a parameter or output contract, but relational business facts and keys remain normalized.

## 28. Audit Scope

Audit covers authentication/Principal context, protected-data access/export, master/effective-data change, approvals, Holds/releases, status transitions, postings, payments, Payroll, owner actions, security/role changes, data correction, report publication, configuration, system clock/control changes, and emergency/outage recovery.

Audit records support accountability but do not replace the authoritative business record.

## 29. Audit Event Content

Each Audit Event records permanent event number, environment, schema/entity, complete natural business key, action, actual/business time, recorded time, Principal/process, correlation, prior/new controlled values or status, reason, approval, source, confidentiality, and integrity evidence.

High-volume technical diagnostics remain separate from governed business audit.

## 30. Audit Immutability and Review

Audit Events are append-only. Corrections add clarifying events; they never alter the original. Privileged database/application actions remain attributable to a named Principal or controlled service identity.

Daily/weekly exception review covers failed jobs, rejected transactions, emergency authority, direct-access attempts, duplicate prevention, protected-data export, and unresolved integration events. Periodic access review verifies continued business need and segregation.

## 31. Security and Distribution

Every Report Definition has an audience and sensitivity. Distribution uses approved recipient roles, channels, and expiration/retention. Reports containing bank, payroll, tax, medical, Customer credit, Supplier banking, owner, or investigation data receive restricted handling.

Downloaded/exported formal data retains report/run/version/as-of markings where practical. Public or broad internal distribution requires specific approval.

## 32. Retention and Legal Hold

Retention follows the authoritative source record, report purpose, legal/regulatory/contractual requirement, and policy. A snapshot may have a different retention period than its reproducible Run metadata.

Legal hold suspends eligible disposition and identifies scope, authority, start/end, custodian, and completion evidence. Expired transient output is disposed through an audited process.

## 33. Business Continuity

Critical worklists and contact/report templates have controlled outage alternatives. After recovery, reports identify missing time windows, late-entered facts, duplicate risk, and reconciliation status.

Emergency reports are labeled preliminary until authoritative facts reconcile. A later final report supersedes rather than overwrites them.

## 34. Logical Business Structures

| Structure | Natural business key |
|---|---|
| Report Definition | report code + effective from |
| Report Run | `report_run_number` |
| Report Result | Report Run Number + result sequence |
| Formal Snapshot | Report Run Number + snapshot sequence |
| KPI Definition | KPI code + effective from |
| KPI Target | KPI code/version + scope + period |
| KPI Result | KPI code/version + period/as-of + governed dimension key |
| Alert | `alert_number` |
| Management Action | `management_action_number` |
| Reconciliation Definition | reconciliation code + effective from |
| Reconciliation Run | `reconciliation_run_number` |
| Data-Quality Rule | rule code + effective from |
| Data-Quality Result | rule code/version + run time + scope sequence |
| Audit Event | `audit_event_number` |
| Access Review | `access_review_number` |
| Legal Hold | `legal_hold_number` |

No surrogate or simulation-session key is permitted in ordinary reporting/audit records.

## 35. Controls and Approvals

- Domain owners approve definitions and material changes.
- Finance approves formal financial reports; Food Safety authority approves regulatory safety output.
- Report developers/operators cannot grant themselves protected access.
- Material formal publication requires an authorized reviewer distinct from preparer.
- Security-role changes and protected exports are audited.
- Management Action closure requires evidence and appropriate verification.
- Audit administrators cannot modify Audit Events.

## 36. Reports About Reports

The simulation monitors failed/late Runs, stale dashboards, missing sources, control-total failures, excessive runtimes, unused definitions, failed distribution, unacknowledged alerts, overdue actions, protected exports, and retention disposition.

## 37. Simulation

Reports query ordinary business data and its dates. The Simulation Controller may request a report or preserve an external run artifact, but ordinary Report/KPI/Audit primary keys and source facts do not depend on a Simulation Session.

Restoring a test baseline occurs outside business reporting. Audit in a restored copy reflects activity in that copy and is not merged into production history.

## 38. Decisions Established

- Reporting is read-only with respect to authoritative domain facts.
- Every definition/result is versioned, time-bounded, and reconciled.
- Daily, weekly, monthly, and annual management cycles are supported.
- The Owner scorecard spans commercial, service, supply, operations, quality, workforce, and finance results.
- Pending operational and posted financial measures are never silently mixed.
- Material exceptions become assigned, verified Management Actions.
- Formal snapshots and Audit Events are immutable.
- Natural business keys are mandatory; simulation-session keys are excluded from ordinary records.

## 39. Remaining Configuration

Opening Report/KPI definitions, targets, thresholds, materiality, schedules, recipients, formats, dashboard layout, data-quality rules, reconciliation tolerances, action escalation, retention, and legal-hold procedures are configuration.

## 40. Acceptance Criteria

The domain is acceptable when management can see current conditions and period results; every measure is defined and traceable; totals reconcile; missing data is visible; formal output is reproducible and immutable; sensitive distribution is controlled; actions close with evidence; and audit history cannot be altered.

## 41. Next Design Work

Next: **Management Reporting and Audit PostgreSQL Build Specification**.
