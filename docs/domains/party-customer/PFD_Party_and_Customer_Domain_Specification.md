# \<business name>
# Party and Customer Domain Specification

**Document version:** 1.0  
**Date:** September 4, 2026  
**Status:** Design baseline for review and database-build planning  
**Depends on:** PFD Business-to-IT Capability Specification; PFD Persistent Data Architecture and File Standards Specification; PFD PostgreSQL Core Build

---

## 1. Purpose

This specification defines how \<business name> (PFD) identifies organizations and people, establishes commercial customer accounts, records customer locations and contacts, determines delivery-service eligibility, and maintains the business information required to sell and deliver food-service supplies.

This is a business and logical-data specification. It defines what the domain must do and the information it must preserve. Physical PostgreSQL tables, indexes, functions, and deployment scripts are the next implementation step.

## 2. Business Context

PFD operates from:

**\<business address>**

The normal service territory follows practical delivery corridors from the PFD facility toward these endpoints:

- Statesville, North Carolina
- Monroe, North Carolina
- Rock Hill, South Carolina
- Gastonia, North Carolina

The service area includes customers located along reasonably direct routes between PFD and those endpoints. It is a spoke-based operating territory, not a simple radius around the warehouse.

PFD primarily serves:

- Restaurants
- Hospitals
- Schools
- Correctional institutions
- Hotels

PFD sells canned goods, frozen goods, fresh produce, paper products, and most other consumable items required to operate institutional or commercial food service.

## 3. Scope

This domain owns:

- Organizations and people known to PFD
- Customer accounts and customer numbers
- Customer classifications and account status
- Customer operating, billing, and delivery locations
- Postal addresses and their history
- Contact methods and customer contact responsibilities
- Customer account relationships and centralized billing arrangements
- Payment-term assignment
- Taxability and exemption-certificate records
- Service-area eligibility and service exceptions
- Standing delivery requirements and receiving restrictions
- Customer onboarding, activation, hold, suspension, and inactivation
- Customer-domain audit and change history

This domain does not own:

- Product definitions or customer-specific item pricing
- Sales orders, allocations, shipments, invoices, or payments
- Credit-limit calculations, receivable balances, or collection activity
- Route construction, truck assignments, or driver dispatch
- General Ledger accounts or accounting entries
- Supplier, employee, or owner-specific details beyond reusable Party identity
- Authentication credentials

Those capabilities reference Party and Customer records but remain in their respective domains.

## 4. Governing Design Decisions

1. Customer data is permanent operational data. A simulation uses and updates the same customer tables used by normal business operation.
2. Simulation-session identifiers are not stored in Customer Master or other authoritative customer records.
3. Every customer has a stable PFD customer number that is the primary key of Customer Master.
4. No surrogate, identity, serial, UUID, or otherwise meaningless substitute primary key is permitted.
5. Assigned business numbers are valid business identifiers when they are visible, stable, controlled, and used operationally.
6. A customer account represents a commercial relationship. It is distinct from the legal organization and from each physical delivery location.
7. One legal organization may have multiple customer accounts when separate billing, credit, ownership, or operating arrangements require them.
8. One customer account may have multiple delivery locations.
9. Historical records are normally inactivated or effective-dated, not physically deleted.
10. Addresses, contacts, tax status, payment terms, service eligibility, and operating requirements retain effective history.
11. Customer classification supports reporting and policy but does not replace the Customer Master.
12. Service eligibility is based on managed delivery corridors and operating feasibility, not only mileage or postal code.
13. Split-pack service may be offered, but the customer record must not imply that it is the preferred fulfillment method.
14. Catch-weight pricing is outside the operating model. Customer requirements cannot create a warehouse weigh-and-price process.

## 5. Domain Model Overview

The model separates four concepts that are often incorrectly combined:

| Concept | Meaning |
|---|---|
| Party | An organization or person known to PFD. |
| Customer account | The commercial relationship under which PFD accepts orders, extends terms, invoices, and manages status. |
| Customer location | A named operating site associated with a customer account. |
| Address | An effective-dated postal or physical address used by a Party or customer location. |

This separation prevents duplicated organization data, permits multiple locations and billing structures, and supports future supplier, employee, carrier, and owner roles without copying identity information.

