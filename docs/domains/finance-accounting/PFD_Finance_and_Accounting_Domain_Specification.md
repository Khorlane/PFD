# \<business name>
# Finance and Accounting Domain Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Design baseline  
**Depends on:** PFD Customer, Product, Purchasing, Inventory, Sales, Warehouse, and Transportation designs

## 1. Purpose

Define how PFD controls credit, billing, receivables, payables, cash, banking, debt, equity, fixed assets, inventory valuation, journal posting, period close, budgeting, taxes, and financial reporting. This is business and logical-data design, not PostgreSQL implementation.

## 2. Accounting Basis and Objectives

PFD maintains its books on the accrual basis in accordance with generally accepted accounting principles appropriate to a privately held business. Finance shall produce reliable operational and statutory records, protect cash and assets, pay valid obligations promptly, recognize revenue and expenses in the proper period, and give owners timely information for decisions.

The accounting equation must remain in balance. Subsidiary records must reconcile to General Ledger control accounts. Financial reporting must remain traceable to originating business transactions rather than independent re-entry.

## 3. Scope

Finance and Accounting owns:

- Customer credit, terms, limits, holds, and exceptions
- Customer invoices, credit/debit memos, AR, receipts, cash application, disputes, collections, and expected credit losses
- Supplier invoices, three-way match, AP, disputes, payment proposals, payments, discounts, and remittance
- Bank accounts/transactions/reconciliation, cash forecasts, liquidity, and line-of-credit use
- Chart of Accounts, accounting periods, journals, posting, reconciliations, close, and statements
- Inventory valuation, financial reserves, and Inventory-to-GL reconciliation
- Fixed assets, depreciation, impairment, transfers, verification, and disposal
- Debt schedules, interest, covenants, owner capital, ownership interests, and distributions
- Tax records/calendars, payroll accounting/liabilities, budgets, forecasts, and financial approvals

It does not own operational Customer, Product, Order, Receipt, Inventory quantity, Warehouse, Delivery, employee/time, or Quality facts.

## 4. Governance

PFD's owner roster and effective ownership percentages are configurable opening data. Active Ownership Interests total exactly 100 percent. Management responsibility and Finance authority are effective assignments independent of ownership percentage.

The effective governance policy specifies the required owner approval count or ownership-percentage threshold for the annual operating budget/capital plan, material unbudgeted capital expenditures, new loans/material borrowing changes, real-property transactions, ownership changes, owner compensation/distributions, and appointment/removal of the General Manager. Thresholds must be valid for the active roster and enforce independent review of related-party matters.

Routine authority follows approved budgets, policies, delegated limits, and segregation of duties. Authorization, custody, recording, and reconciliation are separated whenever staffing reasonably permits.

## 5. Governing Decisions

1. Accounting uses accrual-basis GAAP and a calendar fiscal year with calendar-month periods.
2. Every financial transaction has one permanent business identity and source link.
3. Each approved source event posts its financial consequence exactly once; retries are idempotent.
4. Posted entries/documents are immutable; corrections use reversal or linked forward documents.
5. Debits equal credits before posting.
6. Closed periods reject ordinary posting.
7. Inventory is valued using FIFO; FEFO governs physical rotation only.
8. Revenue and related COGS are recognized upon accepted Customer delivery.
9. Refused, undelivered, or rejected quantities do not create completed revenue.
10. Freight-in and appropriate acquisition costs are included in landed Inventory cost.
11. Normal Customer terms are Net 30; approved governmental, school, healthcare, or contract accounts may use Net 45.
12. Finance controls credit independently of Sales.
13. Supplier invoices use three-way match; only a legitimately disputed portion may be held.
14. Valid undisputed supplier obligations are paid on time; worthwhile early-payment discounts are taken when liquidity permits.
15. PFD targets unrestricted cash of approximately one month of normal operating cash requirements and an unused revolving-credit limit of approximately one additional month.
16. Owner capital/distributions are not revenue/expense; owner payroll is separate.
17. Simulation uses the same Finance records as normal operation.

## 6. Record Ownership and Handoffs

