# \<business name>

## Business Model and Operating Policies

**Company abbreviation:** PFD  
**Business address:** \<business address>  
**Document date:** September 4, 2026  
**Document purpose:** Authoritative definition of how the business operates and what information technology must support at a high level.

---

## 1. Purpose and Authority

This document defines the business model and operating policies of **\<business name> (PFD)**. It describes the company as a business rather than as a software system.

The document establishes:

- What PFD sells and to whom
- Where and how PFD operates
- How customers, suppliers, inventory, employees, trucks, cash, and accounting are managed
- The rules used to make routine business decisions
- The high-level information capabilities required to support the business

The separate PFD simulation design describes how the business may eventually be represented in software. When a technical design choice conflicts with an operating policy in this document, the business policy should be settled first and the technical design adjusted accordingly.

---

## 2. Company Identity and Business Concept

PFD is a privately held, regional, broadline food-service distributor. It supplies most of the consumable products needed to operate commercial and institutional food-service departments.

PFD competes through:

- Dependable, scheduled delivery
- A broad but controlled product assortment
- Strong customer relationships
- Responsive local service
- Consistent product quality
- Responsible customer credit management
- Reliable supplier relationships
- Accurate order fulfillment and billing
- Disciplined inventory, cash, and cost control

PFD is not intended to compete solely by offering the lowest price. Its value proposition is dependable local service supported by knowledgeable people, appropriate inventory, and sound operations.

---

## 3. Ownership and Governance

PFD has one or more owners recorded in an effective-dated ownership roster. The active ownership interests total exactly 100 percent. Owner count, identity, percentage, and operational responsibilities are approved opening data rather than fixed architecture.

Management responsibility is assigned independently from ownership percentage. The required opening responsibilities include General Management, Sales, Operations and Purchasing, and Finance and Administration; one person may hold more than one compatible responsibility when segregation-of-duties controls remain effective.

### 3.1 Routine authority

Each person with an effective management assignment has authority over routine decisions within that assignment, subject to the approved operating budget, established company policies, internal controls, and applicable laws.

The effectively assigned General Manager has final authority over day-to-day matters that cross departmental boundaries, provided the decision:

- Is within the approved budget
- Does not create new long-term debt outside approved plans
- Does not materially change company strategy
- Is not reserved for owner approval

### 3.2 Reserved matters requiring configured owner approval

The effective governance policy defines the required approval count or percentage for each reserved matter. The threshold must be valid for the active owner roster, require meaningful independent approval, and prevent an affected owner from acting alone on a related-party matter.

- Annual operating budget
- Annual capital-investment plan
- Material unbudgeted capital expenditures
- New loans or material changes to borrowing arrangements
- Purchase, sale, or mortgage of real property
- Entry into a materially new market or territory
- Major changes to the product or service model
- Acquisition or sale of another business
- Changes in ownership
- Owner compensation and distributions
- Appointment or removal of the General Manager

### 3.3 Management practices

PFD prepares an annual operating budget and capital plan. Management reviews actual results against budget monthly. Material unfavorable variances require explanation and a corrective plan.

Company policies should separate authorization, custody of assets, transaction recording, and reconciliation whenever staffing reasonably permits. No person should control an entire high-risk financial process without independent review.

---

## 4. Startup Position and Business Scale

The simulation begins with PFD's grand opening. The owners have supplied sufficient capital to prepare the company for operation and have obtained customer commitments before opening.

On the opening date, PFD has:

- A completed and operational facility
- Necessary warehouse equipment and information systems
- Six delivery trucks
- Initial inventory
- Approved suppliers
- Trained employees
- Established banking and credit arrangements
- Appropriate insurance, permits, and operating procedures
- Eighty committed customer locations

PFD opens as a properly organized startup rather than as an empty shell. There are no inherited customer receivables or supplier payables unless expressly included in the approved opening business data.

### 4.1 Opening operating baseline

| Measure | Opening baseline |
|---|---:|
| Customer locations | 80 |
| Active products/SKUs | Approximately 3,000 |
| Approved suppliers | Approximately 60 |
| Regularly used suppliers | Approximately 40 |
| Delivery trucks | 6 |
| Trucks normally dispatched | 5 |
| Spare trucks | 1 |
| Facility area | Approximately 50,000 square feet |
| Warehouse and operating area | Approximately 45,000 square feet |
| Office and employee area | Approximately 5,000 square feet |
| Normal weekday delivery stops | Approximately 40-45 |