## 6. Party Management

### 6.1 Party

A Party is either an organization or a person. Each Party receives a permanent `party_number` from the controlled Core number-allocation service.

The Party record contains only shared identity and governance information:

- Party number
- Party type: organization or person
- Display name
- Active status
- Effective dates
- Audit responsibility and timestamps

Authentication usernames, passwords, tokens, and security credentials are not Party attributes.

### 6.2 Organization

The Organization subtype records:

- Party number
- Legal name
- Trade or doing-business-as name
- Organization form when known
- Federal tax identifier only when required and appropriately protected
- State of organization when relevant
- Active and effective status

Legal name and trade name are not keys because names can change and are not reliably unique.

### 6.3 Person

The Person subtype records business-appropriate identity:

- Party number
- Given name
- Middle name or initial
- Family name
- Preferred business name
- Suffix when applicable
- Active and effective status

Sensitive personal information not required for the commercial relationship is excluded.

### 6.4 Party Relationships

Effective-dated Party relationships support facts such as:

- Person works for organization
- Organization owns or operates another organization
- Person is an authorized contact for organization
- Organization is a parent, division, or affiliated entity

Each relationship identifies the two Party numbers, relationship type, effective period, and responsible Principal. Circular relationships that are invalid for the selected relationship type must be rejected.

## 7. Customer Account

### 7.1 Customer Master

Customer Master is the authoritative commercial-account record. Its primary key is `customer_number`.

Required information includes:

- Customer number
- Party number of the responsible organization
- Customer name used operationally
- Primary customer segment
- Account status
- Account-opening date
- Default payment-terms code
- Default currency code, initially USD
- Default order method when established
- Tax status
- Credit-account reference when credit is established
- Sales responsibility reference
- Service-area status
- Effective and audit information

The customer number is allocated only after onboarding approval. A prospect can exist as a Party before a Customer Master record is created.

### 7.2 Customer Number

The initial format is a controlled numeric customer number displayed with leading zeros. The recommended starting format is six digits, for example `000125`.

Rules:

- The number is assigned by the Core number-allocation service.
- It is never derived with `MAX(customer_number) + 1`.
- It is never reused, even after an account is inactivated.
- Its display format may be extended if capacity requires, but an assigned value never changes.
- Imports from a predecessor system may preserve a documented legacy number only when uniqueness and format are validated before activation.

### 7.3 Customer Segments

The initial controlled segments are:

| Code | Segment |
|---|---|
| `RESTAURANT` | Restaurant or restaurant group |
| `HOSPITAL` | Hospital or healthcare food service |
| `SCHOOL` | Public, private, or postsecondary school food service |
| `CORRECTIONAL_INSTITUTION` | Government or contracted correctional food service |
| `HOTEL` | Hotel or hospitality food service |
| `OTHER_FOOD_SERVICE` | Approved food-service customer not covered above |

Each customer has one primary segment. Additional effective-dated classifications may be assigned for reporting without changing the primary segment.

Useful secondary classifications include independent restaurant, restaurant group, acute-care hospital, long-term care, public school district, private school, college or university, state correctional institution, local detention facility, limited-service hotel, and full-service hotel.

### 7.4 Account Relationships

Customer-account relationships support:

- Parent and child accounts
- Central billing
- Central purchasing with local delivery
- Buying-group affiliation
- Shared credit control

A child account remains independently identifiable. A parent relationship does not silently combine orders, invoices, receivables, tax treatment, or delivery instructions. Each shared behavior must be explicitly authorized and effective-dated.

## 8. Customer Locations and Addresses

### 8.1 Customer Location

A customer location is a stable named site within a customer account. Its logical primary key is:

`customer_number + customer_location_code`

Examples of location codes are `MAIN`, `KITCHEN`, `NORTH_CAMPUS`, or an established customer site number. The code is assigned once and is not reused within that customer account.

Location types include:

- Headquarters
- Billing office
- Delivery site
- Food-service kitchen
- Administrative office
- Central receiving facility

A location can serve more than one purpose.

### 8.2 Address History

An address is stored separately from the customer location so changes can be effective-dated and shared address usage can be controlled. An address record preserves:

- Address number
- Address lines
- City
- State or province code
- Postal code
- Country code
- County when known
- Validation status and validation date
- Geographic coordinates and geocoding confidence when obtained
- Effective period

The system keeps the address as supplied and, when available, a standardized form. Automated standardization must not silently replace an unverified customer-provided address.

The same current address may be designated for physical delivery, billing correspondence, statement delivery, or administrative correspondence through explicit address-use records.

### 8.3 Delivery Address Controls

An order may ship only to an active delivery location that:

- has a current physical address;
- is approved for delivery service or has an active exception;
- has no blocking location status;
- has required receiving instructions; and
- is valid for the requested delivery date.

An address change affecting an open order must be reviewed. It does not silently redirect an already released shipment.

## 9. Contacts and Communication

Contact methods are effective-dated and classified as business email, business telephone, mobile telephone, fax, or approved electronic-order endpoint.

Customer contact responsibilities include:

- Ordering
- Purchasing
- Receiving
- Accounts payable
- Billing inquiry
- Credit and collections
- Food-safety or recall contact
- Management escalation

A contact assignment identifies the customer account and, when appropriate, a specific customer location. Each active customer should have at least:

- one ordering or purchasing contact;
- one receiving contact for every delivery site; and
- one accounts-payable or billing contact for credit customers.

The system records communication preference and permission but does not assume marketing consent from an operational contact relationship.

## 10. Service-Area Eligibility

### 10.1 Service Lanes

The initial managed service lanes are:

| Code | Endpoint |
|---|---|
| `STATESVILLE` | Statesville, North Carolina |
| `MONROE` | Monroe, North Carolina |
| `ROCK_HILL` | Rock Hill, South Carolina |
| `GASTONIA` | Gastonia, North Carolina |

The PFD warehouse is the hub. A service lane represents the practical corridor from the hub to its endpoint and the communities reasonably served along that route.

### 10.2 Eligibility Decision

Every proposed delivery location receives one of these statuses:

- `ELIGIBLE` — normally serviceable on an established lane
- `CONDITIONAL` — serviceable only on specified days, order sizes, or arrangements
- `EXCEPTION_APPROVED` — outside the normal lane but approved for a defined period
- `NOT_ELIGIBLE` — not presently serviceable
- `PENDING_REVIEW` — not yet decided

Eligibility considers:

- Additional travel time and route deviation
- Road and vehicle access
- Delivery-window feasibility
- Expected order frequency and volume
- Temperature-control requirements
- Unloading constraints
- Existing lane capacity
- Profitability and strategic value

Postal code, straight-line distance, or geocoding alone cannot approve a location. Transportation or Operations must approve the service decision.

### 10.3 Service Exceptions

An exception requires a reason, approver, effective start, expiration date, and any minimum-order or delivery-day conditions. Expired exceptions do not remain effective by default.

## 11. Standing Delivery and Receiving Requirements

Each delivery location can maintain effective-dated requirements for:

- Receiving days and time windows
- Required appointment scheduling
- Advance notice
- Dock, liftgate, pallet-jack, or hand-unload requirements
- Vehicle size or access limitations
- Entrance, gate, security, and check-in procedures
- Correctional-institution clearance procedures
- School arrival restrictions
- Hospital dock and sanitation requirements
- Hotel or restaurant street-access restrictions
- Frozen, refrigerated, and ambient receiving capability
- Proof-of-delivery requirements
- Whether split-pack fulfillment is accepted

These are standing instructions. Order- or shipment-specific instructions belong to Sales or Transportation and must preserve the applicable standing requirement snapshot.

Appointments are controlled commitments. PFD and customer receiving appointments must be scheduled; trucks and receiving activity cannot simply arrive whenever convenient.

## 12. Payment Terms, Credit, and Billing

### 12.1 Payment Terms

Customer Master carries a default payment-terms code from controlled reference data. Initial supported terms should include:

- Payment before delivery
- Due on receipt
- Net 7 days
- Net 15 days
- Net 30 days

Terms longer than Net 30 require Finance approval. Order-level deviations require explicit authority and do not change the customer default automatically.

### 12.2 Credit Boundary

