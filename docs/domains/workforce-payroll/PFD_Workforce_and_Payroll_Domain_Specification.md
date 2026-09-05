# \<business name>
# Workforce and Payroll Domain Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Business and logical domain design; executable SQL not included  
**Depends on:** PFD design through the Finance and Accounting PostgreSQL Build Specification

## 1. Purpose

Define how PFD plans, hires, assigns, schedules, qualifies, pays, develops, and separates its workforce. The domain must connect employee availability and competence to operating capacity while producing complete, approved payroll results for Finance without duplicating identity, operational, banking, or accounting facts.

## 2. Required Outcomes

- PFD knows who may work, in what role, at which location, on which shift, and under which qualifications.
- Staffing plans reflect expected workload, absences, training, and legally permissible availability.
- Every compensable hour and approved pay component enters payroll once.
- Payroll is reproducible from approved inputs and is corrected through controlled forward transactions.
- Employee, compensation, tax, benefit, and banking information is restricted by business need.
- Payroll preparation, approval, payment release, and reconciliation are separated.
- Workforce events reach affected operating domains without duplicate entry.
- Natural business numbers and governed composites identify all records; surrogate keys are prohibited.
- Simulation uses the ordinary Workforce and Payroll records.

## 3. Business Context

PFD opens with approximately **45–50 employees, including any owners who also hold Employee roles**, supporting approximately 80 Customer locations, 3,000 Products, a 50,000-square-foot facility, and six owned delivery trucks.

The opening organization includes owner-management, Sales, Customer Service, Purchasing and inventory planning, Warehouse supervision and labor, Transportation and drivers, Finance and administration, Human Resources, sanitation/facility support, and information-technology support. The exact roster and wage levels are opening-data configuration.

Office activity normally operates Monday through Friday, 8:00 AM–5:00 PM. Warehouse activity begins Sunday afternoon, continues through the weekday order-and-delivery cycle, and ends Friday afternoon. Saturday is normally closed. Actual assignments may span evening, overnight, early-morning, and weekday delivery work.

## 4. Scope

This domain owns:

- Employee identity within the employment relationship
- Organization, positions, jobs, assignments, supervisors, and work locations
- Workforce plans, schedules, shifts, availability, attendance, and time
- Recruiting, hiring, onboarding, employment changes, and separation
- Compensation, leave, benefits enrollment, deductions, and garnishment instructions
- Training and general employee qualifications
- Payroll calendars, runs, calculations, results, corrections, and payroll audit
- Performance, discipline, safety-related work restrictions, and return-to-work status
- Workforce reporting and labor-capacity signals

It does not own Customer, Supplier, Product, Route, Delivery, physical Inventory, Bank Account, Journal, or tax-payment facts.

## 5. Ownership and Domain Boundaries

| Fact or activity | Authoritative owner |
|---|---|
| Person/legal identity and contact methods | Party/Core |
| Employment status, job, assignment, compensation, leave, training | Workforce |
| Approved payroll calculation and Employee result | Payroll |
| Operational work performed | Owning operating domain |
| Warehouse productivity and task evidence | Warehouse |
| Route, dispatch, driving time, delivery, and driver regulatory evidence | Transportation |
| Food-safety standards and operating incidents | Quality/Safety owner |
| Payroll cash release, liabilities, remittance, Journal, reconciliation | Finance |
| System access and technical identity | Security/Core |

Operational evidence may support time and pay but cannot silently modify payroll. Workforce and Payroll preserve the reviewed interpretation and source reference.

## 6. Governance and Responsibility

The effectively assigned Finance and Administration authority has executive responsibility for Human Resources and payroll administration. Department leaders own staffing needs, schedules, work approval, and performance within policy. The assigned General Manager resolves routine cross-department operating conflicts.

Owner compensation and material compensation-policy changes require the independent approvals configured by effective governance policy. The affected owner is identified and cannot approve the action unilaterally. Routine hiring, pay changes, bonuses, and overtime operate within approved budgets and delegated authority. No manager approves the manager's own pay, time, bonus, or expense-sensitive payroll adjustment.

