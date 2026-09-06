# Finance and Accounting PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 5, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Changes `0099`–`0126`  
**Depends on:** Cumulative design through `0098`; Finance and Accounting Domain Specification

## 1. Purpose

Define PostgreSQL structures and controls for the Chart of Accounts, periods, journals, credit, invoices, AR, receipts, collections, AP, matching, payments, FIFO valuation, cash, banking, debt, equity, fixed assets, taxes, close, budgets, reporting, and audit. This remains design only.

## 2. Required Outcome

- Accrual-basis GAAP records use calendar months and a calendar fiscal year.
- Each source event produces its financial consequence exactly once.
- Posted financial records are immutable and corrected through linked forward records.
- Every Journal balances and every subsidiary reconciles to its GL control account.
- Revenue and related COGS post only for accepted Customer delivery.
- Inventory financial cost uses FIFO while physical rotation remains FEFO.
- Supplier disputes preserve prompt payment of valid undisputed amounts.
- Cash, borrowing, owner, and payment actions enforce approval and segregation.
- Natural business numbers/composites are the only primary keys.
- Simulation uses ordinary Finance tables without a simulation key.

## 3. Platform and Package

PostgreSQL 15 or later; existing `core`, `party`, `customer`, `product`, `purchasing`, `inventory`, `warehouse`, `sales`, `transportation`, `quality`, `workforce`, `payroll`, `finance`, `audit`, and `reporting` schemas; cumulative manifest `9.0.0`; immutable changes `0001`–`0098`; transactional changes `0099`–`0126` through the standard runner.

Workforce/Payroll and remaining Quality references use governed business keys and documented deferred constraints until the owning packages activate them.

## 4. Standards

Use lowercase `snake_case`, uppercase governed codes, `numeric(19,4)` monetary amounts, `numeric(19,6)` quantities, `numeric(9,6)` rates/percentages, `numeric(19,10)` exchange rates, `char(3)` ISO currency codes, `date` for business/accounting dates, and `timestamptz` for events/effective periods.

Mutable working rows use standard Principal/timestamp audit columns and positive `row_version`. Posted documents, Journal Lines, applications, decisions, reconciliations, statement snapshots, and audit events are append-only.

Business numbers/codes and governed composites are primary keys. Complete natural keys propagate through foreign keys. No identity, serial, UUID, generic hidden ID, or nullable-key placeholder is permitted.

## 5. Controlled Numbers

Change `0099` adds Core-controlled, permanent, nonreusable sequences:

| Sequence | Example |
|---|---|
| `JOURNAL_ENTRY` | `JE0000000001` |
| `POSTING_BATCH` | `PB00000001` |
| `CREDIT_ACCOUNT` | `CA00000001` |
| `CUSTOMER_INVOICE` | `INV00000001` |
| `CUSTOMER_ADJUSTMENT` | `CAD00000001` |
| `AR_OPEN_ITEM` | `ARI00000001` |
| `CUSTOMER_RECEIPT` | `CR00000001` |
| `AR_APPLICATION` | `ARA00000001` |
| `AR_CASE` | `ARC00000001` |
| `AP_INVOICE` | `API00000001` |
| `AP_MATCH_RESULT` | `APM00000001` |
| `SUPPLIER_DISPUTE` | `SDP00000001` |
| `AP_OPEN_ITEM` | `APO00000001` |
| `PAYMENT_PROPOSAL` | `PPR00000001` |
| `SUPPLIER_PAYMENT` | `SPY00000001` |
| `VALUATION_LAYER` | `VAL00000001` |
| `FINANCIAL_ESTIMATE` | `EST00000001` |
| `BANK_TRANSACTION` | `BTX00000001` |
| `RECONCILIATION` | `REC00000001` |
| `CASH_FORECAST` | `CFC00000001` |
| `DEBT_INSTRUMENT` | `DBT00000001` |
| `CREDIT_LINE_DRAW` | `CLD00000001` |
| `OWNER` | `OWN000001` |
| `OWNER_CAPITAL_TRANSACTION` | `OCT00000001` |
| `CAPITAL_REQUEST` | `CAP00000001` |
| `FIXED_ASSET` | `AST00000001` |
| `PAYROLL_LIABILITY` | `PYL00000001` |
| `TAX_PAYMENT` | `TXP00000001` |
| `FINANCIAL_STATEMENT` | `FST00000001` |
| `BUDGET` | `BUD00000001` |
| `FORECAST` | `FCT00000001` |
| `FINANCE_AUDIT_EVENT` | `FAE0000000001` |

Parent-relative lines, decisions, holds, activities, schedule rows, applications, and versions use governed sequence values within the parent business transaction.

## 6. Reference Data

Opening reference groups include:

| Reference | Opening codes |
|---|---|
| Account type | `ASSET`, `LIABILITY`, `EQUITY`, `REVENUE`, `COGS`, `OPERATING_EXPENSE`, `OTHER_INCOME`, `OTHER_EXPENSE` |
| Period status | `FUTURE`, `OPEN`, `CLOSING`, `CLOSED`, `EXCEPTIONALLY_REOPENED` |
| Journal status | `DRAFT`, `VALIDATED`, `PENDING_APPROVAL`, `APPROVED`, `POSTED`, `REVERSED`, `CANCELLED` |
| Invoice status | `PREPARED`, `PRINTED`, `PENDING_DELIVERY`, `DELIVERY_EXCEPTION`, `FINALIZED`, `POSTED`, `SETTLED`, `VOIDED` |
| AR/AP item status | `OPEN`, `PARTIALLY_SETTLED`, `SETTLED`, `DISPUTED`, `COLLECTIONS`, `WRITTEN_OFF`, `CLOSED` |
| AP invoice status | `RECEIVED`, `DUPLICATE_CHECK`, `MATCHING`, `MATCHED`, `EXCEPTION`, `APPROVED`, `SCHEDULED`, `PAID`, `CANCELLED` |
| Payment term | `PREPAID`, `COD`, `NET_30`, `NET_45`, `RESTRICTED` |
| Customer adjustment type | `CREDIT_MEMO`, `DEBIT_MEMO`, `SUPPLEMENTAL_INVOICE`, `WRITE_OFF`, `REFUND`, `RECLASSIFICATION` |
| Bank transaction type | `CUSTOMER_DEPOSIT`, `SUPPLIER_PAYMENT`, `PAYROLL_PAYMENT`, `TAX_PAYMENT`, `DEBT_PRINCIPAL`, `DEBT_INTEREST`, `TRANSFER`, `FEE`, `INTEREST_INCOME`, `OWNER_TRANSACTION`, `OTHER` |
| Debt type | `FACILITY_MORTGAGE`, `VEHICLE_LOAN`, `REVOLVING_LINE`, `OTHER_TERM_DEBT` |
| Asset status | `APPROVED`, `ORDERED`, `RECEIVED`, `IN_SERVICE`, `IDLE`, `MAINTENANCE`, `IMPAIRED`, `DISPOSED` |
| Owner transaction type | `CONTRIBUTION`, `DISTRIBUTION`, `OWNER_LOAN`, `OWNER_LOAN_REPAYMENT`, `OTHER_EQUITY` |

Reference tables follow the Core active/effective/audit pattern.

## 7. Chart of Accounts

`finance.gl_account` uses `account_number` as PK and stores name, account type, normal balance, posting/control flag, currency behavior, effective dates, financial-statement class, tax mapping, allowed dimensions, active status, and audit columns.

`finance.gl_account_control_rule` PK `account_number + control_rule_code + effective_from`; defines permitted posting sources and manual-post restrictions. Cash, AR, AP, Inventory, Payroll Liability, Fixed Asset, Accumulated Depreciation, and Debt control accounts reject unsupported manual Journal Lines.

`finance.account_hierarchy` uses `account_hierarchy_code` as PK. `finance.account_hierarchy_version` PK hierarchy code + effective-from; `finance.account_hierarchy_member` PK hierarchy code + effective-from + account number. Nonoverlap and acyclic hierarchy checks apply.

## 8. Accounting Dimensions and Currency

Journal dimensions use explicit natural keys for Department, facility/location, Customer, Supplier, Product/category, Route, Fixed Asset, and other approved dimensions. A generic unvalidated entity ID is prohibited.

`finance.account_dimension_rule` PK `account_number + dimension_type_code + effective_from`; states required/allowed/prohibited dimensions.

`finance.currency` uses ISO currency code as PK. `finance.exchange_rate` PK `rate_type_code + from_currency_code + to_currency_code + rate_date`; stores rate/source/verification. Opening reporting currency is configuration. Same-currency rate is one.

## 9. Accounting Periods

`finance.accounting_period` uses `period_code` as PK, recommended format `YYYY-MM`, and stores fiscal year/month, start/end dates, status, ordinary-posting cutoff, close/reopen authority, and row version.

`finance.accounting_period_status_history` PK period code + event time + status code; is append-only.

`finance.period_reopening` PK period code + reopening sequence; stores scope, reason, requested/approved Principals, independent review, open/close times, and republishing requirement. Only one ordinary period is current for a business date; date ranges cannot overlap.

## 10. Posting Rules and Source Registry

`finance.posting_rule` PK `posting_rule_code + effective_from`; stores source domain/event, accounting basis, debit/credit templates, dimension rules, rounding/balancing treatment, approval requirement, and effective-to.

`finance.posting_source_event` PK:

`source_domain_code + source_document_type_code + source_document_number + source_event_code + source_event_sequence`

It stores event/accounting dates, posting-rule version, status, Journal Entry Number, reversal source, correlation, and processed time. This composite is the exactly-once boundary.

`finance.posting_exception` PK source-event key + exception sequence; remains assigned until resolved/rejected. Operational source facts are referenced, not copied or rewritten.

## 11. Posting Batches and Journals

