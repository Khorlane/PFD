# \<business name>
# Party and Customer PostgreSQL Build Specification

**Document version:** 1.0  
**Date:** September 4, 2026  
**Status:** Physical database design baseline; executable SQL not included  
**Build range:** Permanent changes `0011` through `0022`  
**Depends on:** PFD PostgreSQL Core Build through change `0010`; PFD Party and Customer Domain Specification

---

## 1. Purpose

This specification defines the PostgreSQL database objects required to implement PFD's Party and Customer domain. It is the contract for the subsequent executable SQL package.

This document remains in design. It specifies tables, columns, natural keys, relationships, checks, indexes, reference data, controlled functions, privileges, build order, verification, and tests. It does not apply changes to a database.

## 2. Required Outcome

The build must provide one normalized and persistent source of truth for:

- Organizations and people known to PFD
- Customer commercial accounts
- Customer locations and addresses
- Contact methods and contact responsibilities
- Customer classifications and account relationships
- Service-lane eligibility and exceptions
- Receiving windows and standing delivery requirements
- Payment terms and billing arrangements
- Tax status and exemption-certificate metadata
- Customer status and material-change history

Customer Master must use `customer_number` as its primary key. No surrogate, identity, serial, UUID, object identifier, or hidden substitute primary key is permitted.

## 3. Platform and Existing Foundation

The implementation targets PostgreSQL 15 or later on a vendor-supported release. It extends the database created by the PFD PostgreSQL Core Build.

Existing objects used by this build include:

- Schemas: `core`, `party`, `sales`, `transport`, `credit`, `audit`, `reporting`, and `simulation`
- `core.principal`
- `core.company`
- `core.business_area`
- `core.role_code`
- `core.transaction_type`
- `core.number_sequence`
- `core.allocate_business_number(text, text)`
- `core.database_change`
- Database roles established by the Core Build
- The `btree_gist` extension

All changes execute under `SET LOCAL ROLE pfd_database_owner` inside a transaction controlled by the existing PFD build runner.

## 4. Package and Manifest Strategy

The Party and Customer executable release must be a cumulative database package.

- Changes `0001` through `0010` are included byte-for-byte from Core Build 1.0.0.
- New changes are numbered `0011` through `0022`.
- The release manifest contains the complete contiguous history `0001` through `0022`.
- Previously applied file checksums must match before any new change runs.
- A new database can be built from the cumulative package.
- An existing Core database applies only pending changes `0011` through `0022`.
- Applied files are immutable. Corrections are new forward changes.

Recommended cumulative manifest version: `2.0.0`.

## 5. Naming and Data-Type Standards

### 5.1 Naming

- PostgreSQL identifiers use lowercase `snake_case`.
- Primary keys are named `pk_<table>`.
- Foreign keys are named `fk_<table>_<purpose>`.
- Unique constraints are named `uq_<table>_<purpose>`.
- Check constraints are named `ck_<table>_<purpose>`.
- Exclusion constraints are named `ex_<table>_<purpose>`.
- Indexes are named `ix_<table>_<purpose>`.
- Controlled functions use an action-oriented name in their owning schema.

### 5.2 Standard Types

| Information | PostgreSQL type |
|---|---|
| Business numbers and governed codes | `text` with explicit format and nonblank checks |
| Names and descriptions | `text` with nonblank checks where required |
| Dates without time-of-day meaning | `date` |
| Events and effective instants | `timestamptz` |
| Day of week | governed code, not free text |
| Time of day | `time without time zone` interpreted in the location's business timezone |
| Monetary amounts | `numeric(19,4)` with explicit currency context |
| Geographic coordinates | `numeric(9,6)` latitude and `numeric(10,6)` longitude |
| Document checksums | lowercase 64-character SHA-256 text |
| Optimistic concurrency | positive `bigint` `row_version` maintained by controlled writes |

Arbitrary short `varchar(n)` limits should not be used as substitutes for real business validation.

### 5.3 Code Format

Governed codes use uppercase letters, numbers, and underscores and satisfy:

`^[A-Z][A-Z0-9_]*$`

Assigned Party and Address numbers use an uppercase prefix and digits. Customer numbers use six digits initially.

## 6. Audit Column Standard

Mutable master and effective-dated tables include, unless expressly excluded:

- `created_at timestamptz not null`
- `created_by_principal_code text not null`
- `updated_at timestamptz not null`
- `updated_by_principal_code text not null`
- `row_version bigint not null default 1`

Both Principal columns reference `core.principal(principal_code)`. Checks require `updated_at >= created_at` and `row_version > 0`.

Effective-dated records additionally use:

- `effective_from timestamptz not null`
- `effective_through timestamptz null`

The period is half-open: `[effective_from, effective_through)`. A null end means indefinitely effective. End must be later than start. Overlapping current facts are prevented with GiST exclusion constraints where appropriate.

## 7. Number Allocation

Change `0011` must add these rows to `core.number_sequence`:

| Sequence code | Prefix | Width | Initial value | Example |
|---|---:|---:|---:|---|
| `PARTY` | `P` | 8 | 1 | `P00000001` |
| `ADDRESS` | `A` | 8 | 1 | `A00000001` |
| `CUSTOMER` | none | 6 | 1 | `000001` |
| `PARTY_CUSTOMER_AUDIT_EVENT` | `PCE` | 10 | 1 | `PCE0000000001` |

These are visible, permanent business identifiers. They are not technical surrogate keys. Allocation must use `core.allocate_business_number`; `MAX(...) + 1` is prohibited.