| Source | Authoritative operational fact | Finance consequence |
|---|---|---|
| Sales | Price, terms evidence, released Order, billing instruction | Prepared invoice |
| Transportation | Accepted/refused/undelivered delivery and proof | Invoice finalization, revenue, AR, COGS |
| Inventory | Receipt/movement/ship/return/disposition and cost evidence | FIFO value, COGS, reserves, Inventory control |
| Purchasing/Receiving | PO commitment, accepted Receipt, discrepancy | AP match and obligation |
| Supplier | Supplier invoice/credit | AP claim subject to validation |
| Customer | Receipt/remittance/dispute | Cash, AR application, collection action |
| Payroll | Approved payroll result/liability | Expense, liability, cash, tax posting |
| Asset custodian | Asset acceptance/in-service/condition/disposal | Capitalization, depreciation, gain/loss |

Finance records financial consequences but does not rewrite source-domain facts.

## 7. Chart of Accounts

Each GL Account has a permanent Account Number, name, type, normal balance, posting/control status, currency behavior, effective dates, statement classification, tax mapping, and allowed dimensions.

Account types include Asset, Liability, Equity, Revenue, Cost of Goods Sold, Operating Expense, Other Income, and Other Expense. Control accounts for Cash, AR, AP, Inventory, Payroll Liabilities, Fixed Assets, Accumulated Depreciation, and Debt prohibit unsupported manual posting.

Account Hierarchies are effective-dated and versioned. A reporting reclassification does not change historical Journal Lines.

## 8. Accounting Periods

Each Accounting Period identifies fiscal year/month, start/end dates, status, close schedule, and authority. Statuses are Future, Open, Closing, Closed, and Exceptionally Reopened.

Transaction date, operational date, invoice date, due date, accounting date, and posting time remain distinct. Accounting date determines the period.

Exceptional reopening requires the authorized Finance role or delegated Finance authority, documented justification, limited scope/time, independent review, and republished report identification. Otherwise, later corrections post in the current open period with original-period reference.

## 9. Journal Entries and Posting

A Journal Entry records permanent Journal Entry Number, accounting date/period, source capability/transaction, entry type, description, preparer, approver, status, posting time, reversal/original reference, and correlation.

Journal Lines record governed line number, Account Number, debit or credit amount, currency, exchange basis when applicable, department/location/Product/Customer/Supplier/Route/asset dimensions when allowed, and source detail.

One line carries either debit or credit, not both. Total debits equal total credits in each transaction currency and reporting currency before posting. Posted Journals cannot be edited/deleted. Reversal creates a new balanced Journal referencing the original.

## 10. Automated Posting and Idempotency

Approved source events generate balanced journals through defined posting rules. The source-domain, permanent source key, event type, accounting basis/version, and reversal state form unique posting identity.

Posting failure leaves an assigned exception and does not partially update a subsidiary or GL. Restarting safely completes or recognizes the prior posting. A source event cannot post twice under a different batch merely because processing was retried.

Posting batches group controlled work but do not replace individual Journal identity or source traceability.

## 11. Customer Credit

A Credit Account is distinct from Customer status and may cover one or more explicitly authorized Customer Accounts. It records limit, payment terms, risk class, review date, status, exposure policy, and responsible Finance Principal.

Credit exposure includes posted AR, eligible pending-delivery invoices, released/unbilled demand, returned payments, and other governed commitments less approved payments/credits as defined by policy.

Credit Holds may arise from limit excess, missing advance payment, seriously overdue invoices, returned payment, or material concern. Sales may request review but cannot release the hold. Exceptions are scoped by Customer/Order/amount/time and require Finance approval.

New accounts begin conservatively; limits may increase after satisfactory history. Prepaid/COD activity while on credit hold requires permitted policy and confirmed payment evidence.

## 12. Customer Invoice Lifecycle

Each Customer Invoice receives a permanent Invoice Number before truck departure. The invoice uses reconciled loaded quantities and approved Sales price/tax/terms evidence and may accompany route paperwork.

| Status | Meaning |
|---|---|
| `PREPARED` | Billing facts assembled |
| `PRINTED` | Delivery document produced |
| `PENDING_DELIVERY` | Truck may depart; revenue/AR not final |
| `DELIVERY_EXCEPTION` | Outcome differs or is incomplete |
| `FINALIZED` | Accepted quantities established |
| `POSTED` | AR/revenue/COGS consequences recorded |
| `SETTLED` | Open-item balance resolved |
| `VOIDED` | Validly cancelled before financial posting |

