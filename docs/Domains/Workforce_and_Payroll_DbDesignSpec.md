# Workforce and Payroll PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0127`–`0155`  
**Depends on:** Cumulative design through `0126`; Workforce and Payroll Domain Specification

## 1. Purpose

Define the normalized PostgreSQL structures, natural keys, constraints, controlled operations, privileges, views, audit, and verification required to support the business Workforce and Payroll. This document specifies the future build package but contains no executable SQL.

## 2. Required Outcome

- Employee identity, employment, assignment, schedule, qualification, time, leave, compensation, and Payroll remain distinct normalized facts.
- Workforce availability and qualifications drive operational eligibility and capacity.
- Approved Payroll Runs reproduce every gross-to-net result from frozen, traceable inputs.
- Approved time and Payroll Results are immutable and corrected forward.
- Payroll approval, Finance payment release, and reconciliation remain separated.
- Cross-domain source events are idempotent and never create duplicate pay or accounting effects.
- Sensitive Employee, tax, benefit, medical, banking, and garnishment information is role-limited and audited.
- Natural business numbers and governed composites are the only primary keys.
- Simulation uses ordinary Workforce and Payroll tables without a simulation-session key.

## 3. Platform and Package

PostgreSQL 15 or later; existing `core`, `party`, `customer`, `product`, `purchasing`, `inventory`, `warehouse`, `sales`, `transportation`, `quality`, `workforce`, `payroll`, `finance`, `audit`, and `reporting` schemas; cumulative manifest `10.0.0`; immutable changes `0001`–`0126`; transactional changes `0127`–`0155` through the standard runner.

All changes use checksums, prerequisite checks, controlled ownership, safe `search_path`, explicit privileges, validation, comments, and rerun-safe assertions. Quality and any later owning package references use documented deferred constraints until activated.

## 4. Relational and Naming Standards

Use lowercase `snake_case`, singular table names, uppercase governed codes, `date` for business dates, `time` for local schedule times, and `timestamptz` for actual events. Monetary amounts use `numeric(19,4)`; hours and units use `numeric(12,4)`; percentages/rates use `numeric(12,8)`.

Mutable working rows include created/changed Principal, timestamps, and positive `row_version`. Effective-dated records use nonoverlapping ranges and preserve history. Approved time, Payroll snapshots, calculations, Results, approvals, corrections, statements, and audit events are append-only.

Business numbers/codes and governed composites are primary keys. Complete natural keys propagate through foreign keys. Identity, serial, UUID, generic hidden IDs, and nullable-key placeholders are prohibited.

## 5. Controlled Business Numbers

Change `0127` adds Core-controlled, permanent, nonreusable sequences where not already established:

| Sequence | Example |
|---|---|
| `EMPLOYEE` | `E00000001` |
| `POSITION` | `POS000001` |
| `WORKFORCE_PLAN` | `WFP0000001` |
| `HIRING_REQUISITION` | `REQ0000001` |
| `APPLICANT` | `APP0000001` |
| `EMPLOYMENT_OFFER` | `OFR0000001` |
| `WORK_SCHEDULE` | `SCH0000001` |
| `TIME_ENTRY` | `TME000000001` |
| `LEAVE_REQUEST` | `LVR0000001` |
| `PAYROLL_INSTRUCTION` | `PRI0000001` |
| `PAYROLL_RUN` | `PAY0000001` |
| `PAYROLL_ADJUSTMENT` | `PAD0000001` |
| `EMPLOYMENT_CASE` | `EMC0000001` |
| `WORK_INCIDENT` | `INC0000001` |
| `WORKFORCE_AUDIT_EVENT` | `WAE000000001` |

Parent-relative periods, versions, lines, assignments, tasks, decisions, corrections, components, and events use governed sequence values within the parent business transaction.

## 6. Reference Data

Opening governed reference groups include:

| Reference | Opening codes |
|---|---|
| Employment status | `PREHIRE`, `ACTIVE`, `LEAVE`, `SUSPENDED`, `SEPARATED`, `DECEASED` |
| Worker type | `EMPLOYEE`, `OWNER_EMPLOYEE`, `TEMP_AGENCY`, `CONTRACTOR`, `OTHER_EXTERNAL` |
| Employment type | `REGULAR`, `TEMPORARY`, `SEASONAL`, `INTERN` |
| Work-time status | `FULL_TIME`, `PART_TIME` |
| Pay basis | `HOURLY`, `SALARY` |
| Assignment type | `PRIMARY`, `SECONDARY`, `ACTING`, `TEMPORARY` |
| Time status | `ENTERED`, `SUBMITTED`, `APPROVED`, `REJECTED`, `CONSUMED`, `CORRECTED`, `VOIDED` |
| Leave status | `REQUESTED`, `APPROVED`, `DENIED`, `TAKEN`, `CANCELLED`, `ADJUSTED` |
| Payroll run type | `REGULAR`, `OFF_CYCLE`, `CORRECTION`, `FINAL_PAY`, `SPECIAL` |
| Payroll run status | `SCHEDULED`, `COLLECTING`, `CALCULATED`, `EXCEPTION_REVIEW`, `PENDING_APPROVAL`, `APPROVED`, `TRANSMITTED`, `PAID`, `RECONCILED`, `CLOSED`, `CANCELLED`, `SUPERSEDED` |
| Pay component class | `EARNING`, `EMPLOYEE_TAX`, `EMPLOYER_TAX`, `DEDUCTION`, `GARNISHMENT`, `EMPLOYER_BENEFIT`, `NET_PAY` |
| Qualification status | `PENDING`, `QUALIFIED`, `RESTRICTED`, `EXPIRED`, `SUSPENDED`, `REVOKED` |
| Separation type | `VOLUNTARY`, `INVOLUNTARY`, `RETIREMENT`, `DEATH`, `END_OF_ASSIGNMENT` |

Reference values use Core active/effective/audit conventions. Legal and policy rules are effective-dated data, never hardcoded labels.

## 7. Employee and Employment Period

`workforce.employee` uses `employee_number` as PK and stores unique Party Person Number, record-established date, restricted-data classification, and row version. Party holds legal identity/contact facts; Employee holds the permanent employment role. Current status and original hire date derive from Employment Period history rather than duplicated columns.

`workforce.employment_period` PK employee number + employment-period sequence stores hire/rehire date, expected/actual separation date, employment/worker/work-time classifications, home Department, primary Position, payroll eligibility, service-credit treatment, reason, and approval.

Checks allow only one active employment period per Employee. Rehire uses the existing Employee Number and a new period. Current Employee summary values are controlled derivatives of the effective period and cannot conflict with it.

`workforce.employee_owner_role` PK employee number + effective-from links an Employee to the applicable Finance Owner Number and effective-to. Owner status and ownership percentage remain authoritative in Finance.

## 8. Restricted Employee Profiles

`workforce.employee_tax_profile` PK employee number + effective-from stores residence/work jurisdictions, filing/election references, protected identifier tokens, verification status, and effective-to.

`payroll.employee_payment_election` PK employee number + election sequence stores payment method, allocation priority/amount/percent, protected external payment token, verification, effective period, and status. Raw bank credentials do not appear in ordinary Workforce tables.

`workforce.employee_emergency_contact` PK employee number + contact sequence stores relationship, priority, Party/contact reference or protected contact snapshot, permission, and effective status.

Sensitive columns use separate restricted tablespaces/storage policy where adopted, column-level privileges, masking views, and audited access.

## 9. Departments, Jobs, and Job Versions

`workforce.department` uses `department_code` as PK and stores name, responsible Principal/owner, Finance cost dimension, active/effective dates, and row version.

`workforce.job` uses `job_code` as PK and stores title, family, general duties, safety-sensitive/regulated indicators, default pay basis, and status.

`workforce.job_version` PK job code + effective-from stores description, minimum qualifications, physical/environmental requirements, standard-hours profile, overtime classification requirement, pay-grade reference, required training profile, approval, and effective-to. Date ranges cannot overlap.

## 10. Positions and Position Budgets

`workforce.position` uses `position_number` as PK and stores Department, Job, primary Work Location, supervisor Position, regular/temporary designation, budget status, standard schedule profile, and row version. Each Position represents one budgeted seat.

`workforce.position_budget` PK position number + fiscal year + budget version stores planned headcount/FTE, hours, compensation, benefits, effective dates, Finance Budget reference, approval, and status.

Supervisor relationships must be acyclic. A Position has no more than one active primary occupant; a brief approved transition overlap is recorded as an assignment exception rather than hidden headcount.

## 11. Employee Assignments

`workforce.employee_assignment` PK employee number + assignment sequence stores employment-period key, Position, assignment type, Department, supervisor Employee/Position, Work Location, start/end times, standard FTE/hours, labor dimensions, status, reason, and approval.

Only one primary assignment may be effective at a time. Secondary, acting, and temporary assignments require compatible schedules, pay treatment, security duties, and qualifications. Nonoverlap rules prevent ambiguous primary responsibility.

`workforce.assignment_eligibility_exception` PK assignment key + exception sequence records missing/expired qualification, work restriction, schedule conflict, segregation conflict, resolver, due time, and disposition.