## 8. Reference-Table Standard

Reference tables use their governed code as primary key and normally contain:

- code
- display name
- description
- sort order
- `is_active`
- `effective_from date`
- `effective_through date`
- standard audit columns

Reference rows are inactivated, not deleted. An inactive code remains valid for historical foreign keys but cannot be assigned to a new current record.

### 8.1 Shared Core References Added by This Build

Change `0011` adds normalized references needed by several future domains:

| Table | Primary key | Opening content |
|---|---|---|
| `core.country` | `country_code` | `US` |
| `core.subdivision` | `country_code + subdivision_code` | `NC`, `SC` under `US` |
| `core.currency` | `currency_code` | `USD` |
| `core.weekday` | `weekday_code` | Monday through Sunday with ISO weekday number |

`core.subdivision` uses the composite foreign key to `core.country`. Address and organization records reference country and subdivision together so an invalid country/state combination cannot be stored.

## 9. Party Reference Tables

The `party` schema must contain these reference tables:

| Table | Primary key | Initial purpose |
|---|---|---|
| `party.party_type` | `party_type_code` | `ORGANIZATION`, `PERSON` |
| `party.organization_name_type` | `organization_name_type_code` | `LEGAL`, `TRADE`, `OPERATIONAL` |
| `party.person_name_type` | `person_name_type_code` | `LEGAL`, `PREFERRED`, `BUSINESS` |
| `party.organization_form` | `organization_form_code` | Corporation, LLC, partnership, government, nonprofit, sole proprietorship, other |
| `party.relationship_type` | `relationship_type_code` | Employment, ownership, parent, division, affiliate, authorized contact |
| `party.address_use_type` | `address_use_type_code` | Physical, delivery, billing, statement, correspondence |
| `party.address_validation_status` | `address_validation_status_code` | Unverified, customer confirmed, standardized, geocoded, rejected |
| `party.geocoding_confidence` | `geocoding_confidence_code` | High, medium, low, unknown |
| `party.contact_method_type` | `contact_method_type_code` | Business email, business phone, mobile phone, fax, electronic-order endpoint |

Every reference table follows the reference-table standard and has an index supporting active values in display order.

## 10. `party.party`

Purpose: stable identity of an organization or person.

| Column | Type | Null | Rule |
|---|---|---:|---|
| `party_number` | `text` | No | Primary key; format `^P[0-9]{8}$` |
| `party_type_code` | `text` | No | FK to `party.party_type` |
| `display_name` | `text` | No | Trimmed, nonblank operational display |
| `is_active` | `boolean` | No | Default true |
| audit columns | standard | No | Required |

Indexes:

- `(party_type_code, is_active)`
- case-insensitive search index on normalized `display_name`

Party type is immutable after creation. Organization and Person subtype rules are verified by controlled creation functions and database constraint triggers.

## 11. Organization Structures

### 11.1 `party.organization`

| Column | Type | Null | Rule |
|---|---|---:|---|
| `party_number` | `text` | No | Primary key and FK to `party.party` |
| `organization_form_code` | `text` | Yes | FK to `party.organization_form` |
| `federal_tax_identifier_ciphertext` | `bytea` | Yes | Encrypted value only when needed |
| `tax_identifier_last_four` | `text` | Yes | Exactly four digits when present |
| `state_of_organization_country_code` | `text` | Yes | Part of composite FK to `core.subdivision` |
| `state_of_organization_code` | `text` | Yes | Part of composite FK to `core.subdivision` |
| audit columns | standard | No | Required |

The referenced Party must have type `ORGANIZATION`. Plaintext federal tax identifiers are prohibited.

### 11.2 `party.organization_name`

Primary key:

`party_number + organization_name_type_code + effective_from`

Columns include organization name, effective period, and audit columns. A GiST exclusion constraint prevents overlapping periods for the same Party and name type. Every active Organization requires one current `LEGAL` name. Trade and operational names are optional.

Index normalized name text for duplicate review and search. Similar names are warnings, not uniqueness violations.

## 12. Person Structures

### 12.1 `party.person`

| Column | Type | Null | Rule |
|---|---|---:|---|
| `party_number` | `text` | No | Primary key and FK to `party.party` |
| audit columns | standard | No | Required |

The referenced Party must have type `PERSON`.

The table establishes the Person subtype. Person names are effective-dated separately so the model has one authoritative source for current and historical names. Person records exclude Social Security numbers, birth dates, home addresses, and other unrelated personal data from this domain.

### 12.2 `party.person_name`

Person names are captured in `party.person_name` with primary key:

`party_number + person_name_type_code + effective_from`

Columns include given name, optional middle name, family name, optional suffix, effective period, and audit columns. Each Person requires one current `BUSINESS` name. Periods for the same Person and name type cannot overlap. Current operational display is exposed through a view rather than duplicated on `party.person`.

## 13. Address Structures

### 13.1 `party.address`

Purpose: stable identity for an address whose details may be revised or revalidated.

| Column | Type | Null | Rule |
|---|---|---:|---|
| `address_number` | `text` | No | Primary key; format `^A[0-9]{8}$` |
| `is_active` | `boolean` | No | Default true |
| audit columns | standard | No | Required |

### 13.2 `party.address_version`

Primary key:

`address_number + effective_from`

Required columns:

- `address_line_1`
- optional `address_line_2` and `address_line_3`
- `city_name`
- `state_province_code`
- `postal_code`
- `country_code`, initially `US`
- optional `county_name`
- `address_validation_status_code`
- optional `validated_at`
- optional `standardized_address_text`
- optional latitude and longitude
- optional geocoding confidence code
- effective period and audit columns

Checks:

- Required address components are trimmed and nonblank.
- Latitude is between -90 and 90.
- Longitude is between -180 and 180.
- Latitude and longitude are both null or both populated.
- `validated_at` is required for customer-confirmed, standardized, or geocoded status.
- Versions for an address cannot overlap.

The address as supplied and standardized result are distinguishable. Standardization cannot silently overwrite customer-provided data.

### 13.3 `party.party_address_use`

Primary key:

`party_number + address_number + address_use_type_code + effective_from`

It associates a Party with an Address for a specific use. An exclusion constraint prevents overlapping assignments of the same use when that use is configured as singular, such as the primary billing address.

## 14. Contact Methods

### 14.1 `party.contact_method`

Primary key:

`party_number + contact_method_code + effective_from`

Columns:

- Party number
- Stable Party-local contact method code, such as `WORK_PHONE` or `AP_EMAIL`
- Contact method type
- Contact value
- Normalized contact value
- Extension when applicable
- Preference sequence
- Verification status and optional verification timestamp
- Effective period and audit columns

Checks and controlled functions validate email and telephone normalization. Validation should reject clearly invalid values but must not claim deliverability merely because format is valid.

Duplicate current normalized contact values for the same Party and type are prevented unless an approved exception is recorded.

## 15. Party Relationships

### 15.1 `party.party_relationship`

Primary key:

`from_party_number + to_party_number + relationship_type_code + effective_from`

Columns include effective period, optional customer-context note, and audit fields.

Constraints:

- Both Party numbers are valid and different.
- Effective periods for the same relationship do not overlap.
- Relationship-type metadata defines permitted source and target Party types.
- Parent, ownership, and division relationships cannot create a cycle.
- Reciprocal meaning is derived from the relationship type rather than duplicated as a second row.

## 16. Customer Reference Tables

The `sales` schema must contain these controlled tables:

| Table | Primary key | Initial values or purpose |
|---|---|---|
| `sales.customer_status` | `customer_status_code` | Pending approval, active, credit hold, operational hold, suspended, inactive |
| `sales.customer_status_reason` | `customer_status_reason_code` | Governed reasons appropriate to each status |
| `sales.customer_segment` | `customer_segment_code` | Restaurant, hospital, school, correctional institution, hotel, other food service |
| `sales.classification_type` | `classification_type_code` | Additional reporting dimensions |
| `sales.customer_classification_value` | `classification_type_code + classification_code` | Governed values within a classification type |
| `sales.customer_relationship_type` | `customer_relationship_type_code` | Parent, central billing, central purchasing, buying group, shared credit |
| `sales.customer_location_type` | `customer_location_type_code` | Headquarters, billing office, delivery site, kitchen, administrative office, central receiving |
| `sales.location_purpose` | `location_purpose_code` | Delivery, billing, ordering, statement, administration |
| `sales.contact_role` | `contact_role_code` | Ordering, purchasing, receiving, AP, billing inquiry, credit, recall, escalation |
| `sales.service_eligibility_status` | `service_eligibility_status_code` | Eligible, conditional, exception approved, not eligible, pending review |
| `sales.location_requirement_type` | `location_requirement_type_code` | Appointment, advance notice, dock, liftgate, pallet jack, security, temperature, POD, split-pack acceptance |
| `sales.payment_terms` | `payment_terms_code` | Prepaid, due on receipt, Net 7, Net 15, Net 30 |
| `sales.billing_arrangement_type` | `billing_arrangement_type_code` | Location billing, customer billing, central parent billing |
| `sales.tax_status` | `tax_status_code` | Taxable, exempt documented, partially exempt, pending review |
| `sales.tax_exemption_type` | `tax_exemption_type_code` | Government, nonprofit, resale, jurisdiction-specific other |
| `sales.certificate_verification_status` | `certificate_verification_status_code` | Pending, verified, rejected, expired |
| `sales.tax_jurisdiction` | `jurisdiction_code` | `US_NC`, `US_SC` opening sales-tax jurisdictions |
| `sales.communication_preference` | `communication_preference_code` | Electronic, email, paper, EDI when supported |

Relationship tables between status/reason and classification type/value enforce valid combinations rather than relying on application code.

## 17. `sales.customer`

Customer Master contains only stable account identity and current operational pointers that are not separately temporal.

| Column | Type | Null | Rule |
|---|---|---:|---|
| `customer_number` | `text` | No | Primary key; format `^[0-9]{6}$` |
| `organization_party_number` | `text` | No | FK to `party.organization(party_number)` |
| `account_opened_on` | `date` | No | Cannot predate formal onboarding |
| `default_currency_code` | `text` | No | FK to governed currency; initial value `USD` |
| `responsible_sales_principal_code` | `text` | Yes | FK to `core.principal` |
| `purchase_order_required` | `boolean` | No | Default false |
| `default_invoice_preference_code` | `text` | No | FK to communication preference |
| audit columns | standard | No | Required |

Constraints and indexes:

- Customer number is permanent and immutable.
- Organization Party must be active when the account is created.
- Multiple customer accounts may reference one Organization; this is intentional.
- Index `(organization_party_number)`.
- Index `(responsible_sales_principal_code)`.

Customer name, active state, status, segment, terms, tax status, and service eligibility are not duplicated here; they reside in effective-dated structures.