`finance.posting_batch` uses `posting_batch_number` as PK and stores source/process, period, created/validated/approved/posted times, totals/counts, status, and audit data.

`finance.journal_entry` uses `journal_entry_number` as PK and stores batch, accounting date/period, source-event key, entry type, description, preparer/approver, status, posting time, original/reversal reference, and correlation.

`finance.journal_line` PK journal entry + line number; stores Account Number, debit amount, credit amount, transaction/reporting currencies and amounts, exchange-rate key, approved dimensions, and source detail.

Checks require one positive debit or credit per line, balanced totals per currency/basis, open/reopened period, valid Account/dimensions, and required approval. Posting Journal, subsidiary change, and source-event completion commit atomically.

## 12. Credit Accounts and Customer Scope

`finance.credit_account` uses `credit_account_number` as PK and stores name, currency, terms, limit, risk class, exposure-policy code, review date, status, responsible Finance Principal, and row version.

Opening standard terms are `NET_30`; approved governmental, school, healthcare, or contract accounts may use `NET_45`. Finance approval is required for all credit terms and exceptions.

`finance.credit_account_customer` PK credit account + Customer Number + effective-from; stores relationship type, limit-sharing rule, billing relationship, approval, and effective-to. Effective rows cannot overlap ambiguously.

`finance.credit_policy` PK `credit_policy_code + effective_from`; defines exposure components, aging/hold thresholds, prepaid/COD treatment, exception authority, and review cadence.

Customer status and Credit Account status remain separate.

## 13. Credit Decisions, Exposure, and Holds

`finance.credit_decision` PK credit account + decision sequence; stores requested terms/limit/Order scope, exposure evidence, risk facts, decision, conditions, effective/expiry dates, approver, and reason.

`finance.credit_hold` PK credit account + hold sequence; stores hold type, optional Customer/Order scope, amount/currency, reason, source, opened/review/release times, status, and authorized releaser.

`finance.credit_exposure_snapshot` PK credit account + as-of time; stores posted AR, pending-delivery invoice, released-unbilled demand, returned payment, other commitments, payments/credits, net exposure, policy version, and source completeness.

Exposure snapshots support decisions but do not replace AR/Order facts. Sales cannot resolve Finance holds.

## 14. Customer Invoice

`finance.customer_invoice` uses `invoice_number` as PK and stores Customer/Credit Account, Sales billing instruction, delivery location, currency, invoice/accounting/due dates, terms/tax snapshots, status, current version, merchandise/charge/discount/tax/total amounts, Delivery outcome state, Journal/AR Item, and row version.

`finance.customer_invoice_line` PK invoice number + line number; stores Sales Order/Line, Delivery/Line, Product, unit/accepted quantity, Sales price-decision reference, unit price, extension, discount/premium, charge/tax/revenue classifications, FIFO COGS amount, and Inventory evidence.

`finance.customer_invoice_status_history` PK invoice + event time + status code; is append-only. Unique rules prevent more than one active Invoice for the same approved billing instruction unless explicitly supplemental/replacement.

Invoice preparation assigns the number before dispatch; `PENDING_DELIVERY` creates no final AR/revenue. Finalization uses authoritative accepted-delivery evidence.

## 15. Customer Adjustments

`finance.customer_adjustment` uses `customer_adjustment_number` as PK and stores adjustment type, Customer/Credit Account, original Invoice/Delivery, Customer Service request, reason, requested/approved Principals, currency/totals, accounting date, status, Journal/AR Item, and reversal reference.

`finance.customer_adjustment_line` PK adjustment number + line number; stores original Invoice Line, Product/charge, quantity, amount, tax, revenue/COGS effect, Inventory disposition reference, and reason.

Credit, debit, supplemental, write-off, refund, and reclassification effects remain distinct through type-specific checks/views. Posted adjustments are immutable and never overwrite the original Invoice.

## 16. AR Open Items

`finance.ar_open_item` uses `ar_item_number` as PK and stores Customer/Credit Account, source document type/number, original/due dates, original/open/disputed/undisputed amounts, currency, status, last activity, Journal, and row version.

`finance.ar_item_event` PK AR Item + event sequence; stores assessment, application, dispute, write-off, reopen, settlement, or reversal with signed amount, source, Principal, and event time.

Current balance/status is maintained atomically from immutable events and reconciled to source documents. Amount checks prohibit negative open/disputed/undisputed balances and require disputed + undisputed = open.

## 17. Customer Receipts and Applications

`finance.customer_receipt` uses `customer_receipt_number` as PK and stores Customer/payer, received/deposit/value dates, method, amount/currency, remittance/source reference, Bank Account/Transaction, status, unapplied amount, and row version.

`finance.ar_application` uses `application_number` as PK and stores Receipt/available credit, AR Item, applied amount, discount/deduction treatment, accounting date, Principal, status, Journal, and reversal reference.

Applications lock Receipt/credit and AR Item deterministically and cannot exceed available or open balances. Partial, multi-item, deduction, and temporarily unapplied cash are supported. Refund/write-off require separate approved Customer Adjustments.