These values are the approved opening baseline. Controlled test copies may vary them without changing the underlying business policies or the continuing operational database.

---

## 5. Market and Service Territory

PFD serves food-service customers within a hub-and-spoke territory centered on the Charlotte facility.

The principal service endpoints are:

- Statesville, North Carolina
- Monroe, North Carolina
- Rock Hill, South Carolina
- Gastonia, North Carolina

The service area includes communities located along reasonably direct routes between the PFD facility and these endpoints. PFD therefore operates in portions of North Carolina and South Carolina.

Expansion beyond this territory requires management review of route time, fleet capacity, delivery economics, customer density, and service reliability. PFD should not accept isolated distant accounts that weaken route economics or service to existing customers unless the account's volume and profitability justify the exception.

---

## 6. Customer Model

PFD primarily serves:

- Restaurants
- Hospitals and healthcare facilities
- Schools
- Correctional institutions
- Hotels

### 6.1 Opening customer mix

| Customer segment | Opening locations | Normal delivery frequency |
|---|---:|---|
| Restaurants | 48 | Three deliveries per week |
| Hotels | 10 | Two deliveries per week |
| Schools | 10 | One or two deliveries per week |
| Hospitals and healthcare facilities | 6 | Three deliveries per week |
| Correctional institutions | 6 | Two deliveries per week |
| **Total** | **80** | Approximately 40-45 weekday stops |

Delivery frequency is the normal planning assumption rather than an absolute entitlement. Individual schedules are established according to route design, customer volume, storage limitations, contract requirements, and service agreements.

### 6.2 Customer ownership

Each customer is assigned to a sales representative. Sales owns the commercial relationship, while Customer Service coordinates routine orders and service issues. Credit decisions remain independent of Sales and are controlled by Finance and Administration.

### 6.3 Customer onboarding

Before the first credit sale, PFD obtains and approves:

- Legal name and billing information
- Delivery locations and receiving hours
- Accounts-payable contacts
- Tax and exemption documentation
- Ownership and credit references where appropriate
- Requested payment terms and credit limit
- Authorized order contacts
- Product, substitution, and delivery preferences
- Contract prices or bid terms, if applicable

New accounts begin with a conservative credit limit. Limits may increase after satisfactory payment and purchasing history.

---

## 7. Product and Service Offering

PFD supplies most consumable items needed to support its customers' food-service operations.

The assortment includes:

- Canned and other shelf-stable foods
- Dry grocery products
- Frozen foods
- Fresh produce
- Refrigerated dairy products
- Eggs and cheese
- Fresh and refrigerated meat
- Deli products
- Paper products
- Disposable food-service supplies
- Related nonfood consumables

PFD does not manufacture food. It purchases finished products for resale and distributes them in the condition and packaging supplied or approved for distribution.

### 7.1 Storage classifications

Every product is assigned an appropriate storage classification:

- Dry/ambient
- Refrigerated
- Frozen
- Controlled produce storage, where required
- Nonfood and chemical segregation, where required

Food products must not be stored or transported in a manner that permits contamination by cleaning chemicals, damaged goods, returned goods, or other incompatible items.

### 7.2 Units of sale

The standard selling unit is the manufacturer's or supplier's full case.

Split-pack sales are available when operationally practical but are discouraged. A split quantity carries a higher per-unit selling price. The price is calculated from the full-case price plus a standard split-pack handling premium. The premium compensates PFD for additional picking labor, open-case control, and the risk of leaving slow-moving partial cases.

PFD does not perform warehouse catch-weight pricing. Products that might otherwise be sold by actual weight are purchased and sold as predefined supplier cases or packs at fixed prices. The warehouse does not weigh individual picked items and transmit a final price to the computer room before invoices are printed.

---

## 8. Pricing and Commercial Policy

PFD maintains standard price lists and may establish customer-specific or contract pricing.

### 8.1 Price construction

Selling prices consider:

- Current and expected replacement cost
- Inbound freight and other landed costs
- Product handling and storage requirements
- Spoilage and shrink risk
- Required gross margin
- Customer volume and service cost
- Competitive conditions
- Contract commitments
- Supplier rebates and allowances when reliably measurable