Accepted delivery finalizes eligible lines. Refused, undelivered, rejected, or otherwise unaccepted quantities do not create completed revenue. Post-departure differences use controlled finalization adjustment, Credit Memo, Debit Memo, or Supplemental Invoice.

## 13. Invoice Lines, Tax, and Revenue

Invoice Lines reference Sales Order/Line and Delivery/Line, Product, quantity/unit, price decision, extension, discount/premium, charge, tax jurisdiction/class/rate/amount, revenue Account, COGS, and Inventory cost evidence.

Invoice totals reconcile to lines, charges, discounts, taxes, and prior adjustments. Later Customer/Product/price/tax changes do not rewrite Invoice evidence.

Revenue and COGS post in the same accepted-delivery period. Customer credits/returns reduce revenue in the appropriate period and record Inventory or loss consequences according to disposition. Drivers and Sales cannot change invoices or authorize credits.

## 14. Credit and Debit Documents

A Credit Memo, Debit Memo, or Supplemental Invoice has a permanent number, Customer, original Invoice/Delivery reference, reason, lines/amounts, requested/approved Principals, accounting treatment, and status.

Credits require original-transaction reference and approved reason. Material or unusual credits require management approval. A Customer Service request does not become a financial document until Finance approves it.

Posted adjustment documents create their own AR Open Items and balanced journals. They never overwrite the original Invoice.

## 15. Accounts Receivable

Each posted Invoice, credit/debit document, receipt, refund, or approved adjustment creates or affects an AR Open Item. The item records permanent AR Item Number, Customer/Credit Account, source document, original/due dates, original/open/disputed/undisputed amounts, currency, aging state, and status.

Open Item statuses include Open, Partially Paid, Paid, Disputed, Collections, Written Off, and Closed. Disputed and undisputed balances remain distinct; undisputed balances remain collectible according to terms.

AR aging uses Current, 1–30, 31–60, 61–90, and Over 90 days based on due date. The AR subsidiary must reconcile to the GL AR control account by period.

## 16. Customer Receipts and Application

A Customer Receipt records permanent Receipt Number, Customer/payer, received/deposit dates, method, amount/currency, remittance, Bank Transaction, status, and audit data.

Receipt Applications connect a Receipt or available credit to specific AR Open Items. Partial, multi-invoice, short-paid, deducted, and temporarily unapplied amounts are supported. Applications cannot exceed available receipt/credit or open item balance.

Unapplied cash remains a controlled Customer liability/clearing amount and part of bank/AR reconciliation. Refunds and write-offs require separate authorization from ordinary cash application.

## 17. Collections, Disputes, and Expected Credit Loss

Collections prioritize age, amount, risk, promise date, dispute, and Customer importance. Activities retain contact, channel, facts, promise to pay, follow-up date, owner, result, and escalation.

Invoice disputes identify affected items/amount, reason, evidence, owner, requested resolution, and outcome. Resolving a dispute may create no change, application, Credit/Debit Memo, refund, or approved write-off.

PFD records an allowance for expected credit losses using an approved method and current evidence. Write-off requires authority and reduces the allowance/AR as appropriate; it does not erase collection history. Later recovery links to the written-off item.

## 18. Supplier Invoice Capture

Each Supplier Invoice receives a permanent PFD AP Invoice Number while retaining Supplier Number and Supplier Invoice Number. Duplicate detection considers Supplier, external invoice number, date, amount, currency, and document similarity.

Header information includes invoice/due/discount dates, terms, total, PO/expense authority, received time/channel, tax/freight, status, and audit data. Lines identify Product, expense, freight, tax, asset, or other authorized charge.

An apparent duplicate is blocked for review; no user can bypass the check without documented independent approval.

## 19. Three-Way Match

Product charges match Supplier Invoice Line to Purchase Order Line and one or more accepted Receipt Lines. The match compares quantity/unit, price, freight, discount, tax, and arithmetic using approved tolerances.

Mismatch ownership follows the underlying fact:

- Purchasing: ordered quantity, price, discount, freight, or commercial commitment
- Receiving: accepted/rejected quantity or condition fact
- AP: duplicate, arithmetic, invoice/reference, or remittance data
- Quality/Purchasing: quality claim or Supplier return

Match Results preserve compared values, tolerance version, outcome, exception, and resolution. PO or Receipt facts are not revised merely to make an Invoice match.