## 7. Person, Employee, and Employment Relationship

A Person may exist before, during, or after employment. An Employee is a permanent business role linked to one Person and identified by a nonreused Employee Number. Rehire normally reactivates the same Employee Number while creating a new employment period.

Employment periods retain hire, rehire, service, termination, and eligibility dates. Legal name changes update effective identity attributes without changing the Employee Number. Former employees remain queryable under restricted access.

## 8. Employment Status and Classification

PFD distinguishes employment status from payroll and schedule status. Employment states include candidate, offered, prehire, active, leave, suspended, separated, and deceased. Payroll eligibility and operational eligibility are separately derived.

Each active employment period identifies:

- Employee or owner-employee relationship
- Regular, temporary, seasonal, or intern status
- Full-time or part-time designation
- Hourly or salaried pay basis
- Applicable overtime classification
- Home Department, primary Position, Work Location, and supervisor
- Effective dates and reason for each change

Classification decisions require documented Human Resources review and are not inferred solely from job title or salary basis.

## 9. Organization, Jobs, Positions, and Assignments

A Department expresses managerial responsibility. A Job defines a reusable kind of work, duties, minimum qualifications, pay structure, and safety sensitivity. A Position is a budgeted seat within a Department and Work Location. An Assignment places an Employee into a Position for an effective period.

An Employee may have one primary assignment and approved secondary assignments. Concurrent assignments cannot create conflicting supervisors, pay rules, schedules, or segregation-of-duties authority. Acting and temporary assignments retain start/end dates and approval.

## 10. Workforce Planning and Staffing

Department workforce plans translate demand into required headcount, skill coverage, labor hours, and shift coverage. Plans consider:

- Sales/order volume and service commitments
- Receiving appointments and expected inbound volume
- Released cases, split-pack work, replenishment, loading, and sanitation
- Route count, stops, mileage, and delivery windows
- Office workload, close/payroll dates, and customer/supplier activity
- Leave, absence, training, turnover, vacancies, and expected productivity
- Equipment availability and required supervision

Plans distinguish budgeted capacity from scheduled capacity and actual available capacity. A shortfall becomes an assigned operating exception rather than an assumed productivity increase.

## 11. Requisitions and Recruiting

A hiring requisition identifies Department, Position/Job, employment type, schedule, reason, requested start date, budget authority, replacement or growth basis, recruiter, and approval status.

Approved recruiting preserves sources, applicants, referrals, interviews, evaluations, and decisions. Equal consideration and consistent job-related criteria are required. Sensitive demographic or accommodation information is separated from routine selection records.

## 12. Selection, Offers, and Preemployment Conditions

Selection records preserve interviewers, criteria, evidence, conflicts, decision, and approval. An offer identifies Position, compensation, pay basis, schedule, start date, contingencies, expiration, and authorized approver.

Preemployment conditions are position-specific and may include identity/work authorization, reference or background checks, driving record, license, medical certification, drug/alcohol program requirements, or other lawful qualification evidence. PFD records completion and result sufficient for the employment decision while limiting access to underlying sensitive evidence.

No candidate becomes active or receives system/physical access until required conditions and approvals are complete.

## 13. Hiring and Onboarding

Hiring creates the Employee Number, employment period, assignment, compensation, payroll/tax setup, schedule eligibility, required training plan, equipment/property assignments, and access requests as one controlled onboarding case.

Onboarding includes policy acknowledgments, tax and payment elections, emergency contact, food-safety and workplace-safety training, confidentiality/security obligations, role procedures, and supervisor confirmation. Missing required items remain visible and may block affected work without necessarily blocking all employment.

## 14. Work Locations and Labor Assignments

The opening Work Location is \<business address>. Customer sites, routes, vehicles, and temporary work points may be referenced as work context without becoming Workforce-owned locations.

Labor may be charged to Department, shift, Route, warehouse function, special project, or another approved cost dimension. The operational domain remains authoritative for the work transaction; Workforce/Payroll owns the approved labor interpretation.