The Customer domain records the link to the applicable Credit Account. The Credit domain owns:

- Credit limit
- Current exposure
- Aging
- Holds caused by credit conditions
- Credit exceptions
- Collection status

Customer status and credit status remain distinct. An otherwise active customer may be on credit hold while still permitted to place prepaid orders if Finance policy allows.

### 12.3 Billing Arrangements

The domain supports:

- Location-level billing
- Central billing to a parent customer
- Statements by account
- Purchase-order-required customers
- Customer-required invoice references
- Electronic or paper invoice preference

The invoice captures the billing arrangement in effect when issued. Later customer-master changes do not rewrite historical invoices.

## 13. Tax Status

Every active customer account has an explicit tax status:

- Taxable
- Exempt with current documentation
- Partially exempt or jurisdiction-dependent
- Pending review

Tax-exemption records include:

- Customer number
- Jurisdiction
- Exemption type
- Certificate number
- Issue and expiration dates when applicable
- Verification status and verification date
- Document reference and integrity hash
- Responsible Finance Principal

The database stores document metadata and a controlled document reference. The authoritative certificate image should be kept in approved document storage, not embedded indiscriminately in Customer Master.

An expired or unverified certificate cannot silently support tax exemption. Tax calculation itself belongs to Sales and Finance.

## 14. Customer Lifecycle

### 14.1 Statuses

| Status | Meaning |
|---|---|
| `PENDING_APPROVAL` | Customer record is being reviewed and cannot receive normal orders. |
| `ACTIVE` | Customer is approved for permitted ordering and delivery. |
| `CREDIT_HOLD` | Credit ordering is blocked; prepaid activity may be allowed by policy. |
| `OPERATIONAL_HOLD` | Ordering or delivery is blocked for a non-credit reason. |
| `SUSPENDED` | All new commercial activity is blocked temporarily. |
| `INACTIVE` | Relationship is closed; history remains available. |

Prospects are Parties, not incomplete Customer Master rows. Customer Master begins at `PENDING_APPROVAL` when commercial onboarding formally starts.

### 14.2 Activation Requirements

Activation requires:

- Approved organization identity
- Assigned customer number
- Primary segment
- At least one current customer location
- Current billing address
- At least one approved delivery location or an explicitly non-delivery account type
- Payment terms
- Tax status
- Required billing and receiving contacts
- Service eligibility decision
- Credit decision when terms extend credit
- Responsible sales assignment

### 14.3 Inactivation

Inactivation requires an effective date and reason. It does not delete the customer, locations, contacts, orders, invoices, receivables, payments, or accounting history. Open obligations must be resolved or formally transferred before final closure.

## 15. Logical Data Structures

The following structures are the expected normalized model. Names are logical and may be refined for consistent PostgreSQL naming during physical design.

| Logical structure | Primary key | Purpose |
|---|---|---|
| Party | `party_number` | Shared identity of an organization or person. |
| Organization | `party_number` | Organization-specific identity. |
| Person | `party_number` | Person-specific business identity. |
| Party Relationship | `from_party_number + to_party_number + relationship_type_code + effective_from` | Effective-dated relationship between Parties. |
| Party Address Use | `party_number + address_number + address_use_code + effective_from` | Effective-dated association of a Party and address. |
| Address | `address_number + effective_from` | Effective-dated address history. |
| Contact Method | `party_number + contact_method_code + effective_from` | Effective-dated telephone, email, fax, or electronic endpoint. |
| Customer | `customer_number` | Authoritative commercial account. |
| Customer Classification | `customer_number + classification_type_code + classification_code + effective_from` | Additional effective-dated segmentation. |
| Customer Relationship | `parent_customer_number + child_customer_number + relationship_type_code + effective_from` | Parent, billing, purchasing, or credit relationship. |
| Customer Location | `customer_number + customer_location_code` | Stable operating, billing, or delivery site. |
| Customer Location Address | `customer_number + customer_location_code + address_number + address_use_code + effective_from` | Effective-dated location/address use. |
| Customer Contact Assignment | `customer_number + contact_role_code + party_number + effective_from` | Account-level contact responsibility. |
| Location Contact Assignment | `customer_number + customer_location_code + contact_role_code + party_number + effective_from` | Location-specific contact responsibility. |
| Customer Service Eligibility | `customer_number + customer_location_code + effective_from` | Service lane, eligibility status, conditions, and approval. |
| Location Receiving Window | `customer_number + customer_location_code + weekday_code + window_sequence + effective_from` | Regular allowable receiving window. |
| Location Requirement | `customer_number + customer_location_code + requirement_code + effective_from` | Standing delivery and receiving requirement. |
| Customer Payment Terms | `customer_number + effective_from` | Effective history of approved default terms. |
| Customer Tax Status | `customer_number + jurisdiction_code + effective_from` | Effective tax treatment by jurisdiction. |
| Tax Exemption Certificate | `customer_number + jurisdiction_code + certificate_number` | Certificate metadata and verification. |
| Customer Status History | `customer_number + effective_from` | Effective history of account status and reason. |