## 12. Workforce Plans

`workforce.workforce_plan` uses `workforce_plan_number` as PK and stores Department/location, planning horizon, source demand version, scenario/baseline type, preparer, approver, status, and row version.

`workforce.workforce_plan_requirement` PK plan number + requirement sequence stores date/time window, Job/skill, activity or operating-domain context, required headcount/FTE/hours, productivity assumption, supervision ratio, and priority.

`workforce.workforce_plan_capacity` PK plan number + capacity sequence stores available Employee/skill group, regular/overtime/temp hours, absence/training assumptions, effective capacity, shortfall/surplus, and evidence.

Plans never change Employee, schedule, or operational demand facts. Approved shortfalls produce assigned exceptions.

## 13. Hiring Requisitions

`workforce.hiring_requisition` uses `requisition_number` as PK and stores Position/Job/Department, replacement/growth reason, requested headcount, employment/pay/schedule basis, requested start, budget reference, requester, HR reviewer, approvals, status, and row version.

`workforce.requisition_approval` PK requisition + decision sequence records authority level, decision, conditions, Principal, and time. A requisition cannot open recruiting until Position and budget controls pass or an approved exception exists.

## 14. Applicants and Applications

`workforce.applicant` uses `applicant_number` as PK and links a Party Person when established. It stores candidate status, preferred contact reference, consent status, source restrictions, duplicate-review result, and restricted retention state.

`workforce.employment_application` PK applicant number + application sequence stores Requisition, submission date, source, employment history/evidence references, requested accommodations routing, status, and row version.

`workforce.application_evaluation` PK application key + evaluation sequence records interview/assessment type, job-related criterion, evaluator, result, evidence, conflicts, recommendation, and decision time. Restricted demographic/accommodation facts are separated.

## 15. Offers and Preemployment Conditions

`workforce.employment_offer` uses `offer_number` as PK and stores Application/Requisition, Position, proposed assignment, compensation/pay basis, schedule, start date, contingencies, issued/expiration/acceptance times, approver, and status.

`workforce.offer_condition` PK offer number + condition sequence records condition type, required-by, responsible verifier, protected evidence reference, result, completion time, waiver authority, and status.

Accepted offers do not activate employment until required conditions pass. One accepted Offer may create only one employment period/onboarding case.

## 16. Onboarding Cases and Tasks

`workforce.onboarding_case` PK employee number + employment-period sequence stores Offer, planned/actual start, coordinator, overall status, and completion approval.

`workforce.onboarding_task` PK onboarding-case key + task sequence stores task type, responsible domain/role, due time, prerequisite, evidence, result, completion Principal/time, blocking scope, and status.

Tasks cover employment/tax/payment elections, policy acknowledgments, training, property, physical/system access requests, supervisor readiness, and payroll eligibility. Dependency cycles are rejected. Incomplete blocking tasks prevent only the affected eligibility.

## 17. Shift Templates and Work Schedules

`workforce.shift_template` PK shift code + effective-from stores local start/end, day boundary, break expectations, Department/Job/location, default paid hours, operating-cycle designation, premium policy, and effective-to.

`workforce.work_schedule` uses `schedule_number` as PK and stores Department/location, schedule period, version, draft/published/superseded status, prepared/approved/published times, and row version.

`workforce.scheduled_shift` PK schedule number + shift sequence stores Employee/Assignment, Shift version, actual start/end timestamps, labor context, qualification requirements, published state, and replacement/call-off link.

Schedule publication freezes that version. Revision creates a new version or append-only change record; it does not rewrite previously communicated shifts.

## 18. Availability, Call-Offs, and Coverage

`workforce.employee_availability` PK employee number + availability sequence stores recurring/exception type, date/time pattern, available/unavailable state, reason category, effective period, and approval where required.

`workforce.employee_call_off` PK employee number + call-off sequence stores Scheduled Shift, notice time/channel, expected duration, reason category, receiving supervisor, Leave Request, work-status effect, and status.

`workforce.shift_coverage_action` PK schedule/shift key + action sequence records qualified replacement, overtime/temp use, workload change, requested/approved Principals, eligibility evaluation, and outcome.

## 19. Time Entries and Segments

`workforce.time_entry` uses `time_entry_number` as PK and stores Employee/Assignment, work date, source, entry/actual times, Scheduled Shift, status, current approved version, Payroll Period/Run consumption, and row version.

`workforce.time_entry_segment` PK time entry + segment sequence stores start/end, segment type, paid/unpaid state, hours, Department, Work Location, approved labor dimensions, Route/warehouse/operating source reference, and earning treatment.