## 15. Schedules and Shifts

Shift templates define normal start/end times, workdays, meal/rest expectations, Department, role/skill requirements, and capacity assumptions. Published schedules assign Employees to shifts and retain revisions.

Scheduling must respect availability, approved leave, required rest/hours limitations, active qualifications, work restrictions, and assignment compatibility. Sunday warehouse work belongs to the following operating delivery cycle but remains on its actual calendar date for time and payroll.

Schedule publication is not proof of attendance or compensable time.

## 16. Availability, Call-Off, and Coverage

Employees maintain recurring availability and effective exceptions. A call-off records notice time, affected shift, expected duration, reason category, contact channel, receiving supervisor, leave relationship, and coverage action.

Managers may use qualified cross-trained employees, approved overtime, temporary labor, schedule changes, or workload reprioritization. Coverage decisions never override qualification, safety, or hours restrictions.

## 17. Attendance and Time Capture

PFD records actual attendance for operational capacity and compensable time for payroll. Hourly employees record start, stop, meal, and approved paid/nonpaid time through controlled time entries. Salaried employees record attendance exceptions, leave, and other time needed for capacity, compliance, costing, or policy.

Time may originate from an employee clock, supervisor entry, approved mobile process, or operational evidence. Each entry retains actual work date/time, entered date/time, source, location/context, Employee, and correction history.

PFD pays all compensable work required by applicable law and policy. Failure to obtain advance approval is handled as a performance matter, not by deleting or refusing valid worked time.

## 18. Time Review and Correction

Employees or supervisors review time before payroll cutoff. Supervisors approve time for Employees under their responsibility; delegated approval is explicit and time-limited.

A correction never erases an approved or payroll-consumed entry. It records the original, corrected value, reason, requestor, approver, and affected Payroll Run. Pre-payroll corrections enter the pending period; post-payroll corrections flow through an adjustment or later Run.

## 19. Overtime and Premium Pay

Overtime is planned and approved when practical. Safety or completion of an active delivery cycle permits documented emergency overtime subject to prompt supervisory review.

Eligibility, workweek, regular-rate components, premium rules, shift differentials, call-back, holiday, and other pay treatments are effective-dated policy. Payroll calculates required pay from approved time and applicable rules; it does not treat scheduled hours as worked hours.

## 20. Leave and Absence

Leave plans define eligibility, accrual or grant method, service rules, carryover, limits, paid/unpaid treatment, approval, evidence, and effective dates. Leave requests identify type, dates/hours, reason category, status, approver, and schedule impact.

Protected or medically sensitive leave details are restricted. Operating domains receive only the availability and work-restriction information required to plan safely. Balances reconcile to grants/accruals, usage, adjustments, expirations, and payouts.

## 21. Compensation

Each compensation agreement identifies Employee/assignment, pay basis, rate or salary, frequency, currency, effective period, standard hours where applicable, approved premiums, reason, budget authority, and approval.

Pay changes are prospective unless a documented correction or authorized retroactive action applies. Payroll uses the effective agreement applicable to each earning date. Historical rates are never overwritten.

Bonuses, commissions, incentives, retroactive pay, reimbursements, and noncash compensation are distinct pay components with explicit source and approval. Sales commissions, if adopted, use finalized eligible Sales facts and documented plans; they do not change recognized revenue.

## 22. Payroll Calendar

PFD uses one company-wide **biweekly payroll calendar** for hourly employees, salaried employees, and owners on payroll. Each Payroll Period spans two defined workweeks and has a published time cutoff, manager approval cutoff, Payroll processing date, payment date, and correction cutoff.

Twenty-six regular Runs are expected in a normal year; a calendar year may occasionally contain a twenty-seventh pay date. Off-cycle Runs are limited to corrections, final pay, special payments, or other approved exceptions.

## 23. Payroll Inputs and Cutoff

Payroll inputs include approved time, leave, compensation, earnings, deductions, benefits, garnishments, tax elections, prior corrections, and authorized one-time items. Each input has one authoritative source and an effective date.