## 18. Collections, Disputes, and Expected Credit Loss

`finance.ar_case` uses `ar_case_number` as PK and stores case type, Credit Account/Customer, optional AR Item, amount, owner, priority, opened/target dates, status, resolution, and row version.

`finance.ar_case_activity` PK AR Case + activity sequence; stores contact/communication, promise to pay, dispute evidence, next action, decision, and outcome. It is append-only.

`finance.expected_credit_loss_estimate` PK `period_code + estimate_version`; stores population/method/assumptions, calculated allowance, preparer/approver, status, Journal, and true-up reference.

`finance.ar_write_off_recovery` PK original adjustment number + recovery sequence; preserves later recoveries. Write-off does not delete Open Item or case history.

## 19. Supplier Invoice

`finance.ap_invoice` uses `ap_invoice_number` as PK and stores Supplier Number, external Supplier Invoice Number, invoice/received/due/discount dates, currency, terms, PO/expense authority, source channel/document, merchandise/freight/tax/total amounts, status, Journal/AP Item, and row version.

`finance.ap_invoice_line` PK AP Invoice + line number; stores line type, Product/expense/asset reference, quantity/unit, unit amount, freight/tax/discount, extension, PO Line reference, GL treatment, and status.

Unique/exception logic compares Supplier + normalized external number and detects similar date/amount/document duplicates. Duplicate-check release requires independent documented approval.

## 20. Three-Way Match and Exceptions

`finance.ap_match_result` uses `match_result_number` as PK and stores AP Invoice/Line, PO/Line, tolerance-policy version, matched/disputed amounts and quantities, result, evaluator, time, and status.

`finance.ap_match_receipt` PK match result + Receipt Number + Receipt Line Number; supports one invoice line matched to multiple accepted Receipts.

`finance.ap_match_difference` PK match result + difference sequence; stores quantity, price, freight, tax, discount, arithmetic, duplicate, quality, or documentation difference, expected/actual/tolerance, owner domain, and resolution.

PO and Receipt records remain authoritative and immutable to Finance. A Match Result records comparison, not rewritten operational truth.

## 21. Supplier Disputes and AP Open Items

`finance.supplier_dispute` uses `supplier_dispute_number` as PK and stores Supplier/AP Invoice/Line, disputed/undisputed amounts, reason, owner, due date, status, agreed resolution, Supplier Credit/adjustment reference, and row version.

`finance.supplier_dispute_activity` PK dispute + activity sequence; stores communication, proposal, evidence, promise, escalation, and outcome.

`finance.ap_open_item` uses `ap_item_number` as PK and stores Supplier, source document, original/due/discount dates, original/open/disputed/undisputed amounts, currency, status, Journal, and row version.

`finance.ap_item_event` PK AP Item + event sequence; supplies immutable application/dispute/settlement/reversal history. A dispute cannot block the validated undisputed amount.

## 22. Payment Proposals and Discounts

`finance.payment_proposal` uses `payment_proposal_number` as PK and stores proposed payment date, Bank Account/method, Cash Forecast version, target-reserve result, preparer, totals, status, approver, and row version.

`finance.payment_proposal_item` PK proposal + line number; stores AP Item, proposed amount, disputed exclusion, due/discount dates, priority, Supplier relationship factor, and selection reason.

`finance.early_payment_discount_decision` PK proposal + line number + decision sequence; stores available discount, required date/cash, effective return, liquidity effect, decision, and reason.

Proposal approval and payment release are separate. Selection cannot exceed approved undisputed/open AP amount.

## 23. Supplier Payments and Remittance

`finance.supplier_payment` uses `supplier_payment_number` as PK and stores Proposal/payee, Bank Account, method, release/value dates, currency/amount, preparer/approver/releaser, status, Bank Transaction, Journal, and void/reversal reference.

`finance.supplier_payment_application` PK payment + application sequence; stores AP Item, paid/discount/credit/disputed amounts and remittance classification.

`finance.supplier_remittance` PK payment + remittance version; stores publication time/method, paid/credited/discounted/still-disputed detail, recipient, and document evidence.

Duplicate-payment identity and row locking prevent the same AP obligation from being paid twice. Payment, applications, AP events, Bank Transaction, Journal, and remittance readiness commit together.

## 24. FIFO Valuation and Landed Cost

`finance.inventory_valuation_layer` uses `valuation_layer_number` as PK and stores Inventory Lot, Product, Receipt/PO/AP Invoice references, acquisition date, original/remaining quantity, purchase cost, freight-in, allowance, other eligible landed cost, total/unit cost, currency, status, and row version.

`finance.valuation_layer_cost_component` PK valuation layer + cost-component code + source sequence; preserves component/source/allocation basis and amount.

`finance.valuation_layer_consumption` PK valuation layer + consumption sequence; stores accepted Delivery/Inventory transaction, quantity, unit cost/value, COGS Journal, reversal, and event time.