Segment ranges within an entry cannot overlap. Derived hours must equal the signed segment total. Schedule is not substituted for actual hourly work.

## 20. Time Approval and Correction

`workforce.time_approval` PK time entry number + approval sequence stores submitted version, approver, delegated authority, decision, exceptions, and time.

`workforce.time_correction` PK time entry number + correction sequence stores original/corrected segment facts, reason, requestor, supervisor/Payroll approvals, affected Payroll Run, effective status, and created time.

Consumed or approved time is never updated/deleted. A correction creates the next controlled version and, after payroll consumption, a Payroll Adjustment. Approvers cannot approve their own time.

## 21. Pay and Overtime Rules

`payroll.pay_rule` PK pay rule code + effective-from stores workweek, overtime/classification treatment, regular-rate inclusion, rounding, break, call-back, holiday, shift-differential, minimum-pay, and jurisdiction applicability.

`payroll.earning_code` uses `earning_code` as PK and stores component class, taxable/benefit/overtime treatment, unit basis, Finance mapping reference, active dates, and security classification.

`payroll.employee_pay_rule_assignment` PK employee number + assignment sequence + effective-from links the governed rule version. Rules cannot remove valid compensable time; policy violations remain separate Workforce cases.

## 22. Leave Plans, Accounts, and Requests

`workforce.leave_plan` PK leave plan code + effective-from stores eligibility, accrual/grant, carryover, cap, paid/unpaid, approval/evidence, payout, and effective-to rules.

`workforce.employee_leave_account` PK employee number + leave plan code + eligibility-period start stores opening, earned, used, adjusted, expired, pending, and available balances plus row version.

`workforce.leave_transaction` PK leave-account key + transaction sequence is append-only and records grant/accrual/use/reversal/expiration/payout/adjustment with source.

`workforce.leave_request` uses `leave_request_number` as PK; lines store date/hours, Schedule impact, protected detail reference, approval, and status. Balance, transaction, schedule, time, and Payroll consequences commit atomically where owned together.

## 23. Compensation Agreements

`payroll.compensation_agreement` PK employee number + agreement sequence stores Assignment, pay basis, rate/salary, currency, frequency, standard hours, pay grade, reason, effective period, budget/approval, and superseded agreement.

`payroll.compensation_component` PK compensation-agreement key + component sequence stores recurring earning, premium, allowance, commission-plan, or noncash component and calculation rule.

Effective agreements cannot overlap ambiguously for the same Assignment/pay purpose. Retroactive changes require explicit effective date, reason, approval, and Payroll Adjustment evaluation.

## 24. Payroll Calendar and Periods

`payroll.payroll_calendar` uses `payroll_calendar_code` as PK and stores name, biweekly frequency, timezone, owner, active status, and row version. Opening Employees and owner-employees use one company-wide calendar.

`payroll.payroll_period` PK calendar code + period number stores work-period start/end, time and manager cutoffs, processing date, payment date, correction cutoff, status, and year sequence.

Period ranges cannot overlap and dates must increase. Twenty-six regular pay dates are typical; the design accepts a governed twenty-seventh date without special schema.

## 25. Payroll Input Registry and Snapshot

`payroll.payroll_input_source` PK source domain + source document type + source document number + source line reference + source event sequence registers validated Time, Leave, Compensation, Benefit, Tax, Deduction, Commission, and Adjustment facts.

`payroll.payroll_input_snapshot` PK payroll run number + calculation version + input sequence stores source key/version, Employee, earning/work date, component, quantity/rate/amount, tax/benefit treatment, inclusion decision, captured time, and checksum.

The source registry prevents one source event from entering more than one intended Run/adjustment chain. Snapshot rows are immutable and never follow later mutable source values.

## 26. Payroll Runs and Calculation Versions

`payroll.payroll_run` uses `payroll_run_number` as PK and stores Calendar/Period, run type, correction/original Run, preparer, approver, status, current calculation version, totals/counts, funding-required time, and row version.

`payroll.payroll_calculation_version` PK Run + version number stores ruleset/version, input cutoff, started/completed time, engine/process, totals, exception count, checksum, superseded version, and status.

`payroll.payroll_run_approval` PK Run + decision sequence stores version, control totals, exception disposition, funding evidence, decision, Principal, and time. Only one approved calculation version may exist per active Run.

## 27. Earnings and Pay Calculations

`payroll.employee_earning_calculation` PK Run + calculation version + Employee + earning sequence stores Earning Code, Assignment, source input, work period, quantity, rate, regular-rate treatment, gross amount, Finance dimensions, and correction link.

`payroll.employee_regular_rate_calculation` PK Run + version + Employee + workweek start stores includable earnings/hours, calculated rate, overtime basis, rounding, and rule version.