No logical structure above requires an artificial technical identifier.

## 16. Normalization and Integrity Rules

The physical model must follow standard relational normalization, normally through Third Normal Form.

Required controls include:

- Organization-only attributes appear in Organization, not Party or Customer.
- Location-specific instructions appear at the location, not repeated on Customer Master.
- Reference descriptions are stored once in controlled reference tables.
- Effective periods for the same business fact cannot overlap.
- An effective-through timestamp must be later than effective-from.
- Only one current default payment-term assignment is allowed per customer.
- Only one current primary segment is allowed per customer.
- Only one current primary billing arrangement is allowed per customer.
- Every Customer references an existing Organization Party.
- Every Customer Location references an existing Customer.
- Every contact assignment references an active Person Party and an active contact method appropriate to the assignment.
- Inactive reference values remain valid for historical rows but cannot be selected for new effective records.
- State, country, currency, weekday, status, classification, relationship, contact-role, address-use, and requirement codes use governed references.
- All monetary values use fixed precision and carry an explicit currency context.
- All business timestamps use timezone-aware timestamps and are interpreted using the PFD business timezone where appropriate.

## 17. Audit and Historical Truth

Customer-domain changes must identify:

- When the change occurred
- The responsible Principal
- The previous and new business state when material
- The effective date of the business change
- The reason and approval when required

Material changes include legal name, billing relationship, address, delivery eligibility, payment terms, tax status, account status, and standing delivery restrictions.

An audit event is not a replacement for effective-dated operational records. Both are needed: effective records answer what rule applied, while audit records answer who changed it and when.

## 18. Approval Responsibilities

| Decision | Primary responsibility | Additional approval when needed |
|---|---|---|
| Create prospect Party | Sales | None |
| Create pending Customer account | Sales | Sales management |
| Approve delivery location and lane | Operations | Transportation for exceptions |
| Assign standard payment terms | Finance/Admin | Within delegated authority |
| Assign extended terms or credit | Finance/Admin | General Management above authority threshold |
| Approve tax exemption | Finance/Admin | Supporting documentation required |
| Approve out-of-area service | Operations | General Management for material exceptions |
| Place or release credit hold | Finance/Admin | According to delegated authority |
| Place operational hold | Operations | General Management for prolonged holds |
| Inactivate customer | Sales and Finance | Operations review if open deliveries exist |

The database must enforce recorded authority and required approvals where practical; it must not depend solely on informal verbal approval.

## 19. Simulation Behavior

Simulation creates and updates ordinary Party and Customer records through the same business services and validation rules used by normal operation.

Examples:

- A simulated new customer receives a real customer number from the controlled number service.
- A simulated address change becomes the effective customer address history.
- A simulated credit hold updates the actual customer/credit business state.
- Reports compare periods using operational and accounting dates, not a duplicate simulation database.

Simulation-run metadata may record scenario control, random seed, start time, and execution diagnostics in the `simulation` schema. That metadata must not become part of Customer Master keys or create parallel customer truth.

## 20. Business-to-IT Capability Alignment