At cutoff, Payroll creates a controlled snapshot of included inputs. Late or changed source facts do not silently alter the Run; they create a visible exception, approved reopening, or later adjustment.

## 24. Payroll Run Lifecycle

A Payroll Run progresses through scheduled, collecting, calculated, exception review, pending approval, approved, transmitted, paid, reconciled, and closed states. Cancelled and superseded states preserve history.

Each Run is uniquely identified, tied to one Payroll Period and Run type, and may contain one current calculation version at a time. Recalculation creates a new version and retains comparison to the prior version.

Approval confirms completeness, reasonableness, authorization, funding readiness, and exception resolution. Approval does not itself release cash.

## 25. Gross-to-Net Calculation

For each Employee, Payroll determines:

1. Earnings by type, assignment, and work period
2. Overtime, differentials, bonuses, commissions, and adjustments
3. Pretax deductions and taxable benefit effects
4. Taxable wages by jurisdiction and tax type
5. Employee taxes and lawful deductions/garnishments
6. Employer taxes and benefit costs
7. Net pay and payment allocation
8. Liabilities and Finance posting classifications

Rules, rates, elections, wage bases, limits, and rounding retain effective dates and source/version. Calculation details must reproduce every result without relying on mutable current values.

## 26. Employee Payroll Result

An approved Employee Payroll Result preserves Run/version, Employee, gross earnings, taxable wages, each deduction/tax, net pay, employer costs, leave effects, payment instruction reference, and accounting classifications.

Approved Results are immutable. A correction uses reversal/replacement or a separately identified adjustment in an authorized Run. Year-to-date values derive from Results and corrections; they are not independently editable balances.

Each paid Result produces a confidential pay statement showing the pay period, earnings, taxes, deductions, employer-reported items, net pay, leave information required by policy, and correction references. Required periodic and year-end wage/tax statements reconcile to approved Results and Finance remittances.

## 27. Payment and Finance Boundary

Payroll provides approved Employee Results and payment instructions. Finance authorizes funding, releases payment, records Bank Transactions, establishes payroll/tax/benefit liabilities, posts Journals, and reconciles cash and liabilities.

Payment status returns to Payroll for pay-statement and exception handling. A rejected deposit, void, reissue, or returned payment remains linked to the original Result and Finance transaction. Payroll approval, payment release, and Bank reconciliation are performed by distinct authorized Principals whenever staffing reasonably permits.

## 28. Taxes, Deductions, and Garnishments

Employee tax elections, work/residence jurisdictions, deductions, and garnishments are effective-dated instructions with protected evidence. Payroll calculates Employee and employer amounts; Finance owns filing/payment obligations and remittance status.

Voluntary deductions require Employee authorization or documented plan enrollment. Involuntary deductions require valid legal authority, priority, limits, protected handling, and termination conditions. Payroll never exposes sensitive details in general manager reports.

## 29. Benefits

Benefit plans and options define eligibility, coverage period, waiting rules, Employee/employer cost, deduction treatment, carrier/provider, enrollment window, and termination rules. Enrollment records Employee elections, dependents/beneficiaries where applicable, qualifying event, evidence, and effective dates.

PFD reconciles enrollment, Payroll deductions, employer contributions, carrier invoices, and Finance remittance. The opening plan catalog and contribution amounts are configuration, not unresolved architecture.

## 30. Owner-Employees and Related-Party Pay

Any Owner may receive reasonable compensation for an actual operational Employee role through Payroll. Ownership percentage does not determine wages, benefits, or payroll treatment.

Owner compensation and material changes require the approvals configured by effective governance policy, excluding self-approval from satisfying independent-review expectations. Owner distributions, contributions, and loans are Finance/equity transactions and never Payroll expense.

## 31. Training and General Qualifications

Training requirements attach to Jobs, Positions, tasks, equipment, locations, and policies. An Employee Qualification records requirement, course/evidence, provider, completion, proficiency/result, effective date, expiration, restrictions, and verifier.