PFD monitors margin by item, customer, order, route, and customer segment. Sales growth that does not produce an acceptable contribution margin is not treated as healthy growth.

### 8.2 Price authority

- Sales representatives may quote within approved price lists and discount limits.
- The authorized Sales role holder may approve routine customer-specific pricing within the approved margin policy.
- Pricing below the established margin floor requires documented approval from Sales and Finance.
- Material long-term commitments below normal margin expectations require General Management approval.

### 8.3 Split-pack pricing

Split packs use a higher per-unit price rather than a separately stated invoice fee. The standard planning assumption is a 15 percent per-unit handling premium over the equivalent full-case unit price, subject to rounding and product-specific exceptions.

### 8.4 Delivery economics

PFD establishes a normal minimum order of **$500 per delivery**. Orders below the minimum may be:

- Combined with the customer's next scheduled order
- Accepted with a small-order delivery charge
- Approved as a customer-service exception

Emergency or off-schedule delivery is available only when fleet capacity permits and may carry an expedited-delivery charge. Contract terms may supersede standard minimums and fees.

---

## 9. Customer Ordering Policy

Customers place orders through their assigned salesperson, Customer Service, approved electronic transmission, or another authorized order channel.

### 9.1 Standard order timing

- Orders are taken Monday through Friday during office hours.
- The standard cutoff for next-scheduled-day delivery is 4:00 PM.
- Sales and Customer Service use the final office hour to resolve holds, pricing issues, and incomplete orders.
- Friday orders are prepared Sunday night for Monday delivery.
- No routine customer orders are taken Saturday or Sunday.

Orders received after cutoff are assigned to the next available scheduled delivery unless Operations approves an exception.

### 9.2 Standing and recurring orders

PFD may maintain standing order templates for customers with predictable needs. A standing template does not bypass credit, inventory, price, or delivery controls. The customer or assigned salesperson confirms quantities according to the agreed schedule.

### 9.3 Changes and cancellations

Customers may change or cancel an order until it is released to warehouse picking. After release, changes require Customer Service and Operations approval. PFD may charge for special-order products or costs that cannot reasonably be avoided.

---

## 10. Credit, Billing, and Collections

### 10.1 Credit terms

The normal commercial term is **Net 30 days**. Governmental, school, healthcare, or contract accounts may receive Net 45 when customary and approved. New or higher-risk customers may be placed on prepaid, COD, or restricted terms.

Credit limits are based on expected purchases, payment history, available credit information, and PFD's risk tolerance. Finance controls credit approval and credit holds independently of Sales.

### 10.2 Credit holds

An order may be held when:

- The order would materially exceed the approved credit limit
- Required advance payment has not been received
- The customer has seriously overdue invoices
- A payment has been returned
- Finance identifies a material credit concern

Sales may request review but cannot unilaterally override a Finance credit hold. Exceptions require Finance approval and documented business justification.

### 10.3 Invoice timing

Invoices are prepared before truck departure and accompany the route or delivery paperwork. Because PFD does not perform catch-weight pricing, all normal invoice prices and quantities can be established before dispatch.

Delivery shortages, refusals, damages, returns, and other post-departure differences are corrected through a credit memo, debit memo, or supplemental invoice after delivery documentation is reviewed.

Revenue is recognized when control of accepted goods passes to the customer, normally upon delivery. Undelivered or rejected goods are not recognized as completed sales.

### 10.4 Collections

Collections are firm, professional, and relationship-oriented. PFD:

- Sends accurate statements promptly
- Contacts customers shortly after material invoices become overdue
- Records disputes and promises to pay
- Escalates persistent delinquency
- Applies credit holds when warranted
- Maintains an allowance for expected credit losses
- Writes off uncollectible balances only with appropriate approval

Customer disputes are separated from undisputed balances. PFD expects undisputed balances to be paid according to terms.

---

## 11. Inventory Management

PFD operates a perpetual inventory system. Inventory quantities and status are updated by receiving, movement, allocation, picking, shipping, returns, adjustments, and disposition transactions.

### 11.1 Inventory statuses

Inventory may be classified as:

- Available
- Allocated
- In reserve storage
- In a picking slot
- Staged
- Loaded
- On quality hold
- Quarantined
- Damaged
- Returned
- Expired
- Pending disposition

Only available inventory may be allocated to normal customer orders.

### 11.2 Reserve and picking locations