## 20. Supplier Disputes and AP Open Items

A Supplier Dispute records Supplier/Invoice/Line, disputed amount, undisputed amount, reason, owner, communications, proposals, agreement, credit/adjustment, due date, and status.

PFD seeks cooperative resolution before due date. A disputed portion may be temporarily held, but the valid undisputed portion remains eligible for timely payment.

Approved Supplier Invoices/Credits create AP Open Items with permanent numbers, source, due/discount dates, original/open/disputed/undisputed amounts, currency, and status. AP subsidiary totals reconcile to the GL AP control account.

## 21. Payment Proposal and Discounts

A Payment Proposal selects approved AP Items according to due date, discount date/return, cash forecast, one-month cash target, priority, Supplier relationship, remittance clarity, and payment method.

The Discount Decision records available discount, payment date, cash required, effective return, liquidity effect, decision, and reason. PFD takes legitimate worthwhile discounts when adequate cash remains available and does not intentionally wait until the last moment to pay valid bills.

Proposal changes preserve history. Invoice entry and ordinary payment preparation do not authorize release of cash.

## 22. Supplier Payment and Remittance

Each Supplier Payment has a permanent Payment Number, payee, Bank Account, method, value/release dates, currency/amount, Proposal, approver, status, Bank Transaction, and reversal/void reference.

Payment Applications connect the Payment to AP Open Items, Supplier Credits, discounts, and disputed balances. Controls prevent duplicate payment and application beyond approved undisputed/open amounts.

Remittance identifies paid, credited, discounted, and still-disputed amounts. Payment, AP settlement, bank transaction, and Journal commit as one controlled business consequence or remain visibly incomplete for recovery.

## 23. Inventory Valuation and Landed Cost

Inventory quantity remains owned by Inventory. Finance owns FIFO valuation layers and financial reserves. Each accepted acquisition creates or updates a FIFO layer tied to Inventory Lot, Receipt, PO, Supplier Invoice/estimated liability, quantity, unit cost, freight-in, allowances, and other eligible landed costs.

Physical FEFO selection may consume a different lot sequence than accounting FIFO valuation. Both remain traceable; Finance does not change physical selection to force valuation.

COGS consumes FIFO value when accepted delivery recognizes revenue. Returns, Supplier returns, damage, spoilage, expiration, shrink, donation, and disposal create controlled valuation consequences. Quantity, valuation layers, and Inventory GL control reconcile by period.

## 24. Accruals and Inventory Reserves

Accepted Inventory without a Supplier Invoice may create a received-not-invoiced accrual. When the invoice arrives, the accrual reverses/clears through matched posting without duplicate expense or liability.

PFD estimates and records shrink, spoilage, obsolescence, expiration, and other Inventory reserves using approved policy and evidence. Estimates retain method, population, assumptions, preparer, approver, period, Journal, and later true-up.

An unexplained physical variance is not hidden in reserve calculations; it remains an Inventory/Accounting exception until approved adjustment.

## 25. Cash and Bank Accounts

Each Bank Account has a permanent Bank Account Number, institution/branch, purpose, currency, GL Account, restricted/unrestricted status, authorized uses/signers, effective dates, and protected external-account evidence.

Bank Transactions record permanent identity, date/time, type, amount, source transaction, statement reference, status, and Journal. They do not replace the originating Customer Receipt, Supplier Payment, payroll payment, debt event, transfer, fee, interest, or owner transaction.

Access to account/routing numbers, credentials, and banking instructions is restricted. Changes require independent verification and audit.

## 26. Bank Reconciliation

Each Bank Statement records external statement identity, period, beginning/ending balance, and imported/manual line evidence. Statement Lines remain distinct from PFD Bank Transactions.

A Bank Reconciliation matches book and bank activity, identifies outstanding checks, deposits in transit, fees, interest, stale/duplicate/unusual items, and unexplained differences. Reconciliation retains preparer, independent reviewer, completion time, and Journal references.

No unexplained plug may force agreement. Each account is reconciled monthly and material differences remain assigned.

## 27. Cash Forecast and Liquidity

A Cash Forecast retains as-of time, horizon, version, assumptions, opening available/restricted cash, expected Customer receipts, Supplier payments, payroll, taxes, debt service, capital spending, and other inflows/outflows.