| Business capability | Party and Customer support |
|---|---|
| Develop customer relationships | Prospect Party, organization, person, contacts, classifications. |
| Open customer accounts | Controlled onboarding, customer-number allocation, activation checklist. |
| Serve multi-site institutions | Customer account separated from multiple operating and delivery locations. |
| Plan delivery territory | Service lanes, eligibility decisions, conditions, and expiring exceptions. |
| Take accurate orders | Current account status, contacts, locations, payment terms, and standing requirements. |
| Deliver safely and on time | Receiving windows, access restrictions, temperature capability, and appointment requirements. |
| Invoice correctly | Explicit billing arrangements, billing addresses, purchase-order requirements, and effective terms. |
| Control credit exposure | Stable customer-to-credit-account linkage and distinct credit-hold status. |
| Apply tax correctly | Effective tax status and verified exemption-certificate metadata. |
| Manage recalls and food safety | Current customer and location contacts, including designated recall contacts. |
| Preserve accountability | Effective history, responsible Principals, reasons, and approval evidence. |
| Run short simulations | Same permanent customer tables and rules as actual operations. |

## 21. Reporting Requirements

The domain must support:

- Active customers by primary and secondary segment
- Customers and locations by service lane
- Conditional and exception-approved service locations
- Service exceptions approaching expiration
- Customers by payment terms
- Customers on credit or operational hold
- Tax certificates missing, unverified, or approaching expiration
- Customer locations lacking required receiving contacts or instructions
- New, activated, suspended, and inactivated customers by period
- Customer and address change history
- Parent/child and centralized-billing account structures

Reports use the operational tables and effective dates. They do not rely on manually maintained duplicate lists.

## 22. Security and Privacy

- Application users receive only the Party and Customer capabilities appropriate to their work.
- Sales may maintain prospect, contact, and commercial information but cannot approve its own credit or tax exceptions beyond assigned authority.
- Operations maintains service eligibility and receiving requirements but cannot change credit limits or tax status.
- Finance maintains terms, tax documentation, billing controls, and credit linkage.
- Reporting access excludes protected tax identifiers and sensitive personal data unless specifically authorized.
- Tax identifiers and document references require field-level protection and access logging.
- Authentication data remains outside this domain.
- Physical deletion of business history is restricted to approved legal retention procedures, not ordinary application activity.

## 23. Reference Data Required for the Initial Build

The initial database build must include controlled values for:

- Party type
- Party relationship type
- Customer status and status reason
- Primary customer segment
- Secondary classification type and value
- Customer relationship type
- Location type and purpose
- Address use and address-validation status
- Contact-method type and contact responsibility
- Service lane and service-eligibility status
- Weekday and receiving-window controls
- Location requirement type
- Payment terms
- Tax status, exemption type, and verification status
- Hold type
- Order and invoice communication preference

Reference rows are inactivated rather than deleted. New codes require governance review because operational and historical records depend on their meaning.

## 24. Dependencies on Later Domains

The Party and Customer database build establishes stable references for later work:

- Sales uses customer number, ordering contact, ship-to location, bill-to arrangement, and terms.
- Credit owns credit accounts, exposure, holds, exceptions, and collections.
- Product and Pricing use customer segments and customer number for eligibility and price agreements.
- Warehouse uses delivery-site requirements relevant to picking, staging, and labeling.
- Transportation uses service lane, address, coordinates, receiving windows, and access restrictions.
- Quality uses customer and location contacts for recalls and incidents.
- Finance uses customer, billing arrangements, tax status, terms, and receivable ownership.

## 25. Build Readiness

No unresolved architectural decision prevents the Party and Customer database build.

The following are implementation or onboarding configuration, not design blockers:

- Exact geographic boundaries and permitted deviation for each service lane
- Initial standard payment terms assigned to each committed opening customer
- Credit limits and credit-account approvals
- Selection of address-validation/geocoding and document-storage services
- Customer-specific receiving windows, security rules, and tax certificates
- Opening customer numbers if owners wish to preserve preassigned commercial numbers

The next deliverable should be the **PFD Party and Customer PostgreSQL Build Specification**, followed by its executable SQL package.

---

## 26. Approved Outcome

PFD will maintain one normalized, permanent source of truth for organizations, people, customer accounts, locations, contacts, service eligibility, billing terms, tax status, and customer lifecycle history. Customer numbers are operational natural keys, simulation uses the same business records as normal operation, and later business domains reference this foundation rather than copying it.