PFD uses separate reserve storage and designated picking slots.

- Full pallets and excess quantities are normally stored in reserve.
- Accessible picking slots supply case and split-pack picking.
- Fast-moving products may use a full pallet as the active picking location.
- Second shift performs planned replenishment before overnight picking.
- Emergency replenishment is permitted during overnight picking.

Replenishment needs are determined from released demand, current pick-slot quantity, case configuration, and a product-specific minimum quantity.

### 11.3 Lot and expiration control

PFD records lot numbers and expiration or best-by dates when supplied for food products, including shelf-stable products. This applies even when the expected shelf life is long.

PFD uses **first-expiring, first-out (FEFO)** physical rotation. When expiration dates are equal, the inventory placed into the picking location earliest is used first.

Multiple lots of the same product may occupy one picking slot when necessary. Picking procedures require one lot to be depleted before moving to the next, except when FEFO, product condition, or management direction requires otherwise.

The warehouse records the date and time each lot or pallet is moved into a picking slot. PFD does not maintain an exact customer-by-customer record of the lot shipped. If a recall occurs, PFD uses receipt records, slot-placement history, inventory movement timing, and product/date customer shipment history to identify the likely exposure window.

### 11.4 Remaining shelf life

Each perishable or date-sensitive product has a minimum remaining shelf-life requirement for normal shipment. Inventory below that minimum is blocked from normal shipment.

Blocked short-dated inventory may be:

- Returned to the supplier when permitted
- Sold at a discount with management authorization and informed customer acceptance
- Donated when safe, lawful, and approved
- Disposed of according to policy

PFD never knowingly ships expired product.

### 11.5 Allocation and shortages

Inventory is normally allocated to released orders in order of scheduled delivery and order release. When supply is insufficient, allocation considers:

1. Safety and contractual obligations
2. Customer priority and service commitments
3. Whether a reasonable approved substitute exists
4. Fair distribution among similarly situated customers
5. Order and route feasibility

No salesperson may reserve scarce inventory informally outside the authorized allocation process.

### 11.6 Substitutions and backorders

Products may be substituted only with an approved equivalent and according to the customer's recorded preferences. Material brand, size, allergen, dietary, or specification differences require customer approval.

For shortages, PFD may:

- Substitute an approved product
- Ship the available quantity and backorder the remainder
- Move the remainder to the next scheduled delivery
- Cancel the unavailable quantity with customer notification

Institutional contract specifications take precedence over general substitution practices.

### 11.7 Cycle counting

PFD conducts routine cycle counts and an annual full physical inventory.

- High-value and fast-moving items are counted most frequently.
- Medium-importance items are counted quarterly.
- Slow-moving, low-value items are counted at least semiannually.
- Sensitive or problem products may be counted more often.

Significant discrepancies require an independent recount and warehouse-manager approval before adjustment. Large or recurring variances are investigated for receiving, picking, spoilage, damage, theft, unit-of-measure, or process problems.

---

## 12. Purchasing and Supplier Management

Purchasing maintains sufficient inventory to meet service objectives without creating unreasonable cash usage, spoilage, or storage pressure.

### 12.1 Replenishment policy

Purchase recommendations consider:

- Current available, allocated, and on-order inventory
- Forecast demand
- Customer commitments and promotions
- Supplier lead time and reliability
- Economic order quantities and case packs
- Minimum order and freight requirements
- Safety stock
- Available storage capacity
- Shelf life and spoilage risk
- Cash requirements

Critical products should have an approved alternate supplier when practical. Sole-source products are identified and reviewed for supply risk.

### 12.2 Supplier approval

Suppliers are approved based on:

- Product quality and food-safety standing
- Pricing and landed cost
- Fill rate
- On-time performance
- Lead time
- Shelf life at receipt
- Damage and rejection history
- Responsiveness to claims
- Payment terms and discounts
- Strategic importance

Supplier performance is reviewed regularly. Good supplier relations are a stated PFD priority.

### 12.3 Purchase authority

Buyers may issue routine purchase orders within approved inventory plans and authority limits. Unusual commitments, purchases outside the approved assortment, or material forward buys require the configured Operations and Purchasing authority. Major commitments outside the budget require General Management and, when material, the configured owner approval.

### 12.4 Supplier discounts and payment behavior

PFD intends to maintain sufficient cash to pay valid obligations promptly. It does not wait until the last possible moment to pay bills merely because additional time is available.