PFD targets unrestricted cash equal to approximately one month of normal operating cash requirements. Its unused revolving line target is approximately one additional month. Forecasts identify shortfalls, discount opportunities, covenant effects, and actions without rewriting source commitments.

Cash priorities are:

1. Payroll, taxes, and safety-critical obligations
2. Valid Supplier obligations
3. Debt service, insurance, utilities, and essential expenses
4. Inventory for committed Customer demand
5. Approved capital investment
6. Discretionary spending and owner distributions

## 28. Debt and Revolving Credit

Each Debt Instrument records permanent Debt Number, lender, type, principal, currency, rate/index, term, maturity, payment schedule, collateral, covenant, purpose, status, and approvals. Facility mortgage, truck financing, and revolving line remain identifiable.

Debt Schedule Lines separate principal, interest, fee, due date, payment, and projected balance. Principal reduction and interest expense post separately.

Normal revolving-credit draws require owner approval. An emergency draw may prevent overdraft or missed payroll; it must be immediately reported and reviewed by owners. The line is a contingency/seasonal tool, not a substitute for profitable operations.

## 29. Owner Equity

Each Owner has a permanent Owner Number linked to the applicable Person/Party. Effective Ownership Interests preserve percentage and dates. The selected opening baseline supplies one or more effective Owners whose interests total exactly 100 percent.

Owner Capital Transactions distinguish contribution, distribution, owner loan, repayment, and other approved equity events. Contributions increase cash/property and equity; distributions reduce cash/equity and are not operating expense.

Owner compensation uses payroll or another approved compensation process. Distributions require the approvals configured by effective governance policy, adequate capitalization, satisfied loan/covenant requirements, and protection of the cash reserve.

## 30. Capital Requests and Fixed Assets

A Capital Request records business need, alternatives, purchase/financing cost, capacity/service/revenue/savings effect, cash-flow effect, depreciation/interest, risk, useful life, budget status, and recommendation.

Material unbudgeted capital requires the configured reserved-matter approvals. Approval alone does not create an Asset; accepted acquisition and placed-in-service evidence do.

Each Fixed Asset receives a permanent Asset Number and records class, description, acquisition source/cost, placed-in-service date, location, custodian, useful life, residual value, status, component relationships, and financing links. The Charlotte facility and six financed trucks are owned Assets distinct from their Debt Instruments.

## 31. Depreciation, Maintenance, and Disposal

Depreciation Schedules identify Asset/component, approved method, basis, useful life, convention, start/end, accumulated amount, and Journal history. Reasonable lives/methods follow adopted accounting/tax policy.

Repairs/routine maintenance are expensed unless they materially extend useful life or capacity. Operational maintenance comes from the custodian domain; Finance determines expense/capital treatment.

Asset transfer/verification preserves location/custodian/existence. Impairment and disposal require evidence and approval. Disposal records proceeds, removal costs, accumulated depreciation, gain/loss, debt effect, and retirement while retaining permanent history.

## 32. Payroll and Employee Liabilities Boundary

The Workforce/Payroll domain owns Employee, assignment, compensation, schedules, time, leave, Payroll Run, and Employee Result. Finance owns cash release, payroll liabilities, tax/benefit remittance, Journal posting, and reconciliation.

Hourly employees are paid biweekly. Salaried employees and owners on payroll are paid biweekly or semimonthly according to the adopted calendar. Approved Payroll Results post wages, employer taxes/benefits, deductions, liabilities, and net pay exactly once.

Payroll preparation, approval, payment release, bank reconciliation, and owner distributions remain separated. Owner distributions never flow through payroll expense.

## 33. Taxes and Regulatory Financial Records

Finance maintains effective tax registrations, jurisdictions, filing calendars, payment obligations, returns, supporting calculations, and evidence for sales/use, payroll, income, property, vehicle, and other applicable taxes.

Sales tax calculation uses Sales/Customer/Product/delivery evidence; Finance owns filing, payable, remittance, and reconciliation. Payroll supplies approved wage/tax results. Fixed Assets and Transportation supply property/vehicle evidence.

Tax estimates, returns, payments, and adjustments are separately identifiable. Filing/payment deadlines create assigned work. No tax liability is removed merely because a return has been filed or payment initiated.

## 34. Monthly Close

The Close Calendar assigns tasks, dependencies, due dates, owners, reviewers, evidence, and status. Monthly close includes:

- Bank/cash reconciliation
- AR and AP subsidiary reconciliation
- Inventory quantity/FIFO value and reserve review
- Received-not-invoiced and other accruals
- Payroll expense/payment/liability reconciliation
- Fixed Asset/depreciation review
- Debt, interest, and covenant reconciliation
- Tax liability review
- Revenue, COGS, gross margin, expense, and unusual-balance review
- Trial Balance, Income Statement, Balance Sheet, and cash-flow review
- Budget comparison and material-variance explanation

Close cannot use unexplained forced balances. Assets must equal Liabilities plus Equity. Authorized Finance closes the period only after required reconciliations and exceptions are resolved or formally assigned under closing policy.

## 35. Financial Statements and Formal Snapshots

PFD produces Trial Balance, Income Statement, Balance Sheet, Cash Flow Statement/Review, equity activity, and supporting schedules. Published statements identify period/as-of time, accounting basis, hierarchy/version, currency, preparation, approval, and superseded version when applicable.

Formal snapshots are immutable. A corrected publication creates a new version linked to the original and explains the reason. Drill-through reaches Journal Lines and source business records subject to access rights.

## 36. Budgeting and Forecasting

The annual Operating Budget and Capital Plan integrate Sales volume/margin, Purchasing/Inventory, labor, facility/fleet capacity, operating expenses, cash, debt, and capital investment. The effective governance policy determines the required owner approvals for the final baseline.

Budget Lines identify period, GL Account/dimension, amount, assumptions, owner, and version. Changes after approval require controlled revision and authority; actual results are never altered to match budget.

Management reviews actual versus budget monthly. Material unfavorable variances require explanation, responsible owner, corrective action, and follow-up. Rolling forecasts preserve as-of assumptions and do not replace the approved budget baseline.

## 37. Logical Structures

| Structure | Natural primary key |
|---|---|
| GL Account | `account_number` |
| Account Hierarchy Version | hierarchy code + effective from |
| Accounting Period | `period_code` |
| Journal Entry | `journal_entry_number` |
| Journal Line | journal entry number + line number |
| Posting Batch | `posting_batch_number` |
| Credit Account | `credit_account_number` |
| Credit Decision/Hold | credit account number + decision/hold sequence |
| Customer Invoice | `invoice_number` |
| Customer Invoice Line | invoice number + line number |
| Credit/Debit/Supplemental Document | document type + document number |
| AR Open Item | `ar_item_number` |
| Customer Receipt | `customer_receipt_number` |
| Receipt Application | `application_number` |
| Collection/Dispute | Customer/Credit Account + case number |
| AP Invoice | `ap_invoice_number` |
| AP Invoice Line | AP invoice number + line number |
| Match Result | `match_result_number` |
| Supplier Dispute | `supplier_dispute_number` |
| AP Open Item | `ap_item_number` |
| Payment Proposal | `payment_proposal_number` |
| Supplier Payment | `supplier_payment_number` |
| Payment Application | supplier payment number + application sequence |
| FIFO Valuation Layer | `valuation_layer_number` |
| Bank Account | `bank_account_number` |
| Bank Transaction | `bank_transaction_number` |
| Bank Statement | bank account number + statement identifier |
| Bank Reconciliation | `reconciliation_number` |
| Cash Forecast | `cash_forecast_number` |
| Debt Instrument | `debt_number` |
| Debt Schedule Line | debt number + due date + sequence |
| Owner | `owner_number` |
| Ownership Interest | owner number + effective from |
| Owner Capital Transaction | `capital_transaction_number` |
| Capital Request | `capital_request_number` |
| Fixed Asset | `fixed_asset_number` |
| Asset Component | fixed asset number + component code |
| Depreciation Schedule | fixed asset number + component code + schedule version |
| Tax Obligation/Return | tax registration + tax type + tax period |
| Close Task | period code + close task code |
| Financial Statement Snapshot | statement type + period/as-of + version |
| Budget | `budget_number` |
| Budget Line | budget number + line number |
| Forecast | `forecast_number` |

All parent-relative sequences are governed. No surrogate keys are permitted.

## 38. Integrity and Reconciliation Rules