Checks reconcile time-based earnings to approved time sources and salary/recurring earnings to effective Compensation Agreements. Manual earnings require an approved source instruction.

## 28. Tax, Deduction, and Garnishment Calculations

`payroll.payroll_instruction` uses `payroll_instruction_number` as PK and stores Employee, instruction type, authority/source, priority, calculation method, amount/rate/limit, protected evidence, effective period, and status.

`payroll.employee_tax_calculation` PK Run + version + Employee + jurisdiction + tax type stores taxable wages, wage base, rate/table version, Employee amount, employer amount, limits, and source elections.

`payroll.employee_deduction_calculation` PK Run + version + Employee + instruction number stores gross/eligible basis, requested/calculated/taken/arrears amounts, priority, statutory/plan limit, and result.

Garnishment details remain restricted. Calculations cannot exceed available pay or governed limits and retain unsatisfied balance/arrears when applicable.

## 29. Benefit Plans and Enrollment

`workforce.benefit_plan` PK benefit plan code + effective-from stores provider, plan/type, eligibility, waiting/coverage rules, Employee/employer contribution method, Payroll/tax treatment, and effective-to.

`workforce.benefit_option` PK benefit plan/version + option code stores coverage tier, contribution/rate schedule, and restrictions.

`workforce.benefit_enrollment` PK employee number + benefit plan code + coverage-period start stores option, election/qualifying event, coverage dates, Employee/employer amounts, Payroll instruction, provider enrollment status, and protected dependent/beneficiary evidence reference.

Enrollment and deductions must reconcile; provider invoice and remittance remain Finance/Supplier facts.

## 30. Employee Payroll Results and Components

`payroll.employee_payroll_result` PK Run + calculation version + employee number stores employment/assignment summary, gross pay, taxable wages, Employee taxes, deductions, garnishments, net pay, employer taxes/benefits, leave effects, status, and checksum.

`payroll.employee_payroll_result_component` PK Result key + component sequence stores component class/code, source calculation/input, amount, currency, jurisdiction/benefit/instruction reference, Finance mapping, and correction reference.

Checks require component totals to equal the Result control totals and net pay. Approved Results are immutable and one approved version per Run/Employee is exposed as current.

## 31. Pay Statements and Payment Instructions

`payroll.employee_pay_statement` PK Run + Employee + statement version stores approved Result version, issued time/channel, gross-to-net summary, leave display, prior correction reference, disclosure version, and superseded statement.

`payroll.payroll_payment_instruction` PK Run + Employee + payment sequence stores payment election, method, destination token, amount, currency, requested date, Finance status, returned/reissue reference, and confidentiality class.

Payment instructions for a Result must equal net pay. Finance owns payment release and Bank Transactions. A payment return or reissue links to the original and cannot create a second valid settlement.

## 32. Payroll Adjustments and Off-Cycle Runs

`payroll.payroll_adjustment` uses `payroll_adjustment_number` as PK and stores Employee, original Run/Result/component, source correction, earning/work date, amount/quantity/rate effect, reason, requested/approved Principals, target Run, and status.

`payroll.payroll_adjustment_component` PK adjustment + component sequence records earning, tax, deduction, benefit, leave, employer-cost, and net-pay consequences.

Post-payroll time changes, retroactive compensation, void/reissue, overpayment, underpayment, and final-pay corrections follow explicit approved chains. An adjustment never edits the original Result.

## 33. Owner-Employee Controls

`payroll.owner_compensation_approval` PK employee number + compensation-agreement/one-time-source key + decision sequence records Owner Number, decision, conditions, and time.

Constraints require the Employee to link to an active Owner and require at least three distinct active Owner approvals before owner compensation or a material change becomes effective. The affected owner cannot authorize the action unilaterally.

Finance Owner Capital Transactions and distributions cannot be used as Payroll inputs. Views report compensation and distribution references separately.

## 34. Training Requirements and Qualifications

`workforce.training_requirement` PK requirement code + effective-from stores owning domain, Job/Position/task/equipment/location applicability, course/evidence, proficiency, renewal/expiration, blocking scope, and effective-to.

`workforce.employee_training` PK employee number + requirement code + training sequence stores provider/course, completion, result, score/proficiency, evidence, verifier, and status.

`workforce.employee_qualification` PK employee number + requirement code + qualification sequence stores derived qualification period, restriction, evidence source, verifier, status, suspension/revocation, and row version.

Qualification updates are serialized by Employee/requirement and published to affected domains. General Workforce qualification does not replace Transportation's driver regulatory evidence.

## 35. Driver and Operational Eligibility Boundary