PFD takes legitimate early-payment discounts when the return is worthwhile and adequate cash remains available. Payment timing also considers supplier relations, cash forecasts, and contractual terms.

---

## 13. Receiving and Quality Control

Supplier deliveries normally require scheduled receiving appointments during the Monday-through-Friday first shift. Unscheduled arrivals require warehouse-management approval and are accepted only when dock capacity and staffing permit.

### 13.1 Receiving verification

Before goods are accepted into available inventory, Receiving verifies as applicable:

- Supplier and purchase order
- Product identity
- Quantity and unit of measure
- Packaging and physical condition
- Lot number
- Expiration or best-by date
- Remaining shelf life
- Product and trailer temperature
- Seal or security condition
- Required regulatory or quality documentation

### 13.2 Receiving exceptions

PFD may accept the satisfactory portion of a shipment and reject the affected portion. Shortages, overages, substitutions, damages, temperature problems, and shelf-life problems are documented and communicated to Purchasing and Accounts Payable.

Questionable product is placed on quality hold or in quarantine and is not available for sale until released by authorized management.

### 13.3 Accounts-payable matching

Supplier invoices require a three-way match among:

- Purchase order
- Receiving record
- Supplier invoice

Differences are reviewed cooperatively with the supplier. PFD aims to resolve discrepancies before the due date. The undisputed amount is paid on time. If the disputed portion remains unresolved, PFD temporarily holds only that portion while continuing to work toward a documented resolution acceptable to both parties.

---

## 14. Warehouse Fulfillment

Warehouse activity follows the established weekly schedule:

- First shift, Monday-Friday: receiving, putaway, inventory control, and related daytime activity
- Second shift, Sunday-Thursday: preparation, replenishment, early picking, staging, and early loading
- Third shift, Sunday-Thursday: primary picking, staging, loading, and dispatch preparation
- Friday second and third shifts: closed
- Saturday: closed
- Sunday first shift: closed

### 14.1 Order release

An order is released to the warehouse only after:

- Customer and delivery information are valid
- Credit requirements are satisfied
- Prices are established
- Inventory allocation is completed
- Route and delivery date are assigned

### 14.2 Picking and checking

Picking instructions identify product, unit of measure, quantity, storage zone, location, and applicable lot-selection rule. Controlled items, split packs, and high-error products may require an independent check.

The warehouse records shortages, substitutions, damage, and other exceptions before loading. No undocumented product may be added to a truck.

### 14.3 Staging and loading

Orders are staged by route and stop sequence while maintaining temperature separation. Loading considers:

- Stop order
- Product temperature
- Weight distribution
- Product fragility
- Security
- Driver access at delivery

The completed load is reconciled to route documents before truck departure.

---

## 15. Transportation and Delivery

PFD owns six financed multi-temperature delivery trucks. Five are normally dispatched, and one is maintained as a spare for breakdowns, planned maintenance, and peak volume.

Each truck can carry ambient, refrigerated, and frozen products in appropriately controlled compartments.

### 15.1 Route model

PFD uses stable geographic route patterns for customer familiarity and planning, with daily adjustments for order volume, delivery windows, vehicle capacity, traffic, and exceptions.

Routes should normally remain within the defined service territory. A route may not be overloaded merely to avoid using the spare truck or authorizing an additional trip.

### 15.2 Delivery execution

Drivers receive route documents and invoices before departure. At each stop, the driver:

- Confirms the customer and delivery location
- Delivers according to receiving requirements
- Protects temperature-controlled products
- Records delivered quantities and exceptions
- Obtains proof of delivery
- Returns refused, damaged, or undelivered products according to procedure

Drivers do not independently promise credits or alter customer prices. They document the condition and reason so Customer Service can resolve the matter promptly.

### 15.3 Vehicle control

PFD maintains preventive-maintenance schedules, inspection records, temperature-control records, fuel usage, mileage, capacity, insurance, and driver assignments. The spare truck protects customer service but is not a substitute for timely fleet maintenance.

---

## 16. Returns, Credits, and Customer Service

Customer Service owns routine coordination of delivery exceptions, shortages, substitutions, complaints, returns, and credits, working with Sales, Warehouse, Transportation, and Finance.

### 16.1 Return policy

Returns require a documented reason and authorization except when the driver records an immediate delivery refusal.