Consumption locks oldest eligible FIFO layers deterministically. Physical FEFO Lot selection does not alter FIFO sequence. Layer quantity/value, Inventory quantity, COGS, and GL reconcile.

## 25. Accruals and Financial Estimates

`finance.received_not_invoiced` PK Receipt Number + Receipt Line Number + estimate version; stores accepted quantity/value, landed-cost basis, period, status, accrual/reversal Journals, and later AP Invoice match.

`finance.financial_estimate` uses `financial_estimate_number` as PK and stores estimate type, period, population/scope, method/version, assumptions, amount, preparer/approver, status, Journal, and true-up reference.

`finance.financial_estimate_detail` PK estimate number + detail sequence supports Inventory shrink/spoilage/obsolescence/expiration, credit loss, accrual, and other approved estimates without combining unlike measures in one row.

Received-not-invoiced clearing is idempotent; Supplier Invoice arrival cannot duplicate Inventory cost or liability.

## 26. Bank Accounts and Transactions

`finance.bank_account` uses `bank_account_number` as PK and stores institution/branch Party, purpose, currency, GL Account, restricted status, effective period, authorized use, active status, and protected external-account reference.

`finance.bank_account_authority` PK Bank Account + Principal + authority code + effective-from; stores limits, dual-approval rule, and effective-to.

`finance.bank_transaction` uses `bank_transaction_number` as PK and stores Bank Account, type, source document, transaction/value dates, amount/currency, counterparty, status, statement match, Journal, and reversal.

Sensitive account/routing/credential data is isolated with stricter privileges. Banking-instruction changes require separately verified history.

## 27. Bank Statements and Reconciliation

`finance.bank_statement` PK Bank Account + statement identifier; stores period, beginning/ending balances, received/source data, and status.

`finance.bank_statement_line` PK Bank Account + statement identifier + line number; stores external reference/date/description/amount/balance and match status.

`finance.reconciliation` uses `reconciliation_number` as PK and stores reconciliation type, period/as-of date, subsidiary/control/Bank Account references, book/external balances, difference, preparer/reviewer, status, and completion.

`finance.reconciliation_item` PK reconciliation + item sequence; stores matched/outstanding/deposit-in-transit/fee/interest/stale/duplicate/unexplained item, amount, source, owner, Journal, and resolution.

Completion requires zero explained residual; an unexplained plug is prohibited.

## 28. Cash Forecast and Liquidity

`finance.cash_forecast` uses `cash_forecast_number` as PK and stores as-of time, horizon, version, opening unrestricted/restricted cash, operating-cash requirement, reserve target, available revolving credit, status, preparer/approver, and assumptions.

`finance.cash_forecast_line` PK forecast + line number; stores date/period, inflow/outflow type, source commitment, probability/scenario basis, amount/currency, priority, and included status.

`finance.liquidity_decision` PK forecast + decision sequence; stores projected shortfall/surplus, discount/capital/payment decision, credit-line action, approver, and reason.

Opening policy targets approximately one month of unrestricted operating cash and one additional month of unused revolving-credit capacity.

## 29. Debt and Revolving Credit

`finance.debt_instrument` uses `debt_number` as PK and stores lender, debt type, currency, original/current principal, rate/fixed-index terms, origination/maturity, payment terms, purpose, collateral, status, and approvals.

`finance.debt_schedule_line` PK debt number + due date + schedule sequence; stores opening principal, payment, principal, interest, fee, ending principal, status, and Bank/Journal references.

`finance.debt_covenant` PK debt number + covenant code + effective-from; stores definition, threshold, test frequency, source, status, and effective-to. `finance.debt_covenant_test` PK debt + covenant + test date; stores calculation/evidence/result/approval.

`finance.credit_line_draw` uses `credit_line_draw_number` as PK and stores revolving Debt Number, request/release dates, amount, normal/emergency basis, approvals, Bank Transaction, Journal, reporting/review state, and repayment reference.

Normal draws require owner approval. Emergency draws to prevent overdraft/missed payroll require immediate owner reporting/review.

## 30. Owners, Ownership Interests, and Capital

`finance.owner` uses `owner_number` as PK and links to Person/Party while storing active status and owner role.

`finance.ownership_interest` PK owner number + effective-from; stores effective-to, percentage, interest class, approval reference, and status. Nonoverlap applies; active interests total exactly 100% at each effective boundary.

Opening data records the selected baseline's configurable owner roster and effective percentages, which total exactly 100 percent.

`finance.owner_capital_transaction` uses `capital_transaction_number` as PK and stores Owner, transaction type, cash/property/debt references, amount/value, date, required approval, liquidity/covenant evidence, Journal, and status.

Owner distributions require the approvals configured by effective governance policy and cannot post as operating expense. Owner compensation remains a Payroll event.

## 31. Capital Requests and Fixed Assets

`finance.capital_request` uses `capital_request_number` as PK and stores requesting department, need, alternatives, purchase/financing cost, capacity/service/revenue/savings effects, cash flow, depreciation/interest, risk, useful life, budget state, recommendation, authority requirement, and status.