## 18. Customer Name, Status, and Segment

### 18.1 `sales.customer_name`

Primary key: `customer_number + effective_from`.

Stores the operational customer name displayed on orders and reports. Periods for the customer cannot overlap. A customer requires exactly one current name after creation.

### 18.2 `sales.customer_status_history`

Primary key: `customer_number + effective_from`.

Columns include status, reason, explanation, effective period, approving Principal when required, and audit fields. Periods cannot overlap. Exactly one current status is permitted.

Status transitions are enforced by `sales.change_customer_status`. Direct application writes are prohibited.

### 18.3 `sales.customer_primary_segment`

Primary key: `customer_number + effective_from`.

Exactly one current primary segment is required for an active customer. Periods cannot overlap.

### 18.4 `sales.customer_classification`

Primary key:

`customer_number + classification_type_code + classification_code + effective_from`

Multiple current classifications are allowed when the classification type permits them. A constraint trigger enforces single-value types.

## 19. Customer Account Relationships

### 19.1 `sales.customer_relationship`

Primary key:

`parent_customer_number + child_customer_number + customer_relationship_type_code + effective_from`

Constraints:

- Parent and child must differ.
- Both accounts must exist.
- Periods for the same relationship cannot overlap.
- Relationship-type rules determine whether multiple current parents are allowed.
- Parent and central-billing relationships cannot form cycles.
- A central-billing relationship alone does not combine credit or ordering behavior.

Indexes support lookup from either parent or child.

## 20. Customer Locations

### 20.1 `sales.customer_location`

Primary key:

`customer_number + customer_location_code`

| Column | Type | Null | Rule |
|---|---|---:|---|
| `customer_number` | `text` | No | FK to Customer |
| `customer_location_code` | `text` | No | Uppercase stable account-local code |
| `location_name` | `text` | No | Nonblank |
| `customer_location_type_code` | `text` | No | FK to location type |
| `business_timezone` | `text` | No | Valid PostgreSQL/IANA timezone |
| `is_active` | `boolean` | No | Default true |
| audit columns | standard | No | Required |

`MAIN` is the recommended first location code but is not assumed to be a delivery site.

### 20.2 `sales.customer_location_purpose`

Primary key:

`customer_number + customer_location_code + location_purpose_code + effective_from`

Supports a location serving several purposes. Effective periods for the same purpose cannot overlap.

### 20.3 `sales.customer_location_address`

Primary key:

`customer_number + customer_location_code + address_use_type_code + effective_from`

The record references `party.address(address_number)` and supplies an effective period. A delivery location may have only one current physical delivery address. Changing the address closes the old assignment and opens the new assignment atomically.

An address change never rewrites the address captured on a released shipment or issued invoice.

## 21. Customer Contact Assignments

### 21.1 `sales.customer_contact_assignment`

Primary key:

`customer_number + contact_role_code + person_party_number + effective_from`

The Person must have a current Contact Method suitable for the role. Account-level roles include purchasing, AP, billing inquiry, credit, recall, and management escalation.

### 21.2 `sales.location_contact_assignment`

Primary key:

`customer_number + customer_location_code + contact_role_code + person_party_number + effective_from`

Every active delivery location requires at least one current receiving contact. Multiple contacts can have a priority sequence; duplicate priority for the same role and period is prohibited.

## 22. Service Lanes and Eligibility

### 22.1 `transport.service_lane`

Primary key: `service_lane_code`.

Initial rows:

| Code | Endpoint city | State |
|---|---|---|
| `STATESVILLE` | Statesville | NC |
| `MONROE` | Monroe | NC |
| `ROCK_HILL` | Rock Hill | SC |
| `GASTONIA` | Gastonia | NC |

Each lane records the hub company/location reference, endpoint, active status, descriptive corridor guidance, and audit columns. Exact corridor geometry and route-deviation tolerances are configuration data, not embedded in application code.

### 22.2 `sales.customer_service_eligibility`

Primary key:

`customer_number + customer_location_code + effective_from`

Columns:

- Service lane code
- Eligibility status
- Decision reason
- Optional minimum order amount and currency
- Optional permitted delivery-day rule
- Optional maximum route deviation or special condition text
- Decision Principal
- Approval Principal for exception status
- Required expiration for exception status
- Effective period and audit fields

Rules:

- Periods for a location cannot overlap.
- `EXCEPTION_APPROVED` requires approver, reason, and finite expiration.
- `CONDITIONAL` requires at least one condition.
- `ELIGIBLE` requires an active service lane.
- Postal code or distance alone cannot create an eligible record.
- Only controlled functions may change eligibility.

Index current records by `(service_lane_code, service_eligibility_status_code)`.

## 23. Receiving Windows and Location Requirements

### 23.1 `sales.location_receiving_window`

Primary key:

`customer_number + customer_location_code + weekday_code + window_sequence + effective_from`

Columns include start time, end time, appointment-required flag, effective period, and audit fields.

Rules:

- Window sequence is a meaningful ordering within the day, starting at 1.
- Start and end must differ.
- Overnight windows must be explicitly flagged.
- Overlapping active windows for a location and weekday are prohibited.
- Times are interpreted in the Customer Location timezone.

### 23.2 `sales.location_requirement`

Primary key:

`customer_number + customer_location_code + location_requirement_type_code + effective_from`

Columns include required flag, structured value when the requirement type defines one, explanatory text, effective period, and audit fields.