Returned products are not placed directly into available inventory. They are inspected and assigned an appropriate disposition:

- Return to available inventory when sealed, safe, traceable, temperature-compliant, and otherwise acceptable
- Quality hold or quarantine
- Return to supplier
- Donation when approved
- Disposal

Temperature-controlled goods that have left PFD's control are presumed unsuitable for resale unless authorized personnel can establish that product integrity was maintained.

### 16.2 Credit policy

Credits must reference the original invoice or delivery and require an approved reason code. Material or unusual credits require management approval. Finance reviews credit trends for product, picker, driver, route, salesperson, and customer patterns.

---

## 17. Food Safety, Sanitation, and Recall Readiness

PFD maintains documented practices for:

- Supplier approval
- Receiving inspection
- Temperature control
- Product segregation
- Lot and expiration recording
- FEFO rotation
- Cleaning and sanitation
- Pest control
- Employee hygiene and training
- Damaged-product handling
- Quality holds and quarantine
- Product withdrawal and recall response
- Record retention

PFD appoints an authorized food-safety leader and backup. A suspected unsafe product is immediately placed on hold. Safety takes priority over sales, inventory availability, and avoidance of loss.

Because PFD does not record the exact outbound lot delivered to each customer, recall investigation uses the best available exposure window developed from supplier receipt, lot placement, location movement, picking timing, remaining inventory, and customer shipment history. This limitation is recognized explicitly and should be reviewed periodically as the business grows.

---

## 18. Organization and Staffing

PFD begins with approximately **45-50 employees, including any owners who also hold Employee roles**. Exact staffing and the number of owner-employees may vary with the selected opening baseline and approved operating plan.

The opening organization includes:

- Four owner-managers
- Sales representatives
- Customer Service and Order Entry
- Buyers and inventory planning
- Warehouse management and shift supervision
- Receiving and putaway employees
- Replenishment, picking, staging, and loading employees
- Transportation supervision and dispatch
- Drivers
- Finance, Accounts Receivable, Accounts Payable, and payroll support
- Human Resources and general administration
- Facility maintenance and sanitation
- Information-technology and computer-operations support, whether staffed internally or supplemented by outside service

### 18.1 Staffing principles

- Staffing follows expected workload by day and shift.
- Employee absences reduce real operating capacity.
- Cross-training is used for critical roles.
- Overtime requires approval except when needed to protect safety or complete an active delivery cycle.
- Temporary labor may supplement peaks but does not replace trained supervision.
- Drivers and employees performing regulated or safety-sensitive work must remain properly qualified.

### 18.2 Payroll and benefits

Hourly employees are paid biweekly. Salaried employees and owners on payroll are paid biweekly or semimonthly according to the adopted payroll calendar. Time, overtime, paid leave, deductions, employer taxes, and benefits are recorded and reconciled.

Owner distributions are separate from payroll and require appropriate authorization and accounting treatment.

---

## 19. Accounting Policies

PFD maintains its books on the accrual basis in accordance with generally accepted accounting principles appropriate to a privately held business.

### 19.1 Core policies

- A perpetual inventory system is used.
- Inventory is costed using FIFO; physical product rotation uses FEFO.
- Revenue is recognized upon completed, accepted delivery.
- Cost of goods sold is recognized with the related revenue.
- Freight-in and other appropriate acquisition costs are included in landed inventory cost.
- Customer credits and returns reduce revenue in the appropriate period.
- Expected credit losses, inventory shrink, spoilage, and obsolescence are estimated and recorded.
- Fixed assets are capitalized and depreciated over reasonable useful lives.
- Repairs and routine maintenance are expensed unless they materially extend useful life or capacity.
- Interest is recorded separately from operating expense.
- Owner capital contributions and distributions are not revenue or operating expense.
- Accounts are reconciled monthly.
- The accounting equation must remain in balance.

### 19.2 Period close

PFD uses calendar months and a calendar fiscal year. The monthly close includes:

- Cash and bank reconciliation
- AR and AP reconciliation
- Inventory reconciliation and reserve review
- Accrued payroll and other liabilities
- Fixed-asset and depreciation entries
- Debt and interest reconciliation
- Revenue, gross-margin, and expense review
- Trial balance
- Income statement
- Balance sheet
- Cash-flow review
- Budget comparison

### 19.3 Control of journal entries