`finance.capital_request_approval` PK request + decision sequence; records Owner/manager decision, conditions, and time. Material unbudgeted items require at least three distinct active Owners approving.

`finance.fixed_asset` uses `fixed_asset_number` as PK and stores asset class, description, acquisition source/cost, in-service date, facility/location/custodian, useful life, residual value, status, and row version.

`finance.asset_component` PK asset number + component code; stores separable cost, in-service date, life, status, and parent relationship. `finance.asset_financing_link` PK asset + debt + effective-from stores financed amount/share.

The Charlotte facility and six financed trucks are owned Assets separate from related Debt Instruments.

## 32. Depreciation and Asset Lifecycle

`finance.depreciation_schedule` PK asset + component code + schedule version; stores accounting/tax book type, method, basis, useful life, convention, start/end, residual value, approval, and status.

`finance.depreciation_entry` PK asset + component + schedule version + period code; stores amount, accumulated depreciation, carrying value, Journal, and status.

`finance.asset_transfer`, `finance.asset_verification`, `finance.asset_impairment`, and `finance.asset_disposal` use Asset Number plus governed event sequence. They record location/custodian/existence/condition, valuation evidence, approval, proceeds/removal cost, accumulated depreciation, gain/loss, debt effect, and Journal as applicable.

Routine repair/maintenance evidence remains sourced from custodian domains. Capitalization decisions are explicit and do not rewrite maintenance facts.

## 33. Payroll and Tax Interfaces

`finance.payroll_posting` PK Payroll Run Number + posting sequence; stores approved Payroll result version, wages/employer costs/deductions/taxes/net pay totals, liabilities, accounting date, Journal, payment batch, and status.

`finance.payroll_liability` PK payroll liability number; stores liability type/payee, Payroll Run/period, original/open amount, due date, payment, Journal, and status. Detailed employee pay remains in Payroll.

`finance.tax_registration` PK jurisdiction code + tax type code + registration number; stores effective period, filing/payment cadence, accounts, protected evidence, and status.

`finance.tax_obligation` PK registration key + tax period; stores calculation source, original/adjusted liability, due dates, return/payment status, Journal, and row version. `finance.tax_payment` uses `tax_payment_number` as PK and links obligation, Bank Transaction, approval, and evidence.

Filing, payment, and liability settlement remain separate states.

## 34. Close Tasks and Subsidiary Reconciliation

`finance.close_task_definition` PK `close_task_code + effective_from`; stores dependency, responsible role, reviewer, due rule, evidence requirement, and effective-to.

`finance.period_close_task` PK period code + close task code; stores assignee/reviewer, due/completion times, result, evidence, open exception, and status.

`finance.close_task_dependency` PK period + task + predecessor task; cycles are rejected.

Close functions require completed Bank/Cash, AR, AP, Inventory/FIFO, Payroll, Fixed Asset, Debt, Tax, accrual/reserve, Trial Balance, financial-statement, and budget-variance work. Reconciliation differences cannot be forced to zero without source/Journals.

## 35. Financial Statements

`finance.financial_statement` uses `financial_statement_number` as PK and stores statement type, period/as-of date, Account Hierarchy version, currency, accounting basis, version, status, prepared/approved/published times, and superseded statement.

`finance.financial_statement_line` PK statement number + line number; stores hierarchy line, label, amount, comparison amount, source period, and drill-through definition.

Formal published statements are immutable. Correction creates a new version. Required outputs include Trial Balance, Income Statement, Balance Sheet, Cash Flow Statement/Review, equity activity, and supporting schedules. Close verifies Assets = Liabilities + Equity.

## 36. Budgets and Forecasts

`finance.budget` uses `budget_number` as PK and stores fiscal year, type, version, status, preparation/approval dates, and baseline indicator.

`finance.budget_line` PK budget + line number; stores period, Account Number, explicit approved dimensions, amount/currency, assumption, responsible owner, and Capital Plan reference.

`finance.budget_approval` PK budget + decision sequence; records distinct Owner decisions. Approved annual Budget/Capital Plan requires at least three active Owners.

`finance.forecast` uses `forecast_number` as PK; `finance.forecast_line` PK forecast + line number. Forecasts preserve as-of time, horizon, version, assumptions, source commitments, and scenario basis without replacing the approved Budget.

`finance.budget_variance_action` PK budget + period + line number + action sequence; records material variance, explanation, owner, corrective action, due date, and verification.

## 37. Controlled Functions

Required transaction-safe functions include:

- `create_or_revise_gl_account_and_hierarchy(...)`
- `open_close_or_exceptionally_reopen_period(...)`
- `register_and_post_source_event(...) returns journal_entry_number`
- `validate_approve_post_or_reverse_journal(...)`
- `create_or_review_credit_account(...)`
- `calculate_credit_exposure(...)`
- `place_or_release_credit_hold(...)`
- `prepare_finalize_and_post_customer_invoice(...)`
- `approve_and_post_customer_adjustment(...)`
- `record_customer_receipt(...)`
- `apply_or_reverse_ar_amount(...)`
- `open_or_resolve_ar_case(...)`
- `record_and_duplicate_check_ap_invoice(...)`
- `perform_or_resolve_three_way_match(...)`
- `open_or_resolve_supplier_dispute(...)`
- `create_and_approve_payment_proposal(...)`
- `release_or_reverse_supplier_payment(...)`
- `create_consume_or_reverse_fifo_layer(...)`
- `record_rni_or_financial_estimate(...)`
- `record_bank_transaction_or_statement(...)`
- `complete_bank_or_subsidiary_reconciliation(...)`
- `create_cash_forecast_and_liquidity_decision(...)`
- `record_debt_schedule_draw_or_payment(...)`
- `record_owner_interest_or_capital_transaction(...)`
- `approve_capital_request_and_create_asset(...)`
- `post_depreciation_or_asset_event(...)`
- `record_payroll_posting_or_tax_obligation(...)`
- `execute_period_close(...)`
- `publish_financial_statement(...)`
- `approve_budget_or_record_forecast(...)`

Functions validate Principal/authority, lock deterministic natural-key order, check row versions, enforce period/source/subledger rules, use safe `search_path`, and deny `PUBLIC` execution.

## 38. Integrity, Concurrency, and Reconciliation

- Source-event registry prevents duplicate posting under retry/concurrency.
- Journal and subsidiary consequences commit together.
- Posted documents/Journals/applications reject update/delete.
- Closed periods reject ordinary posting.
- Debits equal credits by currency/basis.
- Invoice quantity/value reconciles to accepted Delivery, Sales price, and FIFO COGS evidence.
- AR/AP current balances derive/reconcile from immutable events/applications.
- Receipt/payment applications cannot exceed available/open amounts.
- Disputed + undisputed equals open amount.
- Bank statements/reconciliations explain every difference.
- FIFO layer quantities/values reconcile to Inventory/COGS/GL.
- Debt, asset, depreciation, tax, payroll, owner equity, and Budget controls reconcile.
- Active Ownership Interests total 100%.
- Assets equal Liabilities plus Equity.

## 39. Audit

`audit.finance_event` PK `finance_audit_event_number`; stores event type/time, Principal/process, business/accounting date/period, Account, Customer/Supplier, financial document, source-domain key, before/after controlled status/value, reason, approval, reversal, correlation, and sanitized `jsonb` summary.

Audit events are append-only and supplement, not replace, financial records. Sensitive bank/tax/payroll/owner values are redacted from general audit views while remaining available to specifically authorized Finance audit roles.

## 40. Indexes and Views

Indexes support Account/hierarchy/effective rules; period/status; source-event idempotency; Journal source/date/Account/dimensions; credit exposure/holds; Invoice/AR/AP aging/status; receipt/payment applications; matches/disputes; due/discount dates; FIFO remaining layers; bank statement matching; cash forecast; debt/covenants; ownership; assets/depreciation; tax/payroll liability; close tasks; Budget/variance; and audit correlation.

Required views include:

- `reporting.finance_trial_balance`
- `reporting.finance_income_statement`
- `reporting.finance_balance_sheet`
- `reporting.finance_cash_flow`
- `reporting.finance_posting_exception`
- `reporting.finance_credit_exposure`
- `reporting.finance_ar_aging`
- `reporting.finance_collection_worklist`
- `reporting.finance_ap_aging`
- `reporting.finance_three_way_match_exception`
- `reporting.finance_supplier_payment_due`
- `reporting.finance_discount_capture`
- `reporting.finance_inventory_fifo_reconciliation`
- `reporting.finance_bank_reconciliation_status`
- `reporting.finance_daily_cash_position`
- `reporting.finance_liquidity_forecast`
- `reporting.finance_debt_and_covenant`
- `reporting.finance_owner_equity`
- `reporting.finance_fixed_asset_register`
- `reporting.finance_payroll_tax_liability`
- `reporting.finance_period_close_status`
- `reporting.finance_budget_variance`
- `reporting.finance_cross_domain_reconciliation`

## 41. Privileges and Segregation

`pfd_database_owner` owns objects; `pfd_change_executor` assumes ownership only for approved builds; domain roles include `pfd_credit`, `pfd_billing_ar`, `pfd_ap`, `pfd_cash_management`, `pfd_payroll_finance`, `pfd_accounting`, and `pfd_finance_approver`; `pfd_application` uses approved interfaces; `pfd_reporting` reads approved views; `pfd_support_readonly` receives sanitized diagnostics; `PUBLIC` receives none.

Role/function checks enforce Finance independence from Sales credit release, invoice-entry/payment-release separation, bank-change verification, cash/reconciliation separation, independent material Journal approval, owner-vote counts, Payroll separation, and Close review. Sensitive data uses restricted columns/views and is absent from broad reporting.