Expired, suspended, or missing mandatory qualification blocks the affected assignment or task. Supervisors see eligibility and expiration alerts but not unrelated confidential evidence. Cross-training is deliberately maintained for critical roles and backup coverage.

## 32. Driver and Transportation Boundary

Workforce owns Driver employment, general assignment, compensation, schedule, leave, training plan, and Payroll time interpretation. Transportation owns driving license/status/expiration, endorsements, medical and safety qualifications, equipment qualification, territory restrictions, route assignment, driving-duty evidence, and applicable hours restrictions.

Transportation sends eligibility and actual route-duty evidence to Workforce/Payroll. Route time may identify missing or inconsistent time entries but cannot silently create, delete, or alter payable time. A Driver must be both an active Employee and Transportation-eligible before dispatch.

## 33. Food Safety, Workplace Safety, and Work Restrictions

PFD requires role-appropriate sanitation, hygiene, temperature-control, chemical-handling, equipment, lifting, vehicle, emergency, and food-safety training. Quality/Safety processes own operational incidents and corrective actions; Workforce owns employment consequences, training completion, and work restrictions.

An incident records prompt response, medical/emergency action, people involved, witnesses, location, equipment/product context, notifications, investigation, corrective action, and return-to-work status. Medical details are restricted from routine operating records.

No schedule or staffing pressure overrides a safety hold, work restriction, or qualification block.

## 34. Performance, Coaching, and Discipline

Performance records connect expectations, measured facts, feedback, development, and outcomes. Operational metrics inform review but are not accepted blindly; volume, complexity, equipment, congestion, route conditions, training, and data quality are considered.

Coaching, warnings, improvement plans, commendations, and discipline preserve date, policy/expectation, evidence, Employee response, manager, Human Resources review, follow-up, and outcome. Similar situations should receive consistent treatment. Restricted case details do not become general operational history.

## 35. Employment Changes and Separation

Promotion, transfer, demotion, schedule change, status change, compensation change, leave, and supervisor change are separately effective-dated and approved. One change may coordinate multiple future-dated consequences without overwriting prior history.

Separation records type, reason category, effective/last-work dates, notice, final-pay/leave treatment, property return, access removal, benefits continuation activity, required notifications, and rehire eligibility. Detailed confidential reasons remain access-restricted.

Payroll, Finance, Security, Facility, Transportation, Warehouse, and other affected domains receive assigned offboarding tasks. Termination cannot delete prior transactions or accountability.

## 36. Temporary Labor and External Workers

Temporary agency workers, contractors, service technicians, and other nonemployees are identified separately from Employees. Their sponsoring Supplier/agency, engagement, authorized work, schedule, qualifications, access, supervision, and end date remain explicit.

Agency time may support invoice validation but does not enter Employee Payroll. Independent-contractor classification requires documented review. External workers cannot fill regulated or safety-sensitive work without the same required qualification evidence and supervision.

## 37. Employee Property, Access, and Accountability

Issued keys, badges, devices, uniforms, protective equipment, tools, fuel/payment cards, and other property are assigned with condition, date, custodian, acknowledgment, and return/disposition.

Employment status does not itself grant application authority. Security roles derive from approved job need and segregation rules, are reviewed on transfer, and are removed promptly at separation. Shared identities are prohibited.

## 38. Privacy and Sensitive Information

PFD separates routine Employee information from restricted tax identifiers, banking instructions, medical/accommodation facts, background results, garnishments, benefit dependents, and investigation material.

Sensitive values are encrypted or tokenized where appropriate, masked in ordinary screens/reports, and available only to specifically authorized roles. Reports use the minimum necessary information. Access and export are audited.

Managers receive schedule, eligibility, performance, and work-restriction facts needed to operate safely—not unrelated Payroll or medical details.

## 39. Logical Business Structures