Initial requirement types cover appointment scheduling, advance notice, dock availability, liftgate, pallet jack, hand unload, vehicle-size restriction, security/check-in, temperature-zone capability, proof of delivery, and split-pack acceptance.

The presence of split-pack acceptance does not make split pack the default or preferred fulfillment method.

## 24. Payment Terms and Billing

### 24.1 `sales.payment_terms`

Initial rows:

| Code | Due days | Credit terms |
|---|---:|---:|
| `PREPAID` | 0 | No |
| `DUE_ON_RECEIPT` | 0 | No |
| `NET_7` | 7 | Yes |
| `NET_15` | 15 | Yes |
| `NET_30` | 30 | Yes |

The table includes `requires_credit_account`, active/effective data, and audit fields. Terms longer than Net 30 are not part of the opening reference set and require a later governed change.

### 24.2 `sales.customer_payment_terms`

Primary key: `customer_number + effective_from`.

Columns include terms code, approving Principal, approval reference, effective period, and audit fields. Periods cannot overlap. Exactly one current terms row is required for an active Customer.

If terms require credit, activation requires a valid Credit-domain approval. Until the Credit build exists, only non-credit terms may be activated in an executable environment unless a controlled transitional approval record is provided.

### 24.3 `sales.customer_billing_arrangement`

Primary key: `customer_number + effective_from`.

Columns include arrangement type, optional billing customer number, optional billing location code, invoice preference, customer purchase-order requirement, effective period, and audit fields.

Rules:

- Central parent billing requires an active central-billing customer relationship.
- A referenced billing location must be active and have a current billing address.
- Periods cannot overlap.
- Historical invoices retain their own billing snapshot.

## 25. Tax Structures

### 25.1 `sales.customer_tax_status`

Primary key:

`customer_number + jurisdiction_code + effective_from`

Columns include tax status, decision Principal, effective period, and audit fields. Periods cannot overlap for the same customer and jurisdiction.

An active customer must have an explicit current tax status for every jurisdiction required by its active delivery locations.

### 25.2 `sales.tax_exemption_certificate`

Primary key:

`customer_number + jurisdiction_code + certificate_number`

Columns:

- Exemption type
- Issue date
- Optional expiration date
- Verification status
- Verification date and verifying Principal
- Controlled document reference
- SHA-256 document checksum
- Inactivation date and reason
- Audit fields

Rules:

- Verified status requires verification date, Principal, document reference, and checksum.
- Expiration cannot precede issue date.
- Expired or rejected certificates cannot support current exempt status.
- Certificate document bytes are not stored in Customer Master.

## 26. Customer Activation and Status Functions

The executable package must provide controlled, transaction-safe functions. Function names and signatures may be refined without changing their defined behavior.

### 26.1 Party Functions

- `party.create_organization_party(...) returns party_number`
- `party.create_person_party(...) returns party_number`
- `party.record_address_version(...) returns address_number`
- `party.assign_party_address(...)`
- `party.record_contact_method(...)`
- `party.change_organization_name(...)`
- `party.change_person_name(...)`

### 26.2 Customer Functions

- `sales.create_pending_customer(...) returns customer_number`
- `sales.add_customer_location(...) returns customer_location_code`
- `sales.assign_customer_location_address(...)`
- `sales.set_customer_primary_segment(...)`
- `sales.set_customer_payment_terms(...)`
- `sales.set_customer_billing_arrangement(...)`
- `sales.set_customer_service_eligibility(...)`
- `sales.record_customer_tax_status(...)`
- `sales.change_customer_status(...)`
- `sales.activate_customer(...)`
- `sales.inactivate_customer(...)`

### 26.3 Function Requirements

Every controlled function must:

- Validate the responsible Principal and required approval authority.
- Lock the affected stable master row before changing effective history.
- Close the previous current period and insert the new period atomically.
- Refuse a backdated change that would create overlap or rewrite closed history.
- Increment relevant row versions.
- Write a Party/Customer audit event in the same transaction.
- Use a fixed safe `search_path` when `SECURITY DEFINER` is required.
- Revoke execution from `PUBLIC` and grant only approved roles.
- Return stable business identifiers, not internal PostgreSQL identifiers.

## 27. Activation Validation

`sales.activate_customer` must refuse activation unless all required conditions are true:

1. Customer and Organization Party are active.
2. A current customer name exists.
3. A current primary segment exists.
4. At least one active customer location exists.
5. The billing arrangement and billing address are current.
6. A current payment-terms assignment exists.
7. A current tax status exists for required jurisdictions.
8. Every active delivery location has a current physical delivery address.
9. Every delivery location has a service-eligibility decision.
10. At least one required receiving contact exists for each delivery location.
11. Account-level purchasing/ordering and billing contacts exist.
12. Credit-required terms have the required Credit-domain approval.
13. Required approvals are present and effective.

The function returns a clear list of failed prerequisites rather than only the first failure where practical.

## 28. Audit Events

### 28.1 `audit.party_customer_event`

Primary key: `audit_event_number`, allocated from `PARTY_CUSTOMER_AUDIT_EVENT`.

Columns:

- Audit event number
- Event type code
- Event timestamp
- Responsible Principal
- Optional Party number
- Optional customer number
- Optional customer location code
- Business effective timestamp
- Reason code and explanation
- Approval reference when applicable
- Transaction correlation code
- Structured before/after summary using `jsonb`

The event table is append-only. Update and delete are blocked by trigger. The JSON summary is supporting audit evidence, not the authoritative source of customer state.