Routine entries may be generated from approved business transactions. Manual journal entries require documentation and approval independent of the preparer when material. Entries directly affecting cash, inventory, receivables, payables, or owner equity receive particular scrutiny.

---

## 20. Financing, Cash, and Capital Investment

The owners intend to capitalize PFD adequately and maintain enough cash to meet obligations promptly, take worthwhile discounts, and avoid crisis-driven decisions.

### 20.1 Facility and fleet

- PFD owns the Charlotte facility using commercial real-estate financing.
- PFD owns its six trucks using commercial vehicle financing.
- Financing is used to preserve working capital rather than because the owners lack initial capital.

### 20.2 Liquidity policy

PFD targets unrestricted cash equal to approximately one month of normal operating cash requirements.

PFD also maintains an unused revolving line of credit with a limit approximately equal to one additional month of normal operating cash requirements.

The line of credit is a contingency and seasonal working-capital tool, not a permanent substitute for profitable operations. A normal draw requires owner approval. An emergency automatic draw may prevent an overdraft or missed payroll, but it must be reported immediately and reviewed by the owners.

### 20.3 Cash priorities

Available cash is prioritized as follows:

1. Payroll, taxes, and safety-critical obligations
2. Valid supplier obligations
3. Debt service, insurance, utilities, and essential operating expenses
4. Inventory required for committed customer demand
5. Approved capital investment
6. Discretionary spending and owner distributions

Owner distributions are made only when PFD remains adequately capitalized, loan requirements are satisfied, and the cash reserve is protected.

### 20.4 Capital decisions

Capital proposals identify:

- Business need
- Purchase and financing cost
- Capacity or service benefit
- Operating savings or revenue effect
- Cash-flow effect
- Depreciation and interest
- Risks and alternatives
- Expected useful life

PFD does not approve capital projects solely because cash is available.

---

## 21. Performance Objectives and Management Measures

PFD's primary objective is to build a financially sound company that earns customer and supplier trust.

Management balances growth, service, profitability, and liquidity. No single measure is allowed to dominate the business at the expense of the others.

### 21.1 Core measures

- Sales and sales growth
- Gross profit dollars and gross-margin percentage
- Contribution by customer, product, segment, and route
- Order fill rate
- On-time delivery rate
- Picking and delivery accuracy
- Customer credits and returns
- Inventory turnover
- Spoilage, expiration, damage, and shrink
- Warehouse labor productivity
- Truck utilization and cost per route
- Supplier fill rate and on-time performance
- AR aging and days sales outstanding
- AP aging and discount capture
- Cash balance and credit-line usage
- Operating income
- Return on owner equity
- Safety and food-quality incidents

### 21.2 Management cadence

- Daily: orders, warehouse completion, routes, exceptions, cash-sensitive events
- Weekly: sales, fill rate, labor, inventory shortages, supplier issues, delivery performance, collections
- Monthly: financial statements, budget variance, cash forecast, customer and product profitability, KPI review
- Annually: strategy, budget, capital plan, insurance, compensation, supplier and customer concentration, capacity

---

## 22. High-Level Business-to-IT Capability Map

Information technology supports and records the business; it does not replace management accountability.