`workforce.employee_operational_eligibility` PK employee number + operating-domain code + eligibility purpose + as-of time stores active employment, assignment, schedule, leave/restriction, Workforce qualification, external-domain evidence version, decision, reasons, and expiration.

Transportation remains authoritative for driver license, endorsement, medical/safety qualification, equipment qualification, route restrictions, duty evidence, and hours restrictions. The eligibility record is a decision snapshot, not a copied credential master.

Route/warehouse events may create `workforce.time_source_exception` rows keyed by source-event key + exception sequence when operational time conflicts with submitted time. Resolution creates or corrects time only through the controlled time process.

## 36. Incidents, Work Restrictions, and Return to Work

`workforce.work_incident` uses `incident_number` as PK and stores event time, Employee/external worker, location, activity/equipment/operating source, immediate action, reportability review, investigator, status, and protected-detail reference.

`workforce.incident_action` PK incident + action sequence records notification, investigation, corrective action, training, due/completion time, owner, evidence, and verification.

`workforce.employee_work_restriction` PK employee number + restriction sequence stores allowed/prohibited work categories, start/expected end, clearance authority, protected medical evidence reference, reviewer, and status. Managers see only operationally necessary restriction facts.

`workforce.return_to_work_decision` PK restriction key + decision sequence records evidence verification, permitted duties, effective time, approver, and follow-up.

## 37. Performance and Employment Cases

`workforce.performance_review` PK employee number + review period end + review version stores Assignment, expectations, metrics/evidence, contextual factors, ratings, development actions, reviewer, Employee acknowledgment, and status.

`workforce.employment_case` uses `employment_case_number` as PK and stores Employee, case type, policy/expectation, opened date, owner, confidentiality, status, and resolution.

`workforce.employment_case_activity` PK case + activity sequence stores coaching, warning, commendation, investigation, Employee response, improvement plan, follow-up, evidence, decision, and time. Restricted cases use separate access roles.

## 38. Employment Changes and Separation

`workforce.employment_change` PK employee number + change sequence stores effective date, change type, prior/new employment/assignment/compensation/schedule references, reason, approvals, and status.

`workforce.separation` PK employee number + employment-period sequence stores separation type/reason category, notice/last-work/effective dates, final-pay and leave treatment, rehire eligibility, authorization, and protected-detail reference.

`workforce.offboarding_task` PK separation key + task sequence stores responsible domain/role, due time, property/access/benefit/payroll/notification action, evidence, completion, and status. Dependency rules and overdue alerts apply.

Future eligibility closes at the effective time without deleting historical Assignment, security, time, Payroll, or operational records.

## 39. External Workers and Property

`workforce.external_worker` PK worker organization Party Number + external worker number stores Person Party, worker type, sponsoring Supplier/agency, engagement period, supervisor, authorized scope, qualification/access status, and confidentiality class.

`workforce.external_worker_time` PK external-worker key + time-entry sequence stores work period, source, hours, authorization, and Supplier Invoice matching reference; it never enters Employee Payroll.

`workforce.property_assignment` PK worker type + worker business key + assignment sequence stores asset/property reference, issue/return times, condition, acknowledgment, custodian, disposition, and exception status.

## 40. Finance and Accounting Interfaces

`payroll.finance_posting_request` PK Payroll Run + approved calculation version + posting sequence stores accounting date, summarized/detail treatment, Finance dimensions, wages, taxes, deductions, benefits, liabilities, net pay, source checksum, and status.

`payroll.finance_payment_status` PK Payroll Run + Employee + payment sequence + Finance event sequence stores payment release, Bank Transaction, return/void/reissue, amount, event time, and Finance source reference.

`payroll.payroll_liability_reconciliation` PK Payroll Run + liability type + reconciliation sequence stores Payroll calculated amount, Finance liability/payment/remittance amounts, difference, owner, status, and resolution.

Finance is authoritative for Journals, Bank Transactions, liabilities, tax/benefit remittance, and reconciliation completion. Exactly-once source keys prevent duplicate Finance consequences.

## 41. Controlled Functions

Required transaction-safe functions include:

- `create_or_change_employee_and_employment_period(...)`
- `create_or_revise_department_job_or_position(...)`
- `assign_or_transfer_employee(...)`
- `create_and_approve_workforce_plan(...)`
- `open_and_approve_hiring_requisition(...)`
- `record_application_evaluation_and_decision(...)`
- `issue_accept_or_withdraw_offer(...)`
- `start_or_complete_onboarding(...)`
- `publish_or_revise_work_schedule(...)`
- `record_call_off_and_coverage(...)`
- `record_submit_or_approve_time(...)`
- `correct_time_entry(...)`
- `request_approve_or_post_leave(...)`
- `create_or_change_compensation(...)`
- `create_payroll_calendar_and_period(...)`
- `open_and_snapshot_payroll_run(...)`
- `calculate_or_recalculate_payroll(...)`
- `approve_or_cancel_payroll_run(...)`
- `create_pay_statement_and_payment_instruction(...)`
- `create_or_apply_payroll_adjustment(...)`
- `record_training_or_qualification(...)`
- `evaluate_operational_eligibility(...)`
- `record_incident_restriction_or_return_to_work(...)`
- `record_performance_or_employment_case(...)`
- `separate_employee_and_create_offboarding(...)`
- `record_external_worker_or_property_assignment(...)`
- `send_payroll_to_finance_or_record_finance_status(...)`

Functions validate Principal/authority, effective dates, row versions, source idempotency, qualification, self-approval, deterministic lock order, and cross-domain constraints. `PUBLIC` execution is denied.

## 42. Integrity, Concurrency, and Reconciliation

- Natural keys and required full-key foreign keys are enforced.
- Effective employment, primary Assignment, Job version, Compensation, Pay Rule, Leave Plan, and Benefit Plan ranges cannot overlap ambiguously.
- Supervisor and task-dependency graphs are acyclic.
- An Employee cannot approve the Employee's own time/pay action.
- Schedule entries cannot bypass active employment, Assignment, qualification, leave, or restriction checks.
- Time segments cannot overlap and approved totals reconcile.
- Each Payroll source event enters one intended Result/adjustment chain.
- One approved calculation version exists per active Run.
- Result components reconcile gross, taxes, deductions, net pay, and employer cost.
- Payment instructions equal net pay and reconcile to Finance payment status.
- Payroll and Finance liabilities/Journals reconcile without forced plugs.
- Owner compensation requires the governed Owner approval count.

Potentially conflicting rows lock in stable Employee, Period, Run, source-key, and payment order. Deferred constraints cover atomic multirow totals and cross-package references.

## 43. Events and Cross-Domain Integration

`workforce.domain_event` PK source document type + source document number + event code + event sequence stores actual/business time, recorded time, Employee/worker key, source version, correlation, publication status, and checksum.

Opening event types include Employee Hired, Employment Changed, Schedule Published, Employee Absent, Qualification Changed, Work Restriction Changed, Time Approved, Payroll Approved, Payroll Corrected, Payroll Payment Changed, and Employee Separated.

`workforce.event_consumer_receipt` PK domain-event key + consumer code records processing status, attempt, consequence reference, and checksum. Retries are idempotent. Failed publication/consumption remains assigned and visible.

## 44. Security, Audit, and Retention

Opening database roles separate HR administration, recruiting, manager scheduling/time approval, Payroll preparation, Payroll approval, benefit administration, sensitive case access, reporting, Finance integration, audit, and read-only operations.

`audit.workforce_audit_event` uses `workforce_audit_event_number` as PK and stores schema/entity, complete natural key, action, actual/business/recorded times, Principal/process, prior/new controlled value or status, source, reason, approval, correlation, and confidentiality class.

Row-level and column privileges restrict Employees to permitted self-service facts, managers to authorized reporting lines, and Payroll/HR specialists to assigned duties. Protected identifiers, payment tokens, medical/accommodation, garnishment, benefits-dependent, background, and investigation facts are masked outside named roles.

Retention policies are effective-dated by record class and jurisdiction. Authorized disposition is audited and cannot remove records still required for Payroll, Finance, investigation, legal hold, or business history.

## 45. Indexes, Views, and Reporting Contracts

Indexes support current active Employee/Assignment; Department/Position staffing; schedule by date/shift/Employee; qualification and restriction expiry; unapproved/exception time; leave balance/request; Payroll Run/Period/status; Result by Employee/year; payment exceptions; onboarding/offboarding tasks; and restricted-case assignment.

Partial indexes cover active/pending/exception states. GiST exclusion constraints support effective-range rules. Indexes protect foreign-key operations and common reconciliation joins without duplicating source truth.

Governed views include active workforce roster, current assignment/supervisor, staffing coverage, schedule, qualification readiness, expiring requirements, time approval exceptions, leave availability, Payroll Run control, current approved Results, payroll-to-Finance reconciliation, onboarding/offboarding exceptions, and restricted management summaries.

Reporting views expose business keys and as-of/effective dates. They do not expose raw protected identifiers or become editable alternate masters.

## 46. Business Continuity and Simulation