Sensitive tax identifiers and document contents must never be written into audit JSON.

## 29. Concurrency and Temporal Integrity

- Controlled functions lock the stable Party, Customer, Address, or Customer Location row before modifying related effective history.
- GiST exclusion constraints are the final defense against overlapping effective periods.
- `row_version` supports optimistic concurrency for interactive maintenance.
- A stale expected row version causes the write to fail rather than overwrite another user's change.
- Customer-number, Party-number, Address-number, and audit-number allocation uses row locks in `core.number_sequence`.
- The SQL package must include a two-session concurrency test for number allocation and one for competing effective-dated changes.

## 30. Index Requirements

Every primary key, unique constraint, and exclusion constraint creates or receives its supporting index. Additional indexes must support demonstrated access paths:

- Party by type, active status, and normalized display name
- Organization by normalized legal/trade name
- Person by normalized family and given name
- Current Party relationships from either Party
- Current Address version by address number
- Current contact methods by Party and type
- Customer by Organization Party, active status, responsible sales Principal
- Current customer status, primary segment, terms, and billing arrangement
- Customers by current segment and status
- Locations by customer, type, purpose, and active status
- Current delivery address by Customer Location
- Contact assignments by person and by customer/location
- Service eligibility by lane and status
- Receiving windows by location and weekday
- Tax certificates by expiration and verification status
- Audit events by Party, Customer, location, event type, and timestamp

Partial indexes for current active records should use stable predicates only. Indexes are not added merely because a column is a foreign key; each must support a real validation, join, or lookup path.

## 31. Views

The build must provide reporting-safe views:

- `reporting.current_party`
- `reporting.current_organization_name`
- `reporting.current_party_contact`
- `reporting.current_customer`
- `reporting.current_customer_location`
- `reporting.current_customer_service_eligibility`
- `reporting.customer_service_exception_expiration`
- `reporting.customer_tax_certificate_expiration`
- `reporting.customer_activation_readiness`

Views expose current effective records using database time and the PFD timezone where required. They do not hide historical base tables from authorized support or audit roles.

Protected tax identifier ciphertext, document-storage secrets, and other sensitive values are excluded from general reporting views.

## 32. Privilege Model

### 32.1 Existing Roles

| Role | Party/Customer privileges |
|---|---|
| `pfd_database_owner` | Owns all domain objects; remains `NOLOGIN`. |
| `pfd_change_executor` | Explicitly assumes owner only for approved builds; reads change history. |
| `pfd_application` | Uses schemas, reads approved operational data, and executes controlled domain functions; no direct writes to protected history, numbering, tax security fields, or audit events. |
| `pfd_reporting` | Selects approved reporting views and nonsensitive reference data. |
| `pfd_support_readonly` | Reads base tables for authorized diagnostics, subject to protected-field controls. |
| `PUBLIC` | No schema, table, sequence, or function privileges. |

### 32.2 Required Enforcement

- Revoke all domain-function execution from `PUBLIC` before grants.
- Do not grant direct application updates to effective-history tables.
- Do not grant direct application inserts to audit tables.
- Do not grant direct application updates to `core.number_sequence`.
- Default privileges revoke `PUBLIC` access for future tables, functions, and sequences.
- Sensitive tax columns are accessible only through specifically approved functions or restricted views.

Business separation of duties is enforced inside controlled functions using `core.principal`, business responsibility, and approval-authority data. Database login role alone is not sufficient business approval.

## 33. Reference Data Seed Requirements

Reference data must be supplied as reviewable UTF-8 CSV files and inserted by permanent SQL changes. CSVs are evidence and review artifacts; SQL changes are the executable source.

Required files include:

- Party types and name types
- Organization forms and relationship types
- Address uses and validation statuses
- Contact method types
- Customer statuses and reasons
- Customer segments and secondary classifications
- Customer relationship, location, and purpose types
- Contact roles
- Service lanes and eligibility statuses
- Location requirement types
- Payment terms and billing arrangements
- Tax statuses, exemption types, and verification statuses
- Communication preferences

The manifest validates every CSV checksum. Verification compares exact expected baseline counts and required codes.

### 33.1 Opening Governed Codes

The opening package must use these exact codes unless review of the executable-package draft produces a documented forward change:

| Reference | Required codes |
|---|---|
| Party type | `ORGANIZATION`, `PERSON` |
| Organization name type | `LEGAL`, `TRADE`, `OPERATIONAL` |
| Person name type | `LEGAL`, `PREFERRED`, `BUSINESS` |
| Organization form | `CORPORATION`, `LIMITED_LIABILITY_COMPANY`, `PARTNERSHIP`, `GOVERNMENT_ENTITY`, `NONPROFIT`, `SOLE_PROPRIETORSHIP`, `OTHER` |
| Party relationship type | `WORKS_FOR`, `OWNS`, `PARENT_OF`, `DIVISION_OF`, `AFFILIATED_WITH`, `AUTHORIZED_CONTACT_FOR` |
| Address use | `PHYSICAL`, `DELIVERY`, `BILLING`, `STATEMENT`, `CORRESPONDENCE` |
| Address validation | `UNVERIFIED`, `CUSTOMER_CONFIRMED`, `STANDARDIZED`, `GEOCODED`, `REJECTED` |
| Geocoding confidence | `HIGH`, `MEDIUM`, `LOW`, `UNKNOWN` |
| Contact method type | `BUSINESS_EMAIL`, `BUSINESS_PHONE`, `MOBILE_PHONE`, `FAX`, `ELECTRONIC_ORDER_ENDPOINT` |
| Customer status | `PENDING_APPROVAL`, `ACTIVE`, `CREDIT_HOLD`, `OPERATIONAL_HOLD`, `SUSPENDED`, `INACTIVE` |
| Customer segment | `RESTAURANT`, `HOSPITAL`, `SCHOOL`, `CORRECTIONAL_INSTITUTION`, `HOTEL`, `OTHER_FOOD_SERVICE` |
| Customer relationship type | `PARENT_ACCOUNT`, `CENTRAL_BILLING`, `CENTRAL_PURCHASING`, `BUYING_GROUP`, `SHARED_CREDIT_CONTROL` |
| Customer location type | `HEADQUARTERS`, `BILLING_OFFICE`, `DELIVERY_SITE`, `FOOD_SERVICE_KITCHEN`, `ADMINISTRATIVE_OFFICE`, `CENTRAL_RECEIVING` |
| Location purpose | `DELIVERY`, `BILLING`, `ORDERING`, `STATEMENT`, `ADMINISTRATION` |
| Contact role | `ORDERING`, `PURCHASING`, `RECEIVING`, `ACCOUNTS_PAYABLE`, `BILLING_INQUIRY`, `CREDIT_COLLECTIONS`, `FOOD_SAFETY_RECALL`, `MANAGEMENT_ESCALATION` |
| Service eligibility | `ELIGIBLE`, `CONDITIONAL`, `EXCEPTION_APPROVED`, `NOT_ELIGIBLE`, `PENDING_REVIEW` |
| Service lane | `STATESVILLE`, `MONROE`, `ROCK_HILL`, `GASTONIA` |
| Payment terms | `PREPAID`, `DUE_ON_RECEIPT`, `NET_7`, `NET_15`, `NET_30` |
| Billing arrangement | `LOCATION_BILLING`, `CUSTOMER_BILLING`, `CENTRAL_PARENT_BILLING` |
| Tax status | `TAXABLE`, `EXEMPT_DOCUMENTED`, `PARTIALLY_EXEMPT`, `PENDING_REVIEW` |
| Tax exemption type | `GOVERNMENT`, `NONPROFIT`, `RESALE`, `OTHER_JURISDICTIONAL` |
| Certificate verification | `PENDING`, `VERIFIED`, `REJECTED`, `EXPIRED` |
| Communication preference | `ELECTRONIC`, `EMAIL`, `PAPER`, `EDI` |

Opening location requirement codes are:

`APPOINTMENT_REQUIRED`, `ADVANCE_NOTICE_REQUIRED`, `DOCK_AVAILABLE`, `LIFTGATE_REQUIRED`, `PALLET_JACK_REQUIRED`, `HAND_UNLOAD_REQUIRED`, `VEHICLE_SIZE_RESTRICTION`, `SECURITY_CHECK_IN`, `AMBIENT_RECEIVING`, `REFRIGERATED_RECEIVING`, `FROZEN_RECEIVING`, `PROOF_OF_DELIVERY_REQUIRED`, and `SPLIT_PACK_ACCEPTED`.

Opening customer-status reasons are:

`NEW_ACCOUNT_REVIEW`, `ONBOARDING_COMPLETE`, `CREDIT_REVIEW`, `PAST_DUE`, `CREDIT_EXCEPTION_EXPIRED`, `DELIVERY_RESTRICTION`, `COMPLIANCE_REVIEW`, `CUSTOMER_REQUEST`, `ACCOUNT_CLOSED`, and `MANAGEMENT_DECISION`.

The opening secondary classification type is `FOOD_SERVICE_SUBTYPE`. Its values are `INDEPENDENT_RESTAURANT`, `RESTAURANT_GROUP`, `ACUTE_CARE_HOSPITAL`, `LONG_TERM_CARE`, `PUBLIC_SCHOOL_DISTRICT`, `PRIVATE_SCHOOL`, `COLLEGE_UNIVERSITY`, `STATE_CORRECTIONAL`, `LOCAL_DETENTION`, `LIMITED_SERVICE_HOTEL`, and `FULL_SERVICE_HOTEL`.

## 34. Permanent Change Order

| Change | Required content |
|---|---|
| `0011` | Add Party, Address, Customer, and audit number-sequence rows; create shared jurisdiction/currency/weekday references needed by this domain if not already present. |
| `0012` | Create Party reference tables and seed approved Party reference data. |
| `0013` | Create Party, Organization, Person, and effective name-history tables. |
| `0014` | Create Address, Address Version, Party Address Use, and Contact Method tables. |
| `0015` | Create Party Relationship structures and temporal/cycle controls. |
| `0016` | Create Customer reference tables and seed approved Customer reference data. |
| `0017` | Create Customer Master, Customer Name, Status History, Primary Segment, and Classification tables. |
| `0018` | Create Customer Relationship, Customer Location, Location Purpose, Location Address, and contact-assignment tables. |
| `0019` | Create Service Lane, Service Eligibility, Receiving Window, and Location Requirement structures. |
| `0020` | Create Payment Terms assignments, Billing Arrangements, Customer Tax Status, and Tax Exemption Certificate structures. |
| `0021` | Create controlled Party/Customer functions, audit event table, temporal guards, concurrency controls, and reporting views. |
| `0022` | Apply comments, ownership, grants, default privileges, verification metadata, and final baseline assertions. |

Every change is transactional. If a change cannot safely run in a transaction, it must be split and explicitly approved; none is currently expected to require that exception.