| Business capability | Information support required |
|---|---|
| Customer and sales management | Customer master, contacts, locations, salesperson assignment, terms, preferences, contracts, activity, and sales history |
| Pricing | Standard and customer-specific prices, effective dates, discounts, split-pack premiums, margin controls, and approval history |
| Order management | Order capture, cutoff control, standing orders, validation, changes, holds, release, status, and exception handling |
| Credit and AR | Credit limits, terms, holds, invoices, receipts, applications, disputes, aging, collections, and expected credit-loss information |
| Product management | Product master, category, units of measure, case pack, storage class, supplier relationships, shelf-life rules, substitutes, cost, and price |
| Inventory management | Quantity by location and status, allocation, reserve and pick slots, lot and expiration information, movement history, FEFO guidance, and adjustments |
| Warehouse operations | Receiving, putaway, replenishment, picking, staging, loading, labor activity, capacity, and exception records |
| Purchasing | Forecasts, reorder needs, supplier selection, purchase orders, approvals, open commitments, costs, lead times, and supplier performance |
| Quality and food safety | Receiving checks, temperatures, holds, quarantine, damage, expiration, sanitation records, complaints, and recall investigation |
| Transportation | Trucks, compartments, maintenance, capacity, drivers, routes, stops, delivery windows, dispatch, proof of delivery, and exceptions |
| Supplier AP | Supplier master, invoice capture, three-way match, disputes, payment scheduling, discounts, credits, and remittance history |
| Returns and credits | Return authorization, inspection, disposition, original-sale linkage, reason codes, credits, and trend reporting |
| General ledger | Controlled journal generation, chart of accounts, periods, reconciliations, trial balance, and financial statements |
| Cash and financing | Bank activity, cash forecast, debt schedules, line-of-credit availability, interest, approvals, and covenant monitoring |
| Payroll and HR | Employee master, roles, schedules, attendance, time, overtime, compensation, leave, payroll, benefits, training, and qualifications |
| Fixed assets | Asset acquisition, location, custodian, cost, financing, maintenance, useful life, depreciation, and disposal |
| Management reporting | Daily operations, weekly performance, financial statements, budget comparison, KPI trends, alerts, and period comparisons |
| Internal control and audit | User authority, approvals, segregation of duties, transaction history, change history, reconciliations, and exception reporting |
| Business continuity | Data backup, recovery, controlled restart, document retention, equipment contingency, and operating procedures for system outages |

### 22.1 System-of-record principle

Each key business fact has one authoritative source. Other functions may use that information but should not create independent conflicting versions. Examples include:

- Finance owns customer credit status.
- Sales owns commercial customer assignments and approved selling arrangements.
- Operations owns physical inventory location and warehouse status.
- Purchasing owns supplier ordering commitments.
- Receiving owns accepted quantities and receiving exceptions.
- Transportation owns dispatch and delivery results.
- Accounting owns posted financial balances and financial periods.
- Human Resources owns employee status and employment information.

### 22.2 Transaction integration principle

Operational events must carry their financial and management consequences through the business. For example, an accepted customer delivery affects sales, inventory, cost of goods sold, accounts receivable, route performance, customer history, and management reporting. PFD should not require unrelated departments to recreate the same transaction independently.

### 22.3 Exception-first management

Routine valid transactions should flow according to approved policy. Management attention should be directed to exceptions such as:

- Credit holds
- Price or margin exceptions
- Inventory shortages
- Late or incomplete picks
- Receiving discrepancies
- Temperature or quality failures
- Late deliveries
- Customer refusals
- Unmatched supplier invoices
- Overdue receivables
- Inventory variances
- Cash shortfalls

---

## 23. Business Continuity and Operational Resilience

PFD maintains practical plans for:

- Information-system outage
- Power failure
- Refrigeration or freezer failure
- Truck breakdown
- Severe weather
- Supplier disruption
- Labor shortage or high absenteeism
- Product recall
- Cash or banking interruption
- Facility access problem

The spare truck, cash reserve, line of credit, approved alternate suppliers, cross-trained employees, documented procedures, and system backups are deliberate resilience measures.

During a computer outage, PFD may continue essential receiving, warehouse, and delivery work using controlled manual documents. All manual transactions are entered and reconciled when systems return to service.

---

## 24. Configurable Operating Assumptions

The following values may change over time through normal business activity, approved planning, or controlled testing without changing PFD's core business identity:

- Opening cash and owner capital amounts
- Facility and truck acquisition cost
- Loan rates and terms
- Product-level demand
- Customer order size
- Selling prices and supplier costs
- Employee wage and salary levels
- Fuel and utility cost
- Supplier lead time and reliability
- Customer payment behavior
- Absenteeism and turnover
- Damage, spoilage, and breakdown frequency
- Economic growth or recession

The continuing simulation uses the same operational records and accounting books from one simulated day or week to the next. Approved changes are effective-dated or recorded through ordinary business transactions. Deliberate stress testing, when desired, uses a separately restored test copy and does not partition or overwrite the continuing business database.

---

## 25. Decisions Established by This Document

This document completes the high-level definition of PFD's normal business model. Detailed product records, customer records, employee rosters, supplier records, route assignments, account balances, and transaction volumes belong in subsequent master-data and opening-state specifications.

The next design layer should translate these policies into a **Business-to-IT Capability Specification** identifying required information, ownership, inputs, outputs, controls, dependencies, and reports for each business function. It should remain technology-neutral before file formats, classes, or program modules are designed.