| Structure | Natural business key |
|---|---|
| Employee | `employee_number` |
| Employment Period | Employee Number + employment-period sequence |
| Department | `department_code` |
| Job | `job_code` |
| Position | `position_number` |
| Employee Assignment | Employee Number + assignment sequence |
| Workforce Plan | `workforce_plan_number` |
| Hiring Requisition | `requisition_number` |
| Applicant | `applicant_number` |
| Application | Applicant Number + application sequence |
| Employment Offer | `offer_number` |
| Onboarding Case | Employee Number + employment-period sequence |
| Shift Template | `shift_code` + effective from |
| Published Schedule | `schedule_number` |
| Scheduled Shift | Schedule Number + shift sequence |
| Time Entry | `time_entry_number` |
| Time Correction | Time Entry Number + correction sequence |
| Leave Plan | `leave_plan_code` + effective from |
| Leave Account | Employee Number + Leave Plan Code + eligibility period |
| Leave Request | `leave_request_number` |
| Compensation Agreement | Employee Number + agreement sequence |
| Benefit Plan | `benefit_plan_code` + effective from |
| Benefit Enrollment | Employee Number + Benefit Plan Code + coverage period |
| Deduction/Garnishment Instruction | `payroll_instruction_number` |
| Training Requirement | `training_requirement_code` + effective from |
| Employee Qualification | Employee Number + requirement code + qualification sequence |
| Payroll Calendar | `payroll_calendar_code` |
| Payroll Period | Payroll Calendar Code + period number |
| Payroll Run | `payroll_run_number` |
| Payroll Calculation Version | Payroll Run Number + version number |
| Employee Payroll Result | Payroll Run Number + version + Employee Number |
| Payroll Result Component | Result key + component sequence |
| Payroll Adjustment | `payroll_adjustment_number` |
| Employment Case | `employment_case_number` |
| Safety/Work Incident | `incident_number` |
| Property Assignment | Employee/External Worker key + property assignment sequence |

Parent-relative sequences are governed, permanent within the parent, and never reused. No identity, serial, UUID, hidden generic ID, or simulation-session key is permitted.

## 40. Core Lifecycle Rules

- Only an active, eligible Employee may be scheduled for Employee work.
- A task requiring qualification may be assigned only while qualification is valid.
- Schedule, attendance, payable time, and operational production remain distinct facts.
- Approved time consumed by Payroll is immutable.
- A Payroll Run cannot be approved with unresolved material exceptions.
- An approved Employee Result cannot be overwritten or deleted.
- One approved input contributes to one intended Payroll consequence.
- Net pay plus deductions and taxes must equal gross pay subject to documented components and rounding.
- Payroll control totals must reconcile across Run, Employee Results, payment instructions, Finance liabilities, cash release, and Journals.
- Separation closes future eligibility but preserves history.

## 41. Approvals and Segregation of Duties

| Activity | Required control |
|---|---|
| Hiring requisition | Department request plus budget/HR approval |
| Offer and hire | Authorized manager and HR review |
| Compensation change | Budget/delegated approval independent of beneficiary |
| Employee time | Employee/source evidence plus supervisor approval |
| Supervisor's own time | Next-level or independent approval |
| Payroll input adjustment | Source evidence and authorized review |
| Payroll Run | Preparer distinct from approver |
| Payroll payment | Finance release distinct from Payroll preparation |
| Bank reconciliation | Independent of payment release where practical |
| Owner compensation | Configured independent owner approval; affected owner cannot approve unilaterally |
| Sensitive data change | Restricted authority and audit |
| Separation/access removal | HR authorization plus independent task completion |

Emergency actions remain visible, time-limited, and independently reviewed afterward.

## 42. Events and Integration

Workforce/Payroll publishes stable events such as Employee Hired, Assignment Changed, Schedule Published, Employee Absent, Qualification Changed, Time Approved, Payroll Approved, Payroll Corrected, and Employee Separated.

Each event identifies actual/business time, recorded time, Employee/business key, source record/version, action, and correlation. Consumers process idempotently. A retry cannot duplicate access, schedule, pay, liability, or Journal consequences.

Inbound operational events provide evidence, not unrestricted update authority. Conflicts create assigned exceptions.

## 43. Reports and Measures