- Journal Entries are balanced before posting.
- One source event produces one intended posting/reversal chain.
- Posted financial records reject update/delete.
- Closed periods reject ordinary posting.
- Invoice accepted quantities reconcile to Delivery and Inventory evidence.
- AR/AP applications cannot exceed available/open amounts.
- Supplier payments cannot exceed approved payable amounts or pay duplicates.
- AR, AP, Inventory, Payroll, Fixed Asset, Debt, Tax, and Cash subsidiaries reconcile to GL controls.
- Bank Reconciliation explains every difference.
- FIFO layer quantity/value reconciles to Inventory and COGS.
- Asset cost less accumulated depreciation/impairment equals carrying amount.
- Debt schedules reconcile to principal/interest and GL.
- Ownership interests total 100% for active periods.
- Assets equal Liabilities plus Equity.

## 39. Approvals and Segregation of Duties

| Activity | Required separation/control |
|---|---|
| Customer credit/hold | Finance independent of Sales |
| Customer credit/adjustment | Request distinct from authorized financial issuance |
| Supplier invoice/payment | Entry/preparation distinct from payment release |
| Banking instruction change | Independent verification |
| Cash receipt/application | Reconciliation independent where staffing permits |
| Manual Journal | Material entry independently approved |
| Inventory adjustment/value reserve | Operations evidence plus Finance approval |
| Payroll | Preparation, approval, payment, and reconciliation separated |
| Capital/debt/distribution | Budget/delegated authority or required owner vote |
| Period close | Task preparation and review documented |

No person controls an entire high-risk financial process without independent review when staffing reasonably permits.

## 40. Reports and Measures

- Daily cash position and rolling forecast
- Cash target and revolving-credit availability/use
- Credit exposure, holds, exceptions, and review dates
- Invoice status, AR aging, DSO, disputes, promises, expected losses, and write-offs
- Supplier Invoice match/exception, AP aging, payment due, and remittance
- Early discounts available/taken/lost
- Inventory FIFO valuation, COGS, reserves, and Inventory-to-GL reconciliation
- Bank reconciliations and unreconciled/unusual items
- Debt service, interest, maturity, collateral, and covenant status
- Fixed Asset additions, depreciation, maintenance-cost evidence, verification, and disposal
- Payroll/tax liabilities and payment status
- Trial Balance and financial statements
- Actual versus budget/forecast and material variance action
- Profitability by Customer, Product, segment, Sales representative, and Route
- Owner capital, loans, compensation references, and distributions

## 41. Security and Audit

Finance access is separated among Credit, Billing/AR, AP, Cash Management, Payroll, Accounting, and approval roles as practical. Sensitive bank, tax, payroll, debt, owner, and Customer/Supplier financial data is role-limited and excluded from general operational/reporting access.

Posted documents, Journals, applications, reconciliations, statements, approval decisions, and audit events are append-only. Direct application writes are prohibited outside controlled services. `PUBLIC` receives no domain access.

Audit records include actual/business/accounting time, Principal/process, permanent record key, action, prior/new status or controlled value, source, reason, approval, reversal, and correlation. Audit does not replace the business record.

## 42. Business Continuity

Banking/system outages preserve controlled numbering, authorization, and source evidence. Emergency Supplier payment, payroll, credit-line draw, or Customer receipt activity requires explicit emergency authority and later independent reconciliation.

Recovered entries retain actual transaction time, later entry/posting time, source documents, and operator. Recovery processing prevents duplicate cash, AR, AP, payroll, Inventory, debt, or Journal effects.

## 43. Simulation

Simulation uses ordinary Invoices, AR/AP Items, Receipts, Payments, Bank Transactions, Inventory Valuation Layers, Assets, Debt, Journals, periods, budgets, and reports. A Simulation Session may control business time but does not partition or enter operational/accounting primary keys.

A simulated day/week posts and reconciles exactly as normal business. Later scenario reset occurs outside the business model; period comparisons and financial reports derive from the actual tables and dates.

## 44. Remaining Configuration

Opening Chart of Accounts, Account Hierarchies, control mappings, materiality/tolerance/approval limits, credit methods, tax registrations/rules, useful lives/depreciation methods, banking/debt details, close calendar/tasks, reserve methodologies, budget lines, and report formats are configuration—not unresolved architecture.

## 45. Next Step

Next design deliverable: **PFD Finance and Accounting PostgreSQL Build Specification**. It will define normalized structures, natural keys, constraints, functions, privileges, verification, and tests without executable SQL.