## 42. Business Continuity and Simulation

Emergency/offline payment, payroll, credit-line draw, receipt, or Journal activity uses reserved business numbers, explicit authority, actual transaction time, later entry/posting time, source evidence, and independent reconciliation. Recovery idempotency prevents duplicate financial effects.

Simulation uses the same Invoices, Open Items, Receipts, Payments, FIFO Layers, Bank Transactions, Assets, Debt, Journals, periods, Budgets, and statements. Simulation Session may control business time but never appears in operational/accounting primary keys or partitions financial truth.

## 43. Change Order

| Change | Content |
|---|---|
| `0099` | Add Finance business-number sequences and reference data |
| `0100` | Create Chart of Accounts, control rules, hierarchies, dimensions, and currency |
| `0101` | Create accounting periods, status history, and reopening controls |
| `0102` | Create posting rules, source registry, exceptions, batches, Journals, and Lines |
| `0103` | Create Credit Accounts, Customer scope, policies, decisions, exposure, and holds |
| `0104` | Create Customer Invoices, Lines, status history, and delivery posting controls |
| `0105` | Create Customer Adjustments and financial-document correction controls |
| `0106` | Create AR Open Items, immutable events, and balance controls |
| `0107` | Create Customer Receipts, AR Applications, refunds, and reversals |
| `0108` | Create collections, disputes, expected-credit-loss, write-off, and recovery structures |
| `0109` | Create AP Invoices, Lines, duplicate detection, and status controls |
| `0110` | Create three-way Match Results, Receipt links, differences, and exception routing |
| `0111` | Create Supplier Disputes, activities, AP Open Items, and events |
| `0112` | Create Payment Proposals, Items, discount decisions, and approvals |
| `0113` | Create Supplier Payments, Applications, Remittance, and duplicate-payment controls |
| `0114` | Create FIFO Valuation Layers, cost components, consumption, and reconciliation |
| `0115` | Create received-not-invoiced accruals, reserves, estimates, and true-ups |
| `0116` | Create Bank Accounts, authorities, Transactions, and protected banking data |
| `0117` | Create Bank Statements, Lines, Reconciliations, and unresolved-item controls |
| `0118` | Create Cash Forecasts, lines, liquidity targets, and decisions |
| `0119` | Create Debt Instruments, schedules, covenants, tests, draws, and payments |
| `0120` | Create Owners, Ownership Interests, capital transactions, and approval controls |
| `0121` | Create Capital Requests, approvals, Fixed Assets, Components, and financing links |
| `0122` | Create depreciation, transfers, verification, impairment, and disposal structures |
| `0123` | Create Payroll-posting, liability, tax-registration, obligation, and payment interfaces |
| `0124` | Create close tasks/dependencies, subsidiary reconciliation, and Financial Statements |
| `0125` | Create Budgets, Forecasts, variance actions, controlled functions, audit, indexes, and views |
| `0126` | Apply comments, privileges, deferred constraints, and final assertions |

## 44. Verification and Tests

Verification proves contiguous history/checksums through `0126`; required objects/codes; exact natural keys; normalized structures; validated/deferred constraints; source idempotency; balanced/immutable posting; closed-period controls; subsidiary/GL reconciliation; privilege separation; no surrogate keys; and no simulation-session columns.

Disposable tests cover Chart/hierarchy periods; unbalanced Journal rejection; duplicate source retry; reversal; control-account restriction; credit scope/exposure/hold authority; predeparture pending Invoice; accepted/partial/refused delivery posting; Credit Memo; AR receipt/application/unapplied/refund/write-off; AP duplicate/three-way-match/tolerance/dispute; undisputed partial payment; discount decision; duplicate payment; FIFO versus FEFO; landed cost/RNI/estimate true-up; Bank matching/reconciliation; cash targets; normal/emergency credit-line draw; debt principal/interest; configurable opening Owners, 100-percent ownership totals, and configured owner approvals; Asset/depreciation/disposal; Payroll/tax interfaces; Close/reopen; statements; Budget approval/variance; unauthorized access; concurrency; and ordinary-table simulation.

## 45. Acceptance Criteria

The eventual package must build cleanly and incrementally through `0126`, rerun as a no-op, and pass checksum, behavioral, concurrency, reconciliation, and privilege tests. It must demonstrate balanced exactly-once accounting, immutable source-linked history, accurate AR/AP/Inventory/Cash/Asset/Debt/Equity controls, and reliable period close/statements.

## 46. Deferred Configuration

Opening Chart of Accounts/hierarchies/mappings, reporting currency, materiality/tolerances/approval limits, credit methods, bank/debt details, FIFO landed-cost allocations, reserve methods, useful lives/depreciation, tax registrations, close tasks, Budget/Forecast assumptions, and report formats are configuration—not unresolved architecture.

## 47. Next Design Work

Next: **Workforce and Payroll Domain Specification**. Executable Finance and Accounting SQL remains deferred until we leave Design Land.