## 35. Verification Suite

The read-only verification package must assert:

- Change history is contiguous through `0022` and checksums match.
- Required schemas, tables, views, functions, triggers, and constraints exist.
- Every domain table has the approved natural primary key.
- No identity, serial, UUID, owned sequence, or generic `<table>_id` primary key exists.
- Every foreign key is validated.
- Every required effective-dated structure has a date-order check and non-overlap enforcement.
- Number-sequence rows have the approved prefix, width, and positive state.
- Required reference codes exist and baseline counts match.
- Customer number format is six digits.
- Party and Address number formats match the approved prefixes.
- `PUBLIC` has no domain access.
- Application and reporting privileges match the matrix.
- Audit history is append-only.
- Reporting views exclude protected tax data.
- No simulation-session column exists in authoritative Party or Customer structures.

## 36. Behavioral Test Suite

All data-changing unit tests run inside transactions and roll back. Tests execute in a disposable PostgreSQL database built from the cumulative package.

Required tests:

1. Create an Organization Party and receive the next valid Party number.
2. Create a Person Party and reject a mismatched subtype.
3. Add an Address and nonoverlapping Address Versions.
4. Reject overlapping Address Versions.
5. Create a pending Customer and receive the next six-digit Customer number.
6. Reject duplicate Customer number and duplicate natural composite keys.
7. Allow two Customer accounts for one Organization Party.
8. Create multiple locations under one Customer.
9. Reject a duplicate location code within a Customer but allow the same code for another Customer.
10. Reject activation when required terms, tax status, contacts, address, or eligibility are missing.
11. Activate a complete prepaid Customer.
12. Reject credit terms without Credit-domain approval.
13. Change customer status and preserve nonoverlapping history.
14. Reject an unauthorized status or terms change.
15. Create a service exception and require approval, reason, and expiration.
16. Reject overlapping service-eligibility periods.
17. Reject overlapping receiving windows.
18. Record a verified tax certificate only with document reference and checksum.
19. Prevent expired certificate use for exempt status.
20. Prevent cyclic parent and central-billing relationships.
21. Prevent application writes to protected history and audit tables.
22. Prevent update or delete of Party/Customer audit events.
23. Verify two concurrent number allocations are unique and ordered.
24. Verify two concurrent effective-history changes cannot overlap.
25. Verify simulation processing uses ordinary Customer tables without a simulation identifier.

## 37. Test Fixtures

Test data must be fictional and clearly marked. It should cover:

- One restaurant with a single site
- One hospital with central billing and two delivery locations
- One school system with central purchasing and several kitchens
- One correctional institution requiring appointment and security instructions
- One hotel with constrained delivery access
- One conditional or exception-approved service location
- Taxable and tax-exempt examples
- Prepaid and approved-credit examples

Fixture customer numbers, Party numbers, and Address numbers are allocated through the same controlled mechanisms as normal data, then rolled back or used only in the disposable database.

## 38. Operational and Recovery Requirements

- The build runner performs local manifest/checksum validation before database access.
- The target is rejected for unknown, mismatched, or gapped history.
- An advisory lock prevents concurrent database builds.
- Each change commits independently and records only successful completion.
- Verification runs immediately after build.
- Behavioral tests run in a disposable validation database, not production.
- A failed change rolls back completely.
- Forward correction is the normal recovery method after release.
- Backup and restore readiness is confirmed before shared-environment deployment.
- Deployment evidence retains manifest version, target, operator, approver, timestamps, output, and verification result.

## 39. Documentation Delivered with the SQL Package

The executable package must include:

- Party and Customer data dictionary
- Entity and relationship catalog
- Natural-key catalog
- Reference-data catalog
- Function and status-transition catalog
- Privilege matrix
- Sensitive-data handling note
- Build and verification instructions
- Disposable-test instructions
- Deployment acceptance checklist
- Release notes identifying changes `0011` through `0022`

## 40. Acceptance Criteria

The Party and Customer PostgreSQL build is accepted when:

- A clean Core database advances from `0010` through `0022` without manual SQL edits.
- A new database builds cumulatively through `0022`.
- A second build reports no pending work and changes nothing.
- All manifest checksums pass.
- All read-only verification passes.
- All rollback-contained and concurrent behavioral tests pass.
- Customer Master uses `customer_number` as its primary key.
- Every table uses the documented natural or controlled business key.
- Effective histories reject overlap and preserve prior facts.
- Activation prerequisites are enforced in the database service layer.
- Privilege tests prove the application cannot bypass controlled workflows.
- Audit records are complete, append-only, and free of prohibited sensitive content.
- Simulation can create and maintain customers without parallel Customer Master tables or simulation-session keys.

## 41. Decisions Deferred Without Blocking the Build

The following are configuration or integration selections, not unresolved database architecture:

- Address-validation and geocoding provider
- Controlled document-storage platform
- Encryption key-management platform
- Exact geographic corridor definitions and route-deviation thresholds
- Opening committed-customer data
- Credit-limit amounts and account approvals
- EDI provider and customer electronic-order identifiers

Provider-specific identifiers must be stored as alternate identifiers or integration configuration. They never replace PFD's Party, Customer, Address, or Location keys.

## 42. Approved Next Step

After review of this specification, the next deliverable is the **PFD Party and Customer PostgreSQL Build SQL Package**, containing the cumulative manifest, permanent changes `0011` through `0022`, reference CSVs, verification, behavioral tests, and operating documentation.