Offline Workforce/Payroll activity uses reserved business numbers, controlled forms, documented authority, actual occurrence time, and later entry time. Recovery checks source numbers, periods, Employees, totals, approvals, payment/Journals, and prior consequences before posting.

Simulation inserts and updates ordinary Workforce and Payroll tables. Business time may come from the Core simulation clock, but no ordinary primary/foreign key includes Simulation Session. A simulated day/week remains standard business history in that database copy; scenario restoration occurs outside these schemas.

## 47. Change Order

| Change | Content |
|---|---|
| `0127` | Add Workforce/Payroll business-number sequences and reference data |
| `0128` | Create Employee, Employment Period, restricted profiles, and payment elections |
| `0129` | Create Departments, Jobs/versions, Positions, and Position Budgets |
| `0130` | Create Employee Assignments and assignment-eligibility exceptions |
| `0131` | Create Workforce Plans, requirements, capacity, and shortfall controls |
| `0132` | Create Hiring Requisitions and approvals |
| `0133` | Create Applicants, Applications, evaluations, and privacy separation |
| `0134` | Create Employment Offers and preemployment conditions |
| `0135` | Create Onboarding Cases, tasks, dependencies, and eligibility controls |
| `0136` | Create Shift Templates, Work Schedules, Scheduled Shifts, and revisions |
| `0137` | Create availability, call-offs, and coverage actions |
| `0138` | Create Time Entries and Segments |
| `0139` | Create time approvals, corrections, consumption, and exceptions |
| `0140` | Create Pay Rules, Earning Codes, and Employee rule assignments |
| `0141` | Create Leave Plans, Accounts, Transactions, and Requests |
| `0142` | Create Compensation Agreements and Components |
| `0143` | Create Payroll Calendar and Periods |
| `0144` | Create Payroll input source registry and immutable snapshots |
| `0145` | Create Payroll Runs, calculation versions, approvals, and exceptions |
| `0146` | Create earnings and regular-rate calculations |
| `0147` | Create tax, deduction, and garnishment instructions/calculations |
| `0148` | Create Benefit Plans/options and Employee Enrollments |
| `0149` | Create Employee Payroll Results and Components |
| `0150` | Create Pay Statements, payment instructions, and Finance payment status |
| `0151` | Create Payroll Adjustments, off-cycle controls, and Owner approvals |
| `0152` | Create training, qualifications, operational eligibility, and time-source exceptions |
| `0153` | Create incidents, restrictions, performance, cases, changes, and separation |
| `0154` | Create external-worker/property records, Finance posting/reconciliation, functions, and events |
| `0155` | Apply privileges, audit, retention, indexes, views, deferred constraints, comments, and final assertions |

## 48. Verification and Tests

Verification proves contiguous history/checksums through `0155`; required schemas/objects/codes; exact natural keys; normalized relations; full-key foreign keys; validated/deferred constraints; no surrogate or simulation-session keys; restricted privileges; function ownership; comments; and expected views/indexes.

Disposable tests cover Employee hire/rehire; overlapping employment rejection; Job/Position hierarchy; assignment and supervisor cycles; Workforce plan shortfall; Requisition/Offer/Onboarding; schedule revision; call-off/coverage; missing qualification; hourly time/segments; own-time approval denial; correction before/after Payroll; leave accrual/use; prospective/retroactive Compensation; 26/27-period calendar; duplicate input retry; Payroll calculation/recalculation/approval; gross-to-net; overtime/pay rule; taxes/deductions/garnishment limits; benefits; Result immutability; pay statement; payment return/reissue; off-cycle correction; configured independent owner-compensation approval; driver boundary; incident/restriction; separation/offboarding; external-worker exclusion from Payroll; Finance reconciliation; concurrency; outage recovery; and ordinary-table simulation.

## 49. Acceptance Criteria

The eventual package must build cleanly and incrementally through `0155`, rerun as a no-op, and pass checksum, behavioral, concurrency, privacy, reconciliation, and privilege tests. It must demonstrate controlled workforce eligibility, reproducible biweekly Payroll, immutable approved history, correction chains, exactly-once Finance handoff, and natural-key integrity.

## 50. Deferred Configuration

Opening Employee roster, Department/Position counts, Job descriptions, wages/salaries, overtime/premium and workweek rules, leave/holiday plans, Benefit plans/contributions, commission plans, tax jurisdictions/rates, deduction priorities, training catalog, qualification periods, schedule templates, approval thresholds, Payroll provider, payment methods, retention periods, and report layouts are configuration—not unresolved architecture.

## 51. Next Design Work

Next: **Quality, Food Safety, and Recall Domain Specification**. Executable Workforce and Payroll SQL remains deferred until we leave Design Land.