- Active headcount, full-time equivalent, vacancies, starts, separations, turnover, and tenure
- Staffing plan versus scheduled and actual available labor
- Shift coverage, call-offs, absences, leave, overtime, and temporary labor
- Labor hours/cost by Department, function, Route, shift, and approved cost dimension
- Qualification, training, expiration, and cross-training coverage
- Time awaiting approval, missing punches, corrections, and late inputs
- Payroll register, control totals, gross-to-net, employer cost, and prior-Run variance
- Payroll payment/rejection/correction and liability-remittance status
- Compensation and benefit participation under restricted access
- Safety/work-restriction, property, onboarding, and offboarding exceptions
- Owner compensation approvals and separation from distributions

Metrics distinguish operational time, payroll time, and accounting period. Sensitive reports are role-limited.

## 44. Audit, Retention, and Correction

Audit records preserve Principal/process, actual/business time, entry time, permanent business key, action, prior/new status or controlled value, source, reason, approval, and correlation.

Approved time, compensation history, payroll calculations/results, tax/deduction instructions, qualifications, employment changes, and separation records are append-only or effective-dated. Corrections preserve the original and authorized replacement.

Retention and legal-hold schedules are record-type and jurisdiction specific. Expiration removes or anonymizes eligible sensitive evidence only through an authorized, audited process; required financial and employment history remains intact.

## 45. Business Continuity

During system interruption, PFD may use controlled numbered schedule, attendance, time, hiring, and payroll documents. Emergency payroll requires explicit authority, known funding, preserved source evidence, and later independent reconciliation.

Recovery records actual occurrence time and later entry time. Duplicate detection applies to time, deductions, Payroll Results, payment instructions, liabilities, and Journals. A recovered event never silently replaces a completed event.

## 46. Simulation

Simulation creates and updates ordinary Employees, assignments, schedules, absences, time, leave, compensation, qualifications, Payroll Runs, Results, and operating/Finance consequences exactly as normal business would.

A Simulation Session may control business time and randomness but does not appear in Workforce or Payroll primary keys. A simulated day or week becomes ordinary business history in that database copy. Scenario reset occurs outside the business model.

## 47. Decisions Established

- Opening workforce is approximately 45–50 people, including four owner-managers.
- Human Resources and Payroll administration report through Finance and Administration.
- PFD uses one biweekly payroll calendar for all Employees and owners on Payroll.
- Rehire retains the Employee Number and creates a new employment period.
- Employee, assignment, compensation, qualification, schedule, time, and Payroll Result are separate facts.
- Work schedules follow the office, warehouse, and delivery operating cycle rather than a single daytime model.
- All valid compensable time is paid; approval violations are handled separately.
- Temporary workers are not Employees and do not enter Employee Payroll.
- Payroll owns approved calculations/results; Finance owns cash release, liabilities, remittance, Journals, and reconciliation.
- Owner compensation is Payroll; owner distributions are not.
- Approved payroll history is immutable and corrected forward.
- Natural business keys are mandatory; surrogate and simulation-session keys are prohibited.

## 48. Remaining Configuration

The opening Employee roster, exact Position counts, job descriptions, wage/salary amounts, overtime/premium rules, leave plans, holidays, benefit plans/contributions, commission plans, tax jurisdictions/rates, deduction rules, training catalog, qualification intervals, schedule templates, approval thresholds, external Payroll provider choice, payment methods, retention periods, and report layouts are configuration—not unresolved architecture.

## 49. Acceptance Criteria

The design is acceptable when every Employee and external worker is uniquely governed; staffing and eligibility affect operating capacity; time and leave reconcile; Payroll can reproduce every approved gross-to-net Result; corrections preserve history; Finance can fund, post, and reconcile payroll exactly once; private data and approvals are properly separated; and a simulated business day/week uses the same records and controls as ordinary operation.

## 50. Next Design Work

Next: **PFD Workforce and Payroll PostgreSQL Build Specification**. It will define normalized PostgreSQL structures, natural keys, controlled functions, constraints, privileges, indexes, views, verification, and tests without executable SQL.
