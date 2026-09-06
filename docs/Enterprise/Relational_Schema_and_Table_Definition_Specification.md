# Relational Schema and Table Definition Specification

**Document date:** September 4, 2026  
**Document status:** Authoritative logical-to-physical relational schema specification  
**Governing documents:**

- `Business_Model_and_Operating_Policies.md`
- `Business_to_IT_Capability_Specification.md`
- `Information_Model_and_Record_Ownership_Specification.md`
- `Business_Process_and_Transaction_Lifecycle_Specification.md`
- `Persistent_Data_Architecture_and_Database_Standards_Specification.md`

---

## 1. Purpose

This specification defines the PostgreSQL schemas and normalized tables at the design level.

For each table or table family, it establishes:

- Business purpose
- Columns and PostgreSQL data types
- Primary and alternate keys
- Foreign-key relationships
- Required and optional values
- Check and unique constraints
- Continuous-business scope and any technical Simulation Session relationship
- Effective-date and audit behavior
- Expected indexes
- Retention classification

This document is sufficiently precise to guide executable DDL, but it is not itself a migration script.

---

## 2. Relational Conventions

### 2.1 Identifier conventions

- All identifiers use lowercase `snake_case`.
- Table names are singular.
- Operational primary keys are stable natural business numbers or governed composite business keys.
- Primary-key columns use the actual business name, such as `customer_number`, `product_number`, or `sales_order_number`.
- Foreign keys reuse the complete referenced natural key.
- Issued business keys are permanent and never reused.
- Surrogate identity keys are prohibited throughout the design; technical records use governed natural or composite technical keys.
- SQL identifiers do not require quoting.

### 2.2 Standard exact types

| Meaning | PostgreSQL type |
|---|---|
| Business code/number | `text` with explicit validation |
| Name/description | `text` |
| Quantity | `numeric(18,4)` |
| Money | `numeric(19,4)` |
| Rate/percentage as decimal fraction | `numeric(12,8)` |
| Weight | `numeric(18,4)` |
| Cube/volume | `numeric(18,6)` |
| Calendar/business date | `date` |
| Actual instant | `timestamptz` |
| Time of day | `time` |
| Duration | `interval` |
| Boolean | `boolean` |
| Versioned external payload | `jsonb` only where expressly allowed |

### 2.3 Common column profiles

The profiles below are shorthand in this document. Executable DDL expands every profile into ordinary columns and constraints.

#### Profile M — Mutable master/configuration

| Column | Type | Null | Meaning |
|---|---|---:|---|
| `created_at` | `timestamptz` | No | Creation instant |
| `created_by_principal_code` | `text` | No | FK to `core.principal` |
| `updated_at` | `timestamptz` | No | Latest update instant |
| `updated_by_principal_code` | `text` | No | FK to `core.principal` |
| `row_version` | `bigint` | No | Optimistic concurrency version, initially 1 |

Each table definition supplies its natural primary key. Profile M never creates an implicit identifier.

#### Profile B — Operational business master

Profile M applied to the continuing business database. Business-master rows are not partitioned by Simulation Session. Each definition supplies a permanent natural primary key.

#### Profile T — Operational transaction header

| Column | Type | Null | Meaning |
|---|---|---:|---|
| `business_date` | `date` | No | Operating date |
| `status_code` | `text` | No | FK to domain status table |
| `created_at` | `timestamptz` | No | Creation instant |
| `created_by_principal_code` | `text` | No | Creator |
| `updated_at` | `timestamptz` | No | Latest mutable update |
| `updated_by_principal_code` | `text` | No | Latest updater |
| `row_version` | `bigint` | No | Concurrency version |

Each transaction definition supplies a permanent document number as its primary key. The transaction is part of the single continuing business history.

#### Profile L — Transaction line

| Column | Type | Null | Meaning |
|---|---|---:|---|
| `<header>_number` | `text` | No | FK to header natural primary key |
| `line_number` | `integer` | No | Line identity within header |

Primary key is `(<header>_number, line_number)`. Downstream references carry both columns; no separate line identifier is added.

#### Profile E — Append-only event/history

| Column | Type | Null | Meaning |
|---|---|---:|---|
| `<event>_number` or governed composite event key | `text` or composite | No | Natural primary key |
| `occurred_at` | `timestamptz` | No | Actual event instant |
| `business_date` | `date` | Conditional | Required for business events |
| `principal_code` | `text` | No | Responsible human/process |

Event rows are append-only after commit. Technical scheduler attempts use `(scheduled_at, event_sequence, attempt_number)` and may reference a Simulation Session; resulting business transactions retain only their ordinary business keys and dates.

### 2.6 Authoritative natural-key rules

These rules govern every compact table definition below:

- A master or document with a governed `*_number` uses that number as its primary key.
- A code-defined master uses its governed `*_code` as its primary key.
- A header line uses `(header_number, line_number)`.
- An effective-dated relationship uses the complete parent natural keys plus `effective_from`.
- A repeated event or activity uses the owning natural key plus a governed sequence number.
- A junction uses the complete natural keys of both parents, adding effective date or sequence only when multiple historical rows are valid.
- Foreign keys repeat every column of the referenced natural or composite primary key.
- Nullable values are not primary-key components; when a dimensional balance requires an explicit not-applicable member, a controlled value such as `NO_LOT`, `NO_PALLET`, or `NO_DEPARTMENT` is used.
- Descriptions, names, statuses, amounts, quantities, and mutable timestamps are never primary-key components.

Where a compact definition says “Profile M,” “Profile B,” “Profile T,” or names a relationship without restating its key, these rules supply the key. No implicit `*_id` column exists.

### 2.4 Effective dating

Effective-dated tables use:

- `effective_from timestamptz NOT NULL`
- `effective_through timestamptz NULL`
- `CHECK (effective_through IS NULL OR effective_through > effective_from)`

The effective interval is `[effective_from, effective_through)`.

### 2.5 Retention codes

| Code | Meaning |
|---|---|
| R1 | Permanent/company archival |
| R2 | Financial—seven completed fiscal years minimum |
| R3 | Food safety—seven years or longer requirement |
| R4 | Employment plus seven years or longer requirement |
| R5 | Routine operational—three years minimum |
| R6 | Audit/security—seven years for control events; otherwise three |
| R7 | Published management information—seven years |

---

## 3. Schema Dependency Order

The normal DDL creation order is:

1. `core`
2. `party`
3. `simulation`
4. Deferred `core`/`party` natural-key foreign keys
5. `hr` foundation
6. `product`
7. `sales`
8. `credit`
9. `purchasing`
10. `inventory`
11. `warehouse`
12. `transport`
13. `quality`
14. `service`
15. `finance`
16. Remaining cross-domain foreign keys
17. `reporting`
18. `audit`

Circular business dependencies are resolved by creating base tables first and adding selected foreign keys in a later migration. Referential integrity is not omitted.

---

## 4. Reference-Table Standard

Every domain status/classification table uses this normalized structure unless specifically overridden:

| Column | Type | Null | Rule |
|---|---|---:|---|
| `<code_name>` | `text` | No | Primary key; stable uppercase business code |
| `display_name` | `text` | No | User-facing name |
| `description` | `text` | Yes | Business meaning |
| `sort_order` | `integer` | No | Display and workflow order |
| `is_active` | `boolean` | No | Default true |
| `effective_from` | `date` | No | Active start |
| `effective_through` | `date` | Yes | Open-ended when null |

Codes are never repurposed. Referenced inactive codes remain present.

---

## 5. `core` Schema

### 5.1 `core.principal`

Identifies a human, service, scheduled process, migration, or recovery actor.

| Column | Type | Null | Constraint/meaning |
|---|---|---:|---|
| `principal_code` | `text` | No | PK; stable human/process code |
| `principal_type_code` | `text` | No | FK to `core.principal_type` |
| `display_name` | `text` | No | Audit display name |
| `external_subject` | `text` | Yes | Authentication-system identity |
| `is_active` | `boolean` | No | Default true |
| `created_at` | `timestamptz` | No | — |

Constraints/indexes: unique nonnull `external_subject`; index active principals by type. Retention R6.

### 5.2 `core.company`

Profile M plus:

| Column | Type | Null | Meaning |
|---|---|---:|---|
| `company_code` | `text` | No | Stable configured natural key; public sample may use `<company abbreviation>` |
| `legal_name` | `text` | No | Configured legal name |
| `display_name` | `text` | No | Report/customer-facing name |
| `default_currency_code` | `text` | No | `USD` |
| `business_timezone` | `text` | No | `America/New_York` |
| `fiscal_year_start_month` | `smallint` | No | 1 for calendar year |
| `is_active` | `boolean` | No | — |

PK `company_code`. Check month 1–12. Retention R1. The schema defines this structure but does not supply a named Company row; the selected opening dataset supplies and validates business identity.

### 5.3 `core.facility`

Profile B plus:

| Column | Type | Null | Meaning |
|---|---|---:|---|
| `facility_number` | `text` | No | PK; permanent business number |
| `company_code` | `text` | No | FK to Company |
| `facility_name` | `text` | No | — |
| `address_number` | `text` | No | FK to `party.address` added later |
| `facility_type_code` | `text` | No | Combined office/distribution center |
| `total_square_feet` | `numeric(18,2)` | No | Opening 50,000 |
| `warehouse_square_feet` | `numeric(18,2)` | No | Opening 45,000 |
| `office_square_feet` | `numeric(18,2)` | No | Opening 5,000 |
| `is_active` | `boolean` | No | — |

Constraints: positive areas; component areas not greater than total. Retention R1.

### 5.4 `core.warehouse_zone`

Profile B plus `facility_number text`, `zone_code text`, `zone_name text`, `storage_class_code text`, `temperature_min numeric(7,2) NULL`, `temperature_max numeric(7,2) NULL`, `is_food_storage boolean`, `is_active boolean`.

PK `(facility_number, zone_code)` with FK to Facility; temperature maximum not below minimum. Index Facility/storage class. Retention R1.

### 5.5 `core.warehouse_location`

Profile B plus `location_code text`, `facility_number text`, `zone_code text`, `location_type_code text`, `capacity_cases numeric(18,4) NULL`, `capacity_weight numeric(18,4) NULL`, `capacity_cube numeric(18,6) NULL`, `allows_mixed_product boolean`, `allows_mixed_lot boolean`, `is_active boolean`.

PK `location_code`; composite FK `(facility_number, zone_code)` to Warehouse Zone; nonnegative capacities. Index Zone/type/active. Retention R1.

### 5.6 `core.operating_calendar_day`

Columns: `calendar_date date`, `business_day_type_code text`, `office_open_time time NULL`, `office_close_time time NULL`, `order_cutoff_time time NULL`, `is_delivery_day boolean`, `notes text NULL`, plus Profile M audit columns.

PK `calendar_date`. Check close after open. Index business-day type and delivery day. Retention R5.

### 5.7 `core.shift_definition`

Profile B plus `shift_code text`, `shift_name text`, `start_time time`, `end_time time`, `crosses_midnight boolean`, `is_active boolean`.

PK `shift_code`. Opening codes `FIRST`, `SECOND`, `THIRD`. Retention R1.

### 5.8 `core.fulfillment_cycle`

Profile T plus `fulfillment_cycle_number text`, `originating_order_date date`, `planned_delivery_date date`, `second_shift_start_at timestamptz NULL`, `third_shift_start_at timestamptz NULL`, `planned_dispatch_at timestamptz NULL`, `completed_at timestamptz NULL`.

PK `fulfillment_cycle_number`; unique originating-order-date cycle as applicable. Check delivery date after order date. Index status/planned delivery. Retention R2.

### 5.9 `core.unit_of_measure`

Profile M plus `unit_code text`, `unit_name text`, `unit_class_code text`, `decimal_scale smallint`, `is_active boolean`.

PK `unit_code`; scale 0–4. Opening examples: case, pack, each, pallet. Retention R1.

### 5.10 `core.approval_authority`

Profile M plus `authority_code text`, `business_area_code text`, `transaction_type_code text`, `role_code text`, `minimum_amount numeric(19,4) NULL`, `maximum_amount numeric(19,4) NULL`, effective-date columns, `required_approval_count smallint`, `is_active boolean`.

PK `(authority_code, effective_from)`. Amount and approval-count checks. Index active business area/transaction type. Retention R6.

### 5.11 `core.number_sequence`

Columns: `sequence_code text PK`, `prefix text NULL`, `next_value bigint NOT NULL`, `display_width smallint NOT NULL`, `updated_at timestamptz`, `row_version bigint`.

Check positive next value and display width. Row locked during allocation. Retention R1.

### 5.12 Core reference tables

`core.principal_type`, `core.facility_type`, `core.location_type`, `core.storage_class`, `core.business_day_type`, and `core.unit_class` follow the Reference-Table Standard. Retention R1.

---

## 6. `party` Schema

### 6.1 `party.person`

Profile M plus `person_number text PK`, `first_name text`, `middle_name text NULL`, `last_name text`, `preferred_name text NULL`, `suffix text NULL`, `is_active boolean`.

Index normalized last/first name for lookup. Person does not contain payroll or authentication secrets. Retention depends on role; minimum R4 for employees/owners.

### 6.2 `party.address`

Profile M plus `address_number text PK`, `address_line_1 text`, `address_line_2 text NULL`, `city text`, `state_province_code text`, `postal_code text`, `country_code text`, `latitude numeric(10,7) NULL`, `longitude numeric(10,7) NULL`, `validation_status_code text`, `is_active boolean`.

Index postal code and city/state. Retention follows referencing record.

### 6.3 `party.contact_method`

Profile M plus `person_number text`, `contact_type_code text`, `contact_sequence smallint`, `contact_value text`, `is_primary boolean`, `is_verified boolean`, `verified_at timestamptz NULL`, `is_active boolean`. PK `(person_number, contact_type_code, contact_sequence)`.

Check verified timestamp if verified. Index Person/type and normalized value where appropriate. Retention follows party relationship.

### 6.4 Party reference tables

`party.contact_type`, `party.address_validation_status`, and `party.country` follow the reference standard. State/province may use a normalized reference table or validated code list. Retention R1.

---

## 7. `simulation` Schema

The schema contains technical execution controls only. No operational business table carries a Simulation Session key.

### 7.1 `simulation.simulation_configuration`

Columns: `configuration_code text`, `version_number integer`, `effective_at timestamptz`, `configuration jsonb`, `configuration_checksum text`, `created_at timestamptz`, `created_by_principal_code text`. PK `(configuration_code, version_number)`. Immutable after use. Retention R1.

### 7.2 `simulation.simulation_session`

Profile M plus `simulation_session_number text PK`, `configuration_code text`, `configuration_version_number integer`, `session_name text`, `random_seed bigint NULL`, `session_status_code text`, `business_timezone text`, `business_clock_start_at timestamptz`, `business_clock_end_at timestamptz NULL`, `current_business_at timestamptz`, `started_at timestamptz NULL`, `paused_at timestamptz NULL`, `completed_at timestamptz NULL`, `failed_at timestamptz NULL`, `started_by_principal_code text`, `application_version text`, `schema_version text`, `diagnostic_summary text NULL`. FK `(configuration_code, configuration_version_number)`. Check timestamp/status consistency. Retention R5.

### 7.3 `simulation.random_stream`

Columns: `simulation_session_number text`, `stream_name text`, `derived_seed bigint`, `draw_count bigint`, `stream_state jsonb NULL`, plus Profile M audit fields. PK `(simulation_session_number, stream_name)`. Retention R5.

### 7.4 `simulation.random_draw`

Columns: `simulation_session_number text`, `stream_name text`, `draw_sequence bigint`, `distribution_code text`, `input_parameters jsonb`, `result_value numeric(30,12) NULL`, `result_payload jsonb NULL`, `source_event_scheduled_at timestamptz NULL`, `source_event_sequence bigint NULL`, `occurred_at timestamptz`. PK `(simulation_session_number, stream_name, draw_sequence)`. Append-only. Retention R5.

### 7.5 `simulation.scheduled_event`

Columns: `scheduled_at timestamptz`, `event_sequence bigint`, `simulation_session_number text NULL`, `event_type_code text`, `status_code text`, `source_type_code text NULL`, `source_business_key jsonb NULL`, `payload_version integer`, `payload jsonb NULL`, `claimed_at timestamptz NULL`, `claimed_by_principal_code text NULL`, `completed_at timestamptz NULL`, `cancelled_at timestamptz NULL`, `failure_count integer`, `last_error text NULL`, plus Profile M audit fields. PK `(scheduled_at, event_sequence)`. Index pending status/time/sequence. Retention R5.

### 7.6 `simulation.event_attempt`

Columns: `scheduled_at timestamptz`, `event_sequence bigint`, `attempt_number integer`, `started_at timestamptz`, `completed_at timestamptz NULL`, `result_code text NULL`, `error_text text NULL`, `principal_code text`. PK `(scheduled_at, event_sequence, attempt_number)`. Append-only. Retention R5.

### 7.7 `simulation.session_checkpoint`

Columns: `simulation_session_number text`, `checkpoint_number bigint`, `business_clock_at timestamptz`, `event_sequence bigint`, `checkpoint_type_code text`, `state_checksum text`, `created_at timestamptz`, `created_by_principal_code text`. PK `(simulation_session_number, checkpoint_number)`. This is technical restart evidence, not a business-data snapshot. Retention R5.

### 7.8 Simulation reference tables

`simulation.session_status`, `simulation.event_type`, `simulation.event_status`, `simulation.random_distribution`, and `simulation.checkpoint_type` follow the reference standard.

---

## 8. `hr` Foundation Tables

### 8.1 `hr.department`

Profile B plus `department_code text`, `department_name text`, `manager_employee_number text NULL`, `is_active boolean`.

PK `department_code`. Manager FK added after Employee. Retention R4.

### 8.2 `hr.position`

Profile B plus `position_code text`, `position_name text`, `department_code text`, `pay_basis_code text`, `is_safety_sensitive boolean`, `is_active boolean`.

PK `position_code`. Index department/active. Retention R4.

### 8.3 `hr.employee`

Profile B plus `employee_number text`, `person_number text`, `employment_status_code text`, `hire_date date`, `termination_date date NULL`, `full_time_equivalent numeric(5,4)`, `is_owner boolean`, `default_department_code text NULL`, `default_position_code text NULL`.

PK `employee_number`; unique Person for active employment as appropriate. Check termination not before hire and FTE 0–1. Index status/department. Retention R4.

### 8.4 `hr.employee_principal`

Columns: `employee_number text`, `principal_code text`, effective-date columns, `is_primary boolean`, audit fields.

PK `(employee_number, principal_code, effective_from)`. Prevent overlapping primary links. Retention R6.

### 8.5 `hr.employee_assignment`

Profile B plus `employee_number text`, `department_code text`, `position_code text`, `manager_employee_number text NULL`, effective dates, `assignment_status_code text`.

Prevent overlapping primary assignments. Index employee/effective dates and department/position. Retention R4.

### 8.6 `hr.compensation_rate`

Profile B plus `employee_number text`, `pay_basis_code text`, `rate_amount numeric(19,4)`, `annualized_amount numeric(19,4) NULL`, effective dates, `approved_by_principal_code text`.

Positive rate; no overlapping active base rates. Restricted. Retention R4.

### 8.7 `hr.qualification` and `hr.employee_qualification`

`qualification`: Profile M plus `qualification_code`, `qualification_name`, `requires_expiration boolean`, `is_active`.

`employee_qualification`: Profile B plus `employee_number`, `qualification_code`, `issued_date`, `expiration_date NULL`, `status_code`, `evidence_document_number NULL`, audit fields.

Unique active qualification per employee/type/issue. Index expiration/status. Retention R4.

### 8.8 HR reference tables

`hr.employment_status`, `hr.assignment_status`, `hr.pay_basis`, `hr.qualification_status`, and `hr.department_type` follow the reference standard.

---

## 9. `product` Schema

### 9.1 `product.product_category`

Profile B plus `product_category_code text`, `category_name text`, `parent_category_code text NULL`, `is_food boolean`, `is_active boolean`.

PK `product_category_code`. Self-FK prevents cycles through controlled validation. Retention R1.

### 9.2 `product.product`

Profile B plus `product_number text PK`, `sku text`, `product_name text`, `brand_name text NULL`, `product_category_code text`, `stocking_unit_code text`, `standard_selling_unit_code text`, `is_food boolean`, `requires_lot_control boolean`, `requires_expiration_control boolean`, `allows_split_pack boolean`, `product_status_code text`.

PK `product_number`; unique `sku`. Index category/status/name. Retention R1.

### 9.3 `product.product_pack`

Profile B plus `product_pack_code text PK`, `product_number text`, `unit_code text`, `contained_stocking_quantity numeric(18,4)`, `is_full_case boolean`, `is_split_pack boolean`, `weight numeric(18,4) NULL`, `weight_unit_code text NULL`, `cube numeric(18,6) NULL`, `barcode text NULL`, `is_active boolean`.

PK `product_pack_code`; unique Product/Unit/contained quantity; positive quantities. No catch-weight flag exists. Index barcode if used. Retention R1.

### 9.4 `product.storage_requirement`

Profile B plus `product_number text`, `storage_class_code text`, `temperature_min numeric(7,2) NULL`, `temperature_max numeric(7,2) NULL`, `requires_food_separation boolean`, `special_instructions text NULL`, effective dates.

Prevent overlapping primary requirements. Temperature check. Retention R3.

### 9.5 `product.shelf_life_rule`

Profile B plus `product_number text`, `date_type_code text`, `minimum_days_at_receipt integer NULL`, `minimum_days_at_shipment integer NULL`, `warning_days integer NULL`, effective dates.

Nonnegative days; shipment minimum not greater than receipt minimum when both known. Retention R3.

### 9.6 `product.product_substitute`

Profile B plus `original_product_number text`, `substitute_product_number text`, `substitution_rank smallint`, `requires_customer_approval boolean`, `difference_notes text NULL`, effective dates, `is_active boolean`.

Products must differ. Unique active original/substitute relationship. Index original/rank. Retention R2.

### 9.7 `product.supplier_product`

Profile B plus `supplier_product_code text`, `supplier_number text`, `product_number text`, `supplier_item_number text`, `purchasing_unit_code text`, `case_pack_quantity numeric(18,4)`, `minimum_order_quantity numeric(18,4) NULL`, `lead_time_days integer`, `source_priority smallint`, `is_primary_source boolean`, `is_active boolean`.

PK `supplier_product_code`; unique Supplier/Product/purchasing unit. Positive pack and lead time. Index product/source priority and supplier/item number. Retention R2.

### 9.8 `product.supplier_cost`

Profile B plus `supplier_product_code text`, `unit_cost numeric(19,4)`, `freight_amount numeric(19,4)`, `allowance_amount numeric(19,4)`, `currency_code text`, effective dates, `approved_by_principal_code text`.

Nonnegative components. Prevent overlapping active cost periods for same relationship. Index supplier product/effective dates. Retention R2.

### 9.9 Price tables

`product.price_list`: Profile B plus `price_list_code`, `price_list_name`, `currency_code`, effective dates, `is_active`.

`product.product_price`: Profile B plus `price_list_code`, `product_pack_code`, `unit_price numeric(19,4)`, effective dates.

`product.customer_price`: Profile B plus `customer_number`, `customer_location_number NULL`, `product_pack_code`, `unit_price`, `source_contract_number NULL`, effective dates, `approved_by_principal_code`.

`product.contract_price`: Profile B plus `customer_contract_number`, `product_pack_code NULL`, `product_category_code NULL`, `unit_price`, `minimum_quantity NULL`, effective dates.

Constraints prevent overlapping equivalent price rows. Exactly one contract target—Product Pack or Category—is set. Index lookup precedence by Customer/Location/Product/effective dates. Retention R2.

### 9.10 Pricing control tables

`product.split_pack_premium`: Profile B plus `product_number NULL`, `customer_number NULL`, `premium_rate numeric(12,8)`, effective dates, approval. Default opening rate 0.15; most-specific applicable row wins.

`product.margin_rule`: Profile B plus `customer_segment_code NULL`, `product_category_code NULL`, `minimum_margin_rate`, effective dates, approval.

`product.price_override`: Profile T plus `price_override_number text PK`, `sales_order_number text`, `sales_order_line_number integer`, `original_unit_price`, `override_unit_price`, `reason_code`, `requested_by`, `approved_by NULL`, `approved_at NULL`, `expires_at NULL`.

Retention R2/R6.

### 9.11 Product reference tables

`product.product_status`, `product.date_type`, `product.price_override_reason`, and `product.price_source_type` follow the reference standard.

---

## 10. `sales` Customer Tables

### 10.1 `sales.customer_segment`

Reference table with opening codes for restaurant, hotel, school, healthcare, and correctional institution. Retention R1.

### 10.2 `sales.customer`

Profile B plus `customer_number text`, `legal_name text`, `trade_name text NULL`, `customer_segment_code text`, `billing_address_number text`, `assigned_salesperson_employee_number text`, `customer_status_code text`, `opened_date date`, `closed_date date NULL`, `default_price_list_code text NULL`.

PK `customer_number`. Index status/segment/salesperson and normalized name. Retention R2.

### 10.3 `sales.customer_location`

Profile B plus `customer_location_number text`, `customer_number text`, `location_name text`, `address_number text`, `location_status_code text`, `route_territory_code text`, `requires_appointment boolean`, `delivery_instructions text NULL`, `opened_date date`, `closed_date date NULL`.

PK `customer_location_number`; unique `(customer_number, location_name)` where appropriate. Index Customer/status/territory. Retention R2.

### 10.4 `sales.customer_contact`

Profile B plus `customer_number text`, `customer_location_number text NULL`, `person_number text`, `contact_role_code text`, `may_place_order boolean`, `may_approve_substitution boolean`, `may_receive_delivery boolean`, effective dates, `is_active boolean`.

Index customer/location/role and Person. Retention R2.

### 10.5 `sales.customer_sales_assignment`

Profile B plus `customer_number text`, `salesperson_employee_number text`, `is_primary boolean`, effective dates.

Prevent overlapping primary assignment. Index salesperson/effective dates. Retention R2.

### 10.6 `sales.customer_delivery_schedule`

Profile B plus `customer_location_number text`, `weekday smallint`, `receiving_start_time time`, `receiving_end_time time`, `normal_delivery_frequency_code text`, `route_pattern_code text NULL`, effective dates.

Weekday 1–7; end after start. Index weekday/route. Retention R5.

### 10.7 `sales.customer_preference`

Profile B plus `customer_number text`, `customer_location_number text NULL`, `product_number text NULL`, `product_category_code text NULL`, `preference_type_code text`, `preference_value text`, effective dates.

Exactly one Product or Category when product-specific. Retention R2.

### 10.8 `sales.customer_contract`

Profile B plus `customer_contract_number text`, `customer_number text`, `contract_name text`, `contract_status_code text`, `effective_from date`, `effective_through date NULL`, `minimum_order_amount numeric(19,4) NULL`, `payment_term_code text NULL`, `document_number text NULL`.

PK `customer_contract_number`. Date and amount checks. Index Customer/status/effective dates. Retention R2.

### 10.9 Customer onboarding tables

`sales.customer_onboarding_review`: Profile T plus `customer_number`, `commercial_status_code`, `credit_status_code`, `tax_status_code`, `operations_status_code`, `completed_at NULL`.

`sales.sales_activity`: Profile E plus `sales_activity_number text PK`, `customer_number`, `contact_person_number NULL`, `salesperson_employee_number`, `activity_type_code`, `summary`, `follow_up_at NULL`.

Retention R2/R5.

### 10.10 Sales reference tables

`sales.customer_status`, `sales.customer_location_status`, `sales.contact_role`, `sales.contract_status`, `sales.preference_type`, `sales.delivery_frequency`, `sales.onboarding_status`, and `sales.sales_activity_type` follow the reference standard.

---

## 11. `sales` Order Tables

### 11.1 `sales.sales_order`

Profile T plus:

| Column | Type | Null | Meaning |
|---|---|---:|---|
| `sales_order_number` | `text` | No | PK; permanent order number |
| `customer_number` | `text` | No | FK to Customer |
| `customer_location_number` | `text` | No | Must belong to Customer |
| `order_type_code` | `text` | No | Standard/standing/emergency/etc. |
| `order_channel_code` | `text` | No | Authorized channel |
| `ordered_at` | `timestamptz` | No | Actual receipt/entry instant |
| `requested_delivery_date` | `date` | No | Customer request |
| `scheduled_delivery_date` | `date` | Yes | Set during validation |
| `fulfillment_cycle_number` | `text` | Yes | Required before release |
| `salesperson_employee_number` | `text` | No | Commercial owner |
| `ordering_contact_person_number` | `text` | Yes | Authorized contact Person |
| `currency_code` | `text` | No | USD |
| `subtotal_amount` | `numeric(19,4)` | No | Maintained/reconciled |
| `charge_amount` | `numeric(19,4)` | No | Delivery/other charges |
| `total_amount` | `numeric(19,4)` | No | Reconciled document total |
| `released_at` | `timestamptz` | Yes | — |
| `completed_at` | `timestamptz` | Yes | — |

PK `sales_order_number`. Index status/delivery date, Customer/date, Fulfillment Cycle. Retention R2.

### 11.2 `sales.sales_order_line`

Columns: `sales_order_number text`, `line_number integer`, `product_pack_code text`, `ordered_quantity numeric(18,4)`, `unit_code text`, `unit_price numeric(19,4)`, `price_source_type_code text`, approved nullable pricing-source natural-key columns, `discount_amount numeric(19,4)`, `premium_amount numeric(19,4)`, `extended_amount numeric(19,4)`, `expected_unit_cost numeric(19,4)`, `expected_margin_amount numeric(19,4)`, `line_status_code text`, `requested_product_number text`, `fulfilled_product_number text NULL`, `created_at`, `updated_at`, `row_version`. PK `(sales_order_number, line_number)`.

Unique order/line number. Positive quantity; nonnegative price; extended amount reconciliation. Index Product/status and fulfilled Product. Retention R2.

### 11.3 `sales.order_change`

Profile E plus `order_change_number text PK`, `sales_order_number`, `sales_order_line_number NULL`, `change_type_code`, `prior_values jsonb`, `new_values jsonb`, `reason_code`, `requested_by_principal_code`, `approved_by_principal_code NULL`.

Append-only. JSON permitted as historical change evidence, not authoritative current order data. Retention R2/R6.

### 11.4 `sales.order_hold`

Profile T plus `order_hold_number text PK`, `sales_order_number`, `sales_order_line_number NULL`, `hold_type_code`, `hold_reason_code`, `blocking_scope_code`, `opened_at`, `resolved_at NULL`, `resolved_by_principal_code NULL`, `resolution_code NULL`, `notes NULL`.

Partial index open holds by order/type. Retention R2/R6.

### 11.5 `sales.backorder`

Profile T plus `backorder_number text PK`, `originating_sales_order_number`, `originating_line_number`, `backorder_quantity`, `unit_code`, `planned_delivery_date NULL`, `resolution_code NULL`, `replacement_sales_order_number NULL`, `replacement_line_number NULL`, `resolved_at NULL`.

Positive quantity. Index open backorders by Customer/Product/date through joins or maintained keys if justified. Retention R2.

### 11.6 `sales.substitution_decision`

Profile T plus `substitution_decision_number text PK`, `sales_order_number`, `sales_order_line_number`, `original_product_number`, `substitute_product_number`, `substitute_product_pack_code`, `requested_quantity`, `requires_customer_approval`, `contact_person_number NULL`, `customer_decision_code NULL`, `decided_at NULL`, `notes NULL`.

Original and substitute must differ. Retention R2.

### 11.7 Order reference tables

`sales.order_status`, `sales.order_line_status`, `sales.order_type`, `sales.order_channel`, `sales.order_hold_type`, `sales.hold_resolution`, `sales.backorder_resolution`, and `sales.substitution_decision_code` follow the reference standard.

---

## 12. `credit` Schema

### 12.1 `credit.credit_profile`

Profile B plus `customer_number text`, `payment_term_code text`, `credit_limit numeric(19,4)`, `risk_class_code text`, `review_date date`, `profile_status_code text`, effective dates, `approved_by_principal_code text`.

Prevent overlapping active profiles. Nonnegative limit. Restricted. Retention R2.

### 12.2 `credit.credit_review`

Profile T plus `credit_review_number text PK`, `customer_number`, `prior_credit_limit`, `recommended_credit_limit`, `approved_credit_limit NULL`, `risk_class_code`, `evidence_summary`, `next_review_date`, `approved_by_principal_code NULL`, `approved_at NULL`.

Index Customer/review date/status. Retention R2/R6.

### 12.3 `credit.credit_hold`

Profile T plus `credit_hold_number text PK`, `customer_number`, `customer_location_number NULL`, `sales_order_number NULL`, `hold_reason_code`, `opened_at`, `review_at NULL`, `released_at NULL`, `released_by_principal_code NULL`, `release_reason NULL`.

At least one scope target. Partial index active holds by Customer/Order. Retention R2/R6.

### 12.4 `credit.credit_exception`

Profile T plus `credit_exception_number text PK`, `customer_number`, `sales_order_number NULL`, `temporary_limit_amount NULL`, `authorized_order_amount NULL`, `expires_at`, `reason`, `approved_by_principal_code`, `approved_at`.

Positive amounts; expiration after approval. Retention R2/R6.

### 12.5 Collection tables

`credit.collection_case`: Profile T plus `collection_case_number text PK`, `customer_number`, `assigned_employee_number`, `exposure_amount`, `priority_code`, `next_action_at NULL`, `resolved_at NULL`.

`credit.collection_activity`: Profile E plus `collection_case_number`, `activity_sequence`, `contact_person_number NULL`, `activity_type_code`, `outcome_code`, `notes`, `next_action_at NULL`. PK `(collection_case_number, activity_sequence)`.

`credit.promise_to_pay`: Profile T plus `promise_to_pay_number text PK`, `collection_case_number`, `promised_amount`, `promised_date`, `fulfilled_amount`, `fulfilled_at NULL`, `outcome_code NULL`.

`credit.customer_dispute`: Profile T plus `customer_dispute_number text PK`, `customer_number`, `ar_open_item_number`, `disputed_amount`, `reason_code`, `opened_at`, `resolved_at NULL`, `resolution_code NULL`, `approved_adjustment_number NULL`.

`credit.credit_loss_assessment`: Profile T plus `credit_loss_assessment_number text PK`, `accounting_period_code`, `customer_number NULL`, `assessment_method_code`, `exposure_amount`, `loss_rate`, `expected_loss_amount`, approval.

Retention R2.

### 12.6 Credit reference tables

Payment terms are defined in `finance.payment_term`. Credit-specific tables include `credit.risk_class`, `credit.profile_status`, `credit.hold_reason`, `credit.collection_priority`, `credit.collection_activity_type`, `credit.collection_outcome`, `credit.promise_outcome`, `credit.dispute_reason`, and `credit.dispute_resolution`.

---

## 13. `purchasing` Schema

### 13.1 Supplier masters

`purchasing.supplier`: Profile B plus `supplier_number`, `legal_name`, `trade_name NULL`, `supplier_status_code`, `primary_address_number`, `opened_date`, `closed_date NULL`. Primary key is the stated business number; index status/name. R2.

`purchasing.supplier_location`: Profile B plus `supplier_location_number`, `supplier_number`, `location_type_code`, `location_name`, `address_number`, `is_active`. Primary key is the stated business number. R2.

`purchasing.supplier_contact`: Profile B plus `supplier_number`, `supplier_location_number NULL`, `person_number`, `contact_role_code`, effective dates, `is_active`. R2.

`purchasing.supplier_approval`: Profile T plus `supplier_approval_number text PK`, `supplier_number`, `approval_scope_code`, `approval_status_code`, `approved_at NULL`, `expires_at NULL`, `approved_by_principal_code NULL`, `evidence_document_number NULL`. Index Supplier/status/expiry. R3.

`purchasing.supplier_terms`: Profile B plus `supplier_number`, `payment_term_code`, `discount_rate NULL`, `discount_days NULL`, `net_days`, `freight_term_code`, `remittance_address_number`, effective dates, approval. Prevent overlap. R2.

### 13.2 Purchase planning

`purchasing.purchase_recommendation`: Profile T plus `purchase_recommendation_number text PK`, `product_number`, `supplier_product_code NULL`, `recommended_quantity`, `unit_code`, `need_by_date`, `projected_available_quantity`, `safety_stock_quantity`, `forecast_quantity`, `reason_code`. Index open Product/date. R5.

`purchasing.purchase_recommendation_decision`: Profile E plus `purchase_recommendation_number`, `decision_sequence`, `decision_code`, `decided_quantity NULL`, `supplier_product_code NULL`, `reason`, `resulting_purchase_order_number NULL`, `resulting_purchase_order_line_number NULL`. PK `(purchase_recommendation_number, decision_sequence)`. R5.

### 13.3 `purchasing.purchase_order`

Profile T plus `purchase_order_number text`, `supplier_number`, `supplier_location_number NULL`, `ship_to_facility_number`, `buyer_employee_number`, `ordered_at`, `expected_delivery_date`, `currency_code`, `payment_term_code`, `freight_term_code`, `subtotal_amount`, `freight_amount`, `total_amount`, `approved_at NULL`, `sent_at NULL`, `closed_at NULL`.

Primary key is the stated business number. Index Supplier/status/date and expected receipt date. R2.

### 13.4 `purchasing.purchase_order_line`

Columns: `purchase_order_number text`, `line_number integer`, `supplier_product_code text`, `product_number text`, `ordered_quantity`, `purchasing_unit_code`, `unit_cost`, `extended_cost`, `expected_delivery_date`, `received_quantity`, `cancelled_quantity`, `line_status_code`, timestamps/version. PK `(purchase_order_number, line_number)`.

Unique PO/line. Quantity and amount checks. Index Product/status/date. Stored received/cancelled summaries reconcile to Receipt/Change data. R2.

### 13.5 Purchase follow-up

`purchasing.supplier_acknowledgement`: Profile T plus `purchase_order_number`, `supplier_reference`, `acknowledged_at`, `promised_delivery_date`, `acknowledged_total`, `has_exception`. R2.

`purchasing.purchase_order_change`: Profile E plus `purchase_order_number`, `change_sequence`, `purchase_order_line_number NULL`, `change_type_code`, `prior_values jsonb`, `new_values jsonb`, `reason`, `approved_by_principal_code`. PK `(purchase_order_number, change_sequence)`. R2/R6.

`purchasing.purchase_commitment`: Profile B plus `purchase_order_number`, `purchase_order_line_number`, `open_quantity`, `expected_cash_amount`, `expected_payment_date`, `commitment_status_code`, `as_of_at`. PK `(purchase_order_number, purchase_order_line_number)`. R2.

`purchasing.supplier_performance`: Profile T plus `supplier_number`, `period_start`, `period_end`, `ordered_line_count`, `fill_rate`, `on_time_rate`, `rejection_rate`, `damage_rate`, `quality_incident_count`, `score`. PK `(supplier_number, period_start, period_end)`. R7.

`purchasing.supplier_claim`: Profile T plus `supplier_claim_number text PK`, `supplier_number`, `receipt_number NULL`, `supplier_invoice_number NULL`, `claim_type_code`, `claim_amount`, `opened_at`, `resolved_at NULL`, `resolution_code NULL`, `supplier_credit_number NULL`. R2/R3.

### 13.6 Purchasing reference tables

`purchasing.supplier_status`, `purchasing.supplier_location_type`, `purchasing.contact_role`, `purchasing.approval_scope`, `purchasing.approval_status`, `purchasing.freight_term`, `purchasing.purchase_recommendation_reason`, `purchasing.recommendation_decision`, `purchasing.purchase_order_status`, `purchasing.purchase_order_line_status`, `purchasing.purchase_change_type`, `purchasing.commitment_status`, `purchasing.claim_type`, and `purchasing.claim_resolution` follow the reference standard.

---

## 14. `inventory` Schema

### 14.1 `inventory.inventory_lot`

Profile B plus `inventory_lot_number text PK`, `product_number`, `supplier_number`, `receipt_number`, `receipt_line_number`, `supplier_lot_number NULL`, `manufactured_date NULL`, `expiration_date NULL`, `best_by_date NULL`, `lot_status_code`, `received_at`, `original_quantity`, `unit_code`.

PK `inventory_lot_number`; unique Product/Supplier/lot number when supplied. Date consistency checks. Index Product/expiration/status. R3.

### 14.2 `inventory.pallet`

Profile B plus `pallet_number`, `current_location_code`, `pallet_status_code`, `received_at`, `emptied_at NULL`.

PK `pallet_number`. Index location/status. A Pallet may contain multiple Lot balances but quantity remains in Inventory Balance. R5.

### 14.3 `inventory.inventory_balance`

Columns: `facility_number`, `warehouse_location_code`, `product_number`, `product_pack_code`, `inventory_lot_number text` using `NO_LOT` when lot control does not apply, `pallet_number text` using `NO_PALLET` when pallet identity does not apply, `inventory_status_code`, `on_hand_quantity numeric(18,4)`, `allocated_quantity numeric(18,4)`, `row_version`, `updated_at`.

PK `(facility_number, warehouse_location_code, product_number, product_pack_code, inventory_lot_number, pallet_number, inventory_status_code)`. Reserved nonnull natural tokens avoid nullable PK components. Nonnegative quantities; allocation not greater than eligible on-hand. Index availability by Product/status/expiration through Lot and by Location. R2/R3.

### 14.4 `inventory.inventory_movement`

Profile E plus `inventory_movement_number text`, `product_number`, `product_pack_code`, `inventory_lot_number NULL`, `pallet_number NULL`, `quantity`, `unit_code`, `source_location_code NULL`, `destination_location_code NULL`, `source_status_code NULL`, `destination_status_code NULL`, `movement_type_code`, `source_transaction_type_code`, `source_transaction_number`, `idempotency_key text`.

PK `inventory_movement_number` and unique idempotency key. At least one source/destination; nonzero quantity. Append-only. Index Product/time, source transaction, locations/time. R2/R3.

### 14.5 `inventory.inventory_allocation`

Profile T plus `inventory_allocation_number text PK`, `sales_order_number`, `sales_order_line_number`, `product_number`, `product_pack_code`, the complete nullable Inventory Balance key, `allocated_quantity`, `fulfilled_quantity`, `released_quantity`, `allocation_priority`, `expires_at NULL`.

Quantity reconciliation checks. Index active allocation by Product/balance and Order Line. R2.

### 14.6 `inventory.pick_slot_placement`

Profile E plus `warehouse_location_code`, `inventory_lot_number NULL`, `pallet_number NULL`, `product_number`, `quantity_placed`, `unit_code`, `inventory_movement_number`, `depleted_at NULL`.

Index location/Product/depleted/expiration and placement time. R3.

### 14.7 Count and adjustment tables

`inventory.inventory_count`: Profile T plus `inventory_count_number`, `facility_number`, `count_type_code`, `scope_code`, `scheduled_at`, `started_at NULL`, `completed_at NULL`, `approved_at NULL`. PK `inventory_count_number`. R2.

`inventory.inventory_count_line`: `inventory_count_number`, `line_number`, complete Inventory Balance key columns, `recorded_quantity`, `counted_quantity NULL`, `variance_quantity NULL`, `counted_by_principal_code NULL`, `counted_at NULL`. PK `(inventory_count_number, line_number)`. R2.

`inventory.inventory_recount`: Profile E plus `inventory_count_number`, `inventory_count_line_number`, `recount_sequence`, `recounted_quantity`, `recounted_by_principal_code`, `reason`. PK `(inventory_count_number, inventory_count_line_number, recount_sequence)`. R2.

`inventory.inventory_adjustment`: Profile T plus `adjustment_number text PK`, `inventory_count_number NULL`, `inventory_count_line_number NULL`, complete Inventory Balance key, `adjustment_quantity`, `unit_cost`, `adjustment_amount`, `reason_code`, `approved_by_principal_code NULL`, `inventory_movement_number NULL`, `journal_entry_number NULL`. R2/R6.

### 14.8 `inventory.inventory_disposition`

Profile T plus `disposition_number text PK`, `inventory_lot_number NULL`, complete Inventory Balance key, `quantity`, `disposition_type_code`, `reason_code`, `authorized_by_principal_code`, `customer_number NULL`, `supplier_claim_number NULL`, `proceeds_amount`, `inventory_movement_number NULL`, `journal_entry_number NULL`, `completed_at NULL`.

Primary key is the stated business number. Positive quantity. Required relationship varies by disposition. R2/R3.

### 14.9 `inventory.fifo_valuation_layer`

Columns: `receipt_number`, `receipt_line_number`, `valuation_layer_sequence`, `product_number`, `product_pack_code`, `acquired_at`, `original_quantity`, `remaining_quantity`, `unit_cost`, `currency_code`, `layer_status_code`, `updated_at`, `row_version`. PK `(receipt_number, receipt_line_number, valuation_layer_sequence)`.

Unique receipt line/Product Pack as appropriate. Nonnegative remaining <= original. Index Product/status/acquired time. R2.

### 14.10 Inventory reference tables

`inventory.inventory_status`, `inventory.lot_status`, `inventory.pallet_status`, `inventory.movement_type`, `inventory.source_transaction_type`, `inventory.count_type`, `inventory.count_scope`, `inventory.adjustment_reason`, `inventory.disposition_type`, `inventory.disposition_reason`, and `inventory.valuation_layer_status` follow the reference standard.

---

## 15. `warehouse` Schema

### 15.1 Receiving tables

`warehouse.receiving_appointment`: Profile T plus `appointment_number`, `supplier_number`, `facility_number`, `scheduled_start_at`, `scheduled_end_at`, `dock_location_code NULL`, `expected_pallets NULL`, `expected_cases NULL`, `purchase_order_count`, `arrived_at NULL`. Primary key is the stated business number; index Facility/time/status. R5.

`warehouse.receiving_appointment_purchase_order`: `receiving_appointment_number`, `purchase_order_number`; composite PK. R5.

`warehouse.inbound_shipment`: Profile T plus `inbound_shipment_number`, `supplier_number`, `carrier_name NULL`, `vehicle_numberentifier NULL`, `seal_number NULL`, `arrived_at`, `dock_location_code`, `receiving_appointment_number NULL`. R3.

`warehouse.receipt`: Profile T plus `receipt_number`, `inbound_shipment_number`, `supplier_number`, `facility_number`, `started_at`, `completed_at NULL`, `receiver_employee_number`, totals for presented/accepted/rejected/held. Primary key is the stated business number. R2/R3.

`warehouse.receipt_line`: Receipt Number, line number, PO Number/line number, Product, Pack, presented/accepted/rejected/held/short/over quantities, Unit, Lot numbers/dates, and result code. PK `(receipt_number, line_number)`. Quantity reconciliation. Index PO Line/Product. R2/R3.

`warehouse.receipt_inspection`: Profile E plus `receipt_number`, `receipt_line_number`, `inspection_sequence`, `inspection_type_code`, `observed_value text NULL`, `numeric_value numeric(18,4) NULL`, `result_code`, `notes NULL`. PK `(receipt_number, receipt_line_number, inspection_sequence)`. R3.

`warehouse.receiving_discrepancy`: Profile T plus `receiving_discrepancy_number text PK`, `receipt_number`, `receipt_line_number`, `discrepancy_type_code`, `quantity`, `estimated_amount NULL`, `assigned_role_code`, `resolved_at NULL`, `resolution_code NULL`. R2/R3.

### 15.2 Putaway/replenishment tables

`warehouse.putaway_work`: Profile T plus `putaway_work_number text PK`, `receipt_number`, `receipt_line_number`, `inventory_lot_number NULL`, `pallet_number NULL`, `source_location_code`, `destination_location_code`, `planned_quantity`, `completed_quantity`, `assigned_employee_number NULL`, `started_at NULL`, `completed_at NULL`, `inventory_movement_number NULL`. R5.

`warehouse.replenishment_work`: Profile T plus `product_number`, `product_pack_code`, `inventory_lot_number NULL`, `pallet_number NULL`, `source_location_code`, `destination_location_code`, `planned_quantity`, `completed_quantity`, `priority_code`, `is_emergency`, assignment/timing/movement fields. Index status/priority/destination. R5.

### 15.3 Fulfillment work tables

`warehouse.warehouse_work_batch`: Profile T plus `work_batch_number`, `fulfillment_cycle_number`, `shift_code`, `work_type_code`, `route_number NULL`, `released_at NULL`, `completed_at NULL`. Primary key is the stated business number. R5.

`warehouse.warehouse_work_task`: Profile T plus `warehouse_work_batch_number`, `task_type_code`, `priority`, `assigned_employee_number NULL`, `source_location_code NULL`, `destination_location_code NULL`, `planned_start_at NULL`, `started_at NULL`, `completed_at NULL`. Index batch/status/priority and employee/status. R5.

`warehouse.pick_work`: Profile T plus `pick_work_number text PK`, `warehouse_work_batch_number`, `warehouse_work_task_number`, `sales_order_number`, `sales_order_line_number`, `inventory_allocation_number`, complete Inventory Balance key, `directed_location_code`, `directed_quantity`, `unit_code`, `directed_lot_number NULL`, `is_split_pack`. R2/R5.

`warehouse.pick_result`: Profile E plus `pick_work_number`, `result_code`, `actual_product_number`, `actual_product_pack_code`, `actual_lot_number NULL`, `actual_quantity`, `inventory_movement_number NULL`, `exception_number NULL`. R2/R3.

`warehouse.stage_assignment`: Profile T plus `sales_order_number`, `route_number`, `route_stop_number NULL`, `staging_location_code`, `assigned_at`, `released_at NULL`. Unique active order assignment. R5.

### 15.4 Loading tables

`warehouse.load_plan`: Profile T plus `load_plan_number`, `route_number`, `truck_number`, `fulfillment_cycle_number`, `planned_start_at`, `ready_at NULL`, `approved_by_principal_code NULL`, `approved_at NULL`. PK `load_plan_number`; unique active Route. R2/R5.

`warehouse.load_line`: Load Plan Number, line number, Sales Order Number/line number, Product Pack, quantity, Unit, Truck Compartment, loaded quantity, and status. PK `(load_plan_number, line_number)`. Index Order Line and compartment. R2/R5.

`warehouse.load_reconciliation`: Profile T plus `load_plan_number`, planned/picked/staged/loaded/variance totals, `reconciled_by_principal_code`, `reconciled_at`, `approved_by_principal_code NULL`, `approved_at NULL`. One final approved reconciliation per Load Plan. R2/R6.

### 15.5 Warehouse reference tables

`warehouse.appointment_status`, `warehouse.receipt_status`, `warehouse.receipt_line_result`, `warehouse.inspection_type`, `warehouse.inspection_result`, `warehouse.discrepancy_type`, `warehouse.discrepancy_resolution`, `warehouse.work_type`, `warehouse.task_type`, `warehouse.work_status`, `warehouse.work_priority`, `warehouse.pick_result_code`, and `warehouse.load_status` follow the reference standard.

---

## 16. `transport` Schema

### 16.1 Fleet tables

`transport.truck`: Profile B plus `truck_number`, `vehicle_identification_number`, `license_plate`, `truck_status_code`, `model_year`, `manufacturer`, `model`, `gross_capacity_weight`, `capacity_cube`, `odometer`, `fixed_asset_number NULL`, `debt_instrument_number NULL`, `is_normal_route_truck`, `is_spare`. PK `truck_number`; unique VIN and license plate. R1/R2.

`transport.truck_compartment`: Profile B plus `truck_number`, `compartment_number`, `storage_class_code`, `capacity_weight`, `capacity_cube`, `temperature_min NULL`, `temperature_max NULL`, `is_active`. Unique Truck/number. R2.

`transport.vehicle_inspection`: Profile T plus `truck_number`, `driver_employee_number`, `inspection_type_code`, `inspected_at`, `result_code`, `odometer`, `temperature_ready`, `notes NULL`. Index Truck/date/result. R5.

`transport.maintenance_plan`: Profile B plus `truck_number`, `maintenance_type_code`, `interval_miles NULL`, `interval_days NULL`, `next_due_odometer NULL`, `next_due_date NULL`, `is_active`. R2.

`transport.maintenance_event`: Profile T plus `truck_number`, `maintenance_plan_code NULL`, `maintenance_type_code`, `started_at`, `completed_at NULL`, `provider_supplier_number NULL`, `odometer`, `cost_amount`, `fixed_asset_improvement_number NULL`, `notes`. R2.

### 16.2 Route tables

`transport.route_pattern`: Profile B plus `route_pattern_code`, `route_name`, `territory_code`, `normal_weekday NULL`, `estimated_miles`, `estimated_duration`, `is_active`. Primary key is the stated business code. R5.

`transport.route_pattern_location`: `route_pattern_code`, `customer_location_number`, `effective_from`, `normal_stop_sequence NULL`, and `effective_through NULL`; PK `(route_pattern_code, customer_location_number, effective_from)`. Prevent overlapping active location/day assignments. R5.

`transport.daily_route`: Profile T plus `route_number`, `route_date`, `route_pattern_code NULL`, `truck_number`, `driver_employee_number`, `fulfillment_cycle_number`, planned/actual departure/return timestamps, planned/actual miles, status. PK `route_number`; unique active Truck/date assignment. Index date/status/driver. R2/R5.

`transport.route_stop`: `route_number`, `stop_number`, `customer_location_number`, receiving window, planned/actual arrival/completion, and status. PK `(route_number, stop_number)`; index Location/date. R2/R5.

`transport.dispatch_record`: Profile E plus `route_number`, `load_plan_number`, `truck_number`, `driver_employee_number`, `authorized_by_principal_code`, `departed_at`, `document_count`, `notes NULL`. One active departure per Route unless redispatch explicitly modeled. R2.

### 16.3 Delivery tables

`transport.delivery`: Profile T plus `delivery_number`, `route_stop_number`, `customer_number`, `customer_location_number`, `arrived_at NULL`, `completed_at NULL`, `delivery_result_code`, `receiver_name_snapshot NULL`. Primary key is the stated business number. Index Customer/date/result. R2.

`transport.delivery_sales_order`: `delivery_number` + `sales_order_number`; composite PK. R2.

`transport.delivery_line`: Delivery Number/line number, Sales Order Number/line number, Product Pack, loaded/delivered/refused/damaged/short quantity, Unit, and result code. PK `(delivery_number, line_number)` with quantity reconciliation. R2.

`transport.proof_of_delivery`: Profile E plus `delivery_number`, `proof_sequence`, `received_by_name`, `received_by_person_number NULL`, `acknowledgement_type_code`, `document_number NULL`, `notes NULL`. PK `(delivery_number, proof_sequence)`. R2.

`transport.delivery_exception`: Profile T plus `delivery_exception_number text PK`, `delivery_number`, `delivery_line_number NULL`, `exception_type_code`, `quantity NULL`, `severity_code`, `customer_service_case_number NULL`, `resolved_at NULL`, `resolution_code NULL`. R2/R3.

`transport.driver_return`: Profile T plus `driver_return_number text PK`, `route_number`, `delivery_number`, `delivery_line_number`, `product_pack_code`, `inventory_lot_number NULL`, `quantity`, `unit_code`, `return_reason_code`, `return_location_code`, `received_by_employee_number NULL`, `received_at NULL`, `inventory_movement_number NULL`. R2/R3.

`transport.route_cost`: Profile T plus `route_number`, `cost_type_code`, `quantity NULL`, `unit_cost NULL`, `amount`, `source_transaction_type NULL`, `source_transaction_number NULL`. Index Route/cost type. R2.

### 16.4 Transport reference tables

`transport.truck_status`, `transport.inspection_type`, `transport.inspection_result`, `transport.maintenance_type`, `transport.route_status`, `transport.route_stop_status`, `transport.delivery_result`, `transport.delivery_line_result`, `transport.delivery_exception_type`, `transport.exception_severity`, `transport.delivery_exception_resolution`, `transport.return_reason`, `transport.route_cost_type`, and `transport.acknowledgement_type` follow the reference standard.

---

## 17. `quality` Schema

### 17.1 `quality.quality_hold`

Profile T plus `hold_number`, `hold_reason_code`, nullable scope FKs for Product, Lot, Balance, Location, Supplier, Receipt, `opened_at`, `released_at NULL`, `released_by_principal_code NULL`, `disposition_code NULL`.

At least one scope target. Partial indexes active holds by Product/Lot/Location. R3/R6.

### 17.2 `quality.temperature_observation`

Profile E plus `temperature_observation_number text PK`, nullable `facility_number`, `warehouse_zone_code`, `truck_number`, `truck_compartment_code`, `receipt_number`, `receipt_line_number`, `delivery_number`, `product_number`, `observed_temperature numeric(7,2)`, `temperature_unit_code`, `minimum_allowed NULL`, `maximum_allowed NULL`, `result_code`.

At least one subject. Index failed results/time/subject. R3.

### 17.3 Sanitation and pest-control tables

`quality.sanitation_task`: Profile B plus `facility_number`, `warehouse_zone_code NULL`, `task_code`, `task_name`, `frequency_code`, `responsible_role_code`, `is_active`. R3.

`quality.sanitation_completion`: Profile E plus `sanitation_task_number`, `scheduled_at`, `completed_at`, `result_code`, `finding_text NULL`, `verified_by_principal_code NULL`, `corrective_action_number NULL`. Unique task/scheduled occurrence. R3.

`quality.pest_control_activity`: Profile E plus `facility_number`, `warehouse_zone_code NULL`, `provider_supplier_number NULL`, `activity_type_code`, `result_code`, `finding_text NULL`, `corrective_action_number NULL`. R3.

### 17.4 Incident and recall tables

`quality.food_safety_incident`: Profile T plus `incident_number`, `incident_type_code`, `severity_code`, `reported_at`, `reported_by_principal_code`, `product_number NULL`, `supplier_number NULL`, `receipt_number NULL`, `delivery_number NULL`, `description`, `assessment`, `closed_at NULL`. R3.

`quality.corrective_action`: Profile T plus `corrective_action_number text PK`, `source_type_code`, `source_business_key`, `assigned_principal_code`, `action_description`, `due_at`, `completed_at NULL`, `verified_by_principal_code NULL`, `verified_at NULL`. R3/R6.

`quality.product_recall`: Profile T plus `recall_number`, `recall_type_code`, `initiating_supplier_number NULL`, `opened_at`, `scope_description`, `risk_description`, `closed_at NULL`, `approved_closed_by_principal_code NULL`. R3.

`quality.recall_product`: Recall/Product with optional Lot/date scope; composite identity. R3.

`quality.recall_exposure`: Profile T plus `product_recall_number`, `customer_number NULL`, `customer_location_number NULL`, `product_number`, `shipment_start_at`, `shipment_end_at`, `estimated_quantity NULL`, `estimation_method`, `confidence_code`. Explicitly estimated; no exact customer-Lot FK. R3.

`quality.recall_communication`: Profile E plus Recall, `communication_sequence`, party/customer/supplier target, contact method, message summary, acknowledgement time. PK `(product_recall_number, communication_sequence)`. R3.

`quality.recall_effectiveness_review`: Profile T plus Recall, inventory reconciled flag, communication complete flag, corrective action complete flag, review summary, reviewed/approved principals and times. PK `product_recall_number`; one final review per Recall. R3.

### 17.5 Quality reference tables

`quality.hold_reason`, `quality.temperature_unit`, `quality.observation_result`, `quality.sanitation_frequency`, `quality.sanitation_result`, `quality.pest_activity_type`, `quality.incident_type`, `quality.severity`, `quality.recall_type`, and `quality.exposure_confidence` follow the reference standard.

---

## 18. `service` Schema

`service.customer_service_case`: Profile T plus `case_number`, `customer_number`, `customer_location_number NULL`, `sales_order_number NULL`, `delivery_number NULL`, `invoice_number NULL`, `case_type_code`, `priority_code`, `assigned_employee_number`, `opened_at`, `target_resolution_at NULL`, `resolved_at NULL`, `closed_at NULL`. Primary key is the stated business number. R2/R5.

`service.case_activity`: Profile E plus Case, `activity_sequence`, activity type, Customer Contact NULL, notes, next action time NULL. PK `(customer_service_case_number, activity_sequence)`. R2/R5.

`service.return_authorization`: Profile T plus `return_authorization_number`, Case, Customer, Delivery Line NULL, Product Pack, authorized quantity, reason code, authorized_at, expires_at NULL. R2/R3.

`service.return_receipt`: Profile T plus `return_receipt_number text PK`, Return Authorization, Driver Return NULL, received quantity, location, receiver, received_at. R2/R3.

`service.return_inspection`: Profile E plus Return Receipt, `inspection_sequence`, package/seal/temperature/condition results, `is_resalable`, notes. PK `(return_receipt_number, inspection_sequence)`. R2/R3.

`service.return_disposition`: Profile T plus `return_disposition_number text PK`, Return Receipt, disposition type, quantity, destination location NULL, Supplier Claim NULL, Inventory Movement NULL, completed_at NULL. R2/R3.

`service.customer_credit_request`: Profile T plus `customer_credit_request_number text PK`, Case, Invoice/Invoice Line, requested amount, reason, requested by, resolution status. R2.

`service.credit_approval`: Profile T plus `credit_approval_number text PK`, Customer Credit Request, approved amount, decision, approved by, approved at, resulting Credit Memo NULL. R2/R6.

`service.root_cause_assignment`: Profile T plus `root_cause_assignment_number text PK`, Case, cause type, optional Product/Supplier/Employee/Truck/Route references, summary, Corrective Action NULL. R5.

Reference tables: case status/type/priority, activity type, return reason, condition result, disposition type, credit decision, root-cause type. Retention follows parent.

---

## 19. `finance` Foundation and General Ledger

### 19.1 Reference and account tables

`finance.currency`: ISO-like currency code PK, name, decimal places, active dates. R1.

`finance.payment_term`: term code PK, name, net days, discount days NULL, discount rate NULL, active dates. Opening Net 30 and approved Net 45/COD/prepaid. R1.

`finance.gl_account`: Profile B plus `account_number`, `account_name`, `account_type_code`, `normal_balance_code`, `parent_account_number NULL`, `is_control_account`, `allows_manual_posting`, `is_active`. PK `account_number`. R1.

`finance.accounting_period`: Profile B plus `accounting_period_code`, `fiscal_year`, `period_index`, `start_date`, `end_date`, `period_status_code`, close/reopen principals and times. PK `accounting_period_code`; unique `(fiscal_year, period_index)`. R1.

### 19.2 Journal tables

`finance.journal_entry`: Profile T plus `journal_entry_number`, `accounting_period_code`, `accounting_date`, `entry_type_code`, `source_type_code`, `source_business_key`, `source_event_key`, `description`, `currency_code`, `total_debit`, `total_credit`, `approved_by_principal_code NULL`, `approved_at NULL`, `posted_at NULL`, `reverses_journal_number NULL`. PK `journal_entry_number`; unique source event key. R1/R2.

`finance.journal_line`: Journal Entry Number, line number, GL Account, debit amount, credit amount, optional department/customer/supplier/Product/route/fixed-asset dimensions, and description. PK `(journal_entry_number, line_number)`. Check one-sided positive amount and balanced entry through posting control. R1/R2.

`finance.posting_batch`: Profile T plus `posting_batch_number`, source area, accounting period, entry count, debit/credit totals, posted_at NULL. Primary key is the stated business number. R2.

`finance.posting_batch_entry`: Batch/Journal composite PK. R2.

### 19.3 Reconciliation and close

`finance.reconciliation`: Profile T plus `reconciliation_number`, `accounting_period_code`, `reconciliation_type_code`, `control_account_number NULL`, `subsidiary_amount`, `control_amount`, `difference_amount`, `prepared_by`, `reviewed_by NULL`, `reviewed_at NULL`, `unresolved_notes NULL`. R2/R6.

`finance.close_task`: Profile T plus Accounting Period, task type, assigned Principal, due at, completed at NULL, evidence document NULL, approved by NULL. PK `(accounting_period_code, close_task_type_code)`. R2/R6.

Reference tables: account type, normal balance, period status, journal status/type/source, reconciliation type, close task type. R1/R2.

---

## 20. `finance` Customer Billing and AR

`finance.customer_invoice`: Profile T plus `invoice_number`, `customer_number`, `customer_location_number`, `delivery_number`, `invoice_date`, `due_date`, `currency_code`, `subtotal_amount`, `charge_amount`, `tax_amount`, `total_amount`, `delivered_amount`, `posted_amount`, `printed_at`, `pending_delivery_at`, `finalized_at`, `posted_at`, and `payment_terms_snapshot`. Primary key is the stated business number and normally one primary Invoice per Delivery. R2.

`finance.customer_invoice_line`: Invoice Number/line number, Delivery Number/line number, Sales Order Number/line number, Product Pack, Product description snapshot, quantity, Unit, unit price, discount, premium, extended amount, expected/actual cost, and revenue GL Account. PK `(invoice_number, line_number)`. R2.

`finance.credit_memo`: Profile T plus `credit_memo_number`, Customer, Invoice, Customer-Service Case NULL, memo date, reason code, amount, approved by, posted at NULL. Primary key is the stated business number. R2.

`finance.credit_memo_line`: Credit Memo Number/line number, optional Invoice Number/line number, Product Pack NULL, quantity NULL, amount, revenue/expense account, and disposition link NULL. PK `(credit_memo_number, line_number)`. R2.

`finance.debit_memo`: Profile T plus number, Customer, Invoice NULL, reason, amount, approval, posted at. R2.

`finance.ar_open_item`: Profile B plus Customer, source type/id, document number, document date, due date, original amount, open amount, disputed amount, status. Unique source business key. Index Customer/status/due date. R2.

`finance.customer_receipt`: Profile T plus `customer_receipt_number`, Customer, received date/time, payment method, reference, currency, amount, Bank Account, deposit identifier NULL, posted at NULL. PK `customer_receipt_number`; unique controlled external reference where reliable. R2.

`finance.receipt_application`: Profile E plus Customer Receipt, `application_sequence`, AR Open Item, applied amount, application type, reversed application NULL. PK `(customer_receipt_number, application_sequence)`. Amount positive; total applications not above Receipt without controlled unapplied balance. R2.

`finance.ar_adjustment`: Profile T plus `ar_adjustment_number text PK`, Customer, AR Open Item NULL, adjustment type, amount, reason, approval, Journal Entry NULL. R2/R6.

Reference tables: invoice status, invoice line status, AR item source/status, payment method, receipt application type, credit/debit reason, AR adjustment type. R2.

---

## 21. `finance` Supplier Billing and AP

`finance.supplier_invoice`: Profile T plus `ap_invoice_number`, `supplier_number`, `supplier_invoice_number`, `invoice_date`, `received_date`, `due_date`, `discount_date NULL`, payment terms, currency, subtotal/freight/tax/total, undisputed amount, disputed amount, and `posted_at NULL`. PK `ap_invoice_number`; unique `(supplier_number, supplier_invoice_number)`. R2.

`finance.supplier_invoice_line`: AP Invoice Number/line number, PO Number/line number NULL, expense/asset/Product reference as applicable, description, quantity NULL, Unit NULL, unit cost NULL, amount, and GL Account. PK `(ap_invoice_number, line_number)`. R2.

`finance.match_result`: Profile T plus `match_result_number text PK`, Supplier Invoice Line, PO Line NULL, accepted Receipt quantity/cost totals, invoice quantity/cost, quantity variance, price variance, result code, matched at/by. One current final result plus history through status/audit. R2.

`finance.match_receipt_line`: Match Result/Receipt Line/quantity matched; composite key. R2.

`finance.match_exception`: Profile T plus `match_exception_number text PK`, Match Result, exception type, amount/quantity, assigned role, resolution code NULL, resolved at/by NULL. R2/R6.

`finance.supplier_dispute`: Profile T plus `supplier_dispute_number text PK`, Supplier Invoice, Match Exception NULL, disputed amount, opened at, contact/activity summary, resolved at NULL, resolution code NULL, Supplier Credit NULL. R2.

`finance.ap_open_item`: Profile B plus Supplier, source type/id, document number/date, due/discount dates, original/open/disputed amounts, status. Unique source business key. Index Supplier/status/due/discount. R2.

`finance.payment_proposal`: Profile T plus proposal number, proposed payment date, Bank Account, currency, total, discount amount, prepared/approved fields. R2/R6.

`finance.payment_proposal_item`: Proposal/AP Open Item, proposed amount, discount amount, disputed amount held; composite key. R2.

`finance.supplier_payment`: Profile T plus supplier payment number, Supplier, Bank Account, payment date/method/reference, currency, amount, approved/released/posted fields. PK `supplier_payment_number`; unique controlled bank reference where reliable. R2.

`finance.supplier_payment_application`: Profile E plus Supplier Payment, `application_sequence`, AP Open Item, applied amount, discount amount. PK `(supplier_payment_number, application_sequence)`. R2.

`finance.supplier_credit`: Profile T plus credit number, Supplier, Supplier Invoice NULL, Supplier Claim NULL, credit date, amount, posted at. R2.

`finance.supplier_remittance`: Profile T plus Supplier Payment, document number NULL, generated at, delivery method, delivered at NULL. PK `supplier_payment_number`; one remittance per Payment. R2.

Reference tables: supplier invoice status, match result/exception/resolution, AP source/status, payment proposal status, supplier payment status/method, supplier dispute resolution. R2.

---

## 22. `finance` Cash, Debt, Equity, Assets, Budget

### 22.1 Banking and cash

`finance.bank_account`: Profile B plus account number token/masked representation, bank name, account type, currency, GL cash account, is restricted, status. Sensitive full credentials are not stored here. R2.

`finance.bank_transaction`: Profile T plus `bank_transaction_number text PK`, Bank Account, transaction date/time, bank reference, transaction type, amount, direction code, source type/natural business key, cleared date NULL. Unique bank/reference where reliable. R2.

`finance.bank_statement`: Profile T plus `bank_statement_number text PK`, Bank Account, statement start/end, opening/closing balance, document number, imported at. Unique Account/period. R2.

`finance.bank_reconciliation`: Profile T plus `bank_reconciliation_number text PK`, Bank Statement, book/statement balance, outstanding deposit/payment totals, difference, prepared/reviewed fields. R2/R6.

`finance.cash_forecast`: Profile T plus forecast number, as-of timestamp, horizon start/end, opening cash, inflow/outflow/ending amounts, minimum reserve, line availability, scenario assumptions checksum. R7.

### 22.2 Debt and equity

`finance.debt_instrument`: Profile B plus debt number, debt type, lender Supplier/party NULL, original principal, current principal, interest rate, origination/maturity dates, payment frequency, collateral description, status. R1/R2.

`finance.debt_schedule`: Profile B plus Debt Instrument, installment number, due date, beginning principal, principal due, interest due, ending principal, status, payment application NULL. Unique Debt/installment. R2.

`finance.credit_line_draw`: Profile T plus Debt Instrument, draw number, draw date, amount, emergency flag, reason, approved by NULL, Bank Transaction, Journal Entry. R2/R6.

`finance.owner`: Profile B plus Person, owner number, status. PK `owner_number`; unique Person. R1.

`finance.ownership_interest`: Profile B plus Owner, ownership rate, effective dates, approved decision reference. PK `(owner_number, effective_from)`. Prevent overlap; controlled total equals 1.0. R1.

`finance.owner_capital_transaction`: Profile T plus `owner_capital_transaction_number text PK`, Owner, transaction type, amount, asset number NULL, Bank Transaction NULL, approval reference, Journal Entry. R1/R2.

### 22.3 Fixed assets

`finance.fixed_asset`: Profile B plus asset number, asset class, description, acquisition/in-service dates, cost, salvage value, Facility/Location, custodian Employee NULL, status, Debt link NULL. Primary key is the stated business number. R1.

`finance.asset_component`: Profile B plus Fixed Asset, component number, description, cost, in-service date, useful life months. R1.

`finance.depreciation_schedule`: Profile B plus Fixed Asset/Component, method, depreciable basis, useful life months, start date, end date NULL, accumulated depreciation, status. PK `(fixed_asset_number, asset_component_code, start_date)` using `WHOLE_ASSET` when no component applies. R1/R2.

`finance.depreciation_entry`: Profile E plus Depreciation Schedule, Accounting Period, amount, Journal Entry. PK `(fixed_asset_number, asset_component_code, depreciation_start_date, accounting_period_code)`. R1/R2.

`finance.asset_transfer`: Profile E plus Fixed Asset, `transfer_sequence`, from/to Facility/Location/Custodian, reason. PK `(fixed_asset_number, transfer_sequence)`. R1.

`finance.asset_disposal`: Profile T plus Fixed Asset, disposal date/type, proceeds, accumulated depreciation, book value, gain/loss, approval, Journal Entry. PK `fixed_asset_number`; one completed disposal per Asset. R1.

`finance.asset_verification`: Profile T plus Fixed Asset, `verification_sequence`, observed date/location/custodian/condition, result, variance resolution. PK `(fixed_asset_number, verification_sequence)`. R1/R6.

### 22.4 Budget and forecast

`finance.budget`: Profile T plus budget number/name, fiscal year, version, approval reference, approved at, status. PK `budget_number`; unique fiscal year/version. R7.

`finance.budget_line`: Budget Number, Accounting Period Code, GL Account Number, Department Code using `NO_DEPARTMENT` when not applicable, amount, and notes. PK `(budget_number, accounting_period_code, gl_account_number, department_code)`. R7.

`finance.forecast`: Profile T plus forecast number/name, horizon, base Budget NULL, assumptions checksum, status, approved at/by. R7.

`finance.forecast_line`: Forecast Number, Accounting Period Code, GL Account Number, Department Code using `NO_DEPARTMENT` when not applicable, and amount. PK `(forecast_number, accounting_period_code, gl_account_number, department_code)`. R7.

Reference tables cover banking, transaction direction/type, debt type/status, ownership status, capital transaction type, asset class/status/disposal/depreciation, budget/forecast status. R1/R2/R7.

---

## 23. `hr` Scheduling, Time, and Payroll

`hr.work_schedule`: Profile T plus Employee, work date, Shift, Facility, scheduled start/end, planned hours, assignment type. PK `(employee_number, work_date, shift_code)` with overlap prevention. R4.

`hr.attendance_event`: Profile E plus Employee, `attendance_sequence`, Work Schedule NULL, attendance type, start/end timestamps, hours, reason code, approved by NULL. PK `(employee_number, business_date, attendance_sequence)`. R4.

`hr.time_entry`: Profile T plus `time_entry_number text PK`, Employee, Work Schedule NULL, work date, start/end, regular/overtime hours, Department, approved by/at NULL. No overlapping time; totals reconcile. R4.

`hr.leave_balance`: Profile B plus Employee, leave type, as-of date, accrued/used/adjusted/available hours. PK `(employee_number, leave_type_code, as_of_date)`. R4.

`hr.leave_transaction`: Profile E plus Employee, leave type, `leave_transaction_sequence`, hours, transaction type, source natural business key, resulting balance. PK `(employee_number, leave_type_code, business_date, leave_transaction_sequence)`. R4.

`hr.payroll_run`: Profile T plus payroll run number, pay period start/end, pay date, currency, employee count, gross/deduction/tax/net totals, approved/paid/posted/closed fields. PK `payroll_run_number`; unique pay period. R2/R4.

`hr.payroll_employee_result`: Payroll Run Number, Employee Number, regular/overtime hours, gross pay, employee tax, other deductions, employer tax, benefits, net pay, and status. PK `(payroll_run_number, employee_number)`. R2/R4.

`hr.payroll_result_component`: Result/component line, component type/code, quantity/rate/amount, liability Account NULL, expense Account NULL. Unique Result/line. R2/R4.

`hr.payroll_payment`: Profile T plus Payroll Run, Employee Result, Bank Transaction, payment method/reference, amount, paid at. PK `(payroll_run_number, employee_number)`. R2/R4.

`hr.payroll_liability`: Profile B plus Payroll Run, liability type, payee Supplier/party NULL, original/open amount, due date, status, AP/Open Item link NULL. PK `(payroll_run_number, liability_type_code, payee_business_key)`. R2/R4.

Reference tables: schedule status, assignment type, attendance type/reason, time status, leave type/transaction, payroll status, payroll component type, payroll payment method, payroll liability type/status. R4.

---

## 24. `reporting` Schema

`reporting.report_definition`: Profile M plus report code/name, owner role, definition version, parameter schema JSON, retention code, is active. JSON allowed for report parameter contract. R7.

`reporting.report_run`: Profile T plus `report_run_number text PK`, Report Definition, requested by, requested/completed times, parameters JSON, as-of time, source period, optional Simulation Session Number, status, row/control totals, error text NULL. R7.

`reporting.formal_report_snapshot`: Profile E plus Report Run, `snapshot_sequence`, document number, checksum, byte size, published by/at, supersedes snapshot NULL. PK `(report_run_number, snapshot_sequence)`. Immutable. R7.

`reporting.kpi_definition`: Profile M plus KPI code/name, owner role, formula description, source definition, unit, target direction, effective dates. R7.

`reporting.kpi_result`: Profile T plus KPI Definition, period/as-of time, dimension type/natural business key NULL, actual value, target value NULL, status code, source Report Run NULL. PK `(kpi_definition_code, accounting_period_code, dimension_type_code, dimension_business_key)` using controlled `TOTAL` values when no dimension applies. R7.

`reporting.management_action`: Profile T plus `management_action_number text PK`, KPI Result NULL, Report Run NULL, exception number NULL, assigned Principal, action, due at, completed/verified fields. R7.

Reference tables: report status, KPI status, target direction, management action status. R7.

---

## 25. `audit` Schema

`audit.audit_event`: Profile E plus `audit_event_number`, environment code, schema name, table name, row natural-key text, action code, correlation code, prior values JSON NULL, new values JSON NULL, reason NULL, approval decision number NULL, and optional Simulation Session Number. PK `audit_event_number`; append-only; indexes record/time, Principal/time, Session/time, and correlation. R6.

`audit.business_exception`: Profile T plus exception number, exception type, severity, source type/natural business key, blocked object type/natural business key NULL, assigned role/principal, opened/due/resolved/verified/closed times, and resolution. Primary key is the stated business number; partial index open severity/due. R6.

`audit.hold`: Profile T plus hold number, hold type, target type/natural business key, reason, opened by/at, released by/at NULL, release reason NULL. Partial index active target. R6.

`audit.approval_request`: Profile T plus request number, authority code/effective date, subject type/natural business key, requested by/at, amount NULL, due at NULL. R6.

`audit.approval_decision`: Profile E plus Approval Request, Principal, decision code, conditions NULL, rationale NULL. PK `(approval_request_number, principal_code)`. Multiple owner decisions allowed. R6.

`audit.override`: Profile E plus `override_number text PK`, authority code/effective date, subject type/natural business key, original rule/condition, override action, reason, approved by, expiration NULL. R6.

`audit.recovery_event`: Profile T plus recovery number, event type, outage start/end NULL, recovery start/end NULL, affected Simulation Session NULL, summary, reconciliation status, approved by NULL. R6.

`audit.recovery_item`: Recovery Event Number, item sequence, subject type and natural business key, prior status, recovery action, result status, and notes. PK `(recovery_event_number, item_sequence)`. R6.

Reference tables: audit action, exception type/severity/status, hold type/status, approval decision, recovery event/action/status. R6.

---

## 26. Document Metadata

`core.document`: Profile M plus `document_number text`, `document_type_code text`, `file_name text`, `media_type text`, `storage_reference text`, `byte_size bigint`, `checksum_algorithm text`, `checksum_value text`, `retention_code text`, `access_classification_code text`, `document_version integer`, `supersedes_document_number text NULL`, `is_active boolean`.

PK `document_number`; unique checksum/storage reference as appropriate. Binary content normally remains outside ordinary relational tables. R1–R7 according to document type.

`core.document_relationship`: Profile M plus `document_number`, `subject_type_code`, `subject_business_key`, `relationship_type_code`.

Unique Document/subject/relationship. Referential subject validation is enforced through controlled service logic because the subject spans schemas. R1–R7 follows Document.

---

## 27. Continuous-Business Foreign-Key Standard

Operational relationships use the parent's natural primary key without a Simulation Session column.

Examples:

- Sales Order carries `customer_number`.
- Sales Order Line carries `product_pack_code` and has PK `(sales_order_number, line_number)`.
- Purchase Order carries `supplier_number`.
- Receipt Line carries `(purchase_order_number, purchase_order_line_number)`.
- Inventory Balance carries Product, Pack, Lot, Pallet, Location, Facility, and status natural keys.
- Pick Work carries the complete Sales Order Line, Allocation, and Inventory Balance keys.
- Daily Route carries Truck Number, Employee Number, and Fulfillment Cycle Number.
- Delivery carries Customer Number and Customer Location Number.
- Customer Invoice carries Delivery Number and Customer Number.
- Journal Entry carries Accounting Period Code.

This standard makes the data model operate like a single real business. Simulation Session relationships are allowed only in technical execution, diagnostic, checkpoint, and audit records.

---

## 28. Polymorphic Source References

Some audit, event, accounting, document, and exception records refer to many possible source types.

Generic `(source_type_code, source_business_key)` pairs are allowed only when:

- A conventional foreign key cannot represent the polymorphic relationship.
- The owning service validates the referenced record.
- Source type is controlled reference data.
- A stable resolver exists.
- Integrity is covered by automated tests and reconciliation.

Ordinary business relationships use real foreign keys. Polymorphic references shall not be used merely to avoid normalized junction tables.

---

## 29. Required Partial and Composite Indexes

At minimum, detailed DDL shall include access-path review for:

| Table/family | Expected leading columns/predicate |
|---|---|
| Scheduled Event | Pending status, scheduled time, sequence |
| Sales Order | Status, scheduled delivery date |
| Sales Order | Customer, order date |
| Order Hold | Order; open only |
| Customer Price | Customer/Location, Product Pack, effective period |
| Inventory Balance | Product, status, Location/Lot |
| Inventory Allocation | Balance/Product; active only |
| Inventory Lot | Product, expiration date, status |
| Pick-Slot Placement | Location, Product, depleted status, placement time |
| Purchase Order | Supplier, status, expected date |
| Receipt Line | PO Line and Product |
| Warehouse Work | Status, priority, planned time |
| Daily Route | Route date, status, Truck/Driver |
| Route Stop | Route, stop number; Customer Location/date |
| Delivery | Customer, date/result |
| AR Open Item | Customer, open status, due date |
| AP Open Item | Supplier, open status, due/discount date |
| Journal Entry | Accounting Period, status; source event key |
| Payroll Run | Pay period/status |
| Business Exception | Open status, severity, due time |
| Audit Event | Session when applicable, table/row; Principal/time; correlation code |

Foreign-key columns are indexed when needed for joins, lifecycle processing, or parent restriction checks. Redundant indexes are omitted.

---

## 30. Mandatory Constraint Families

Detailed DDL shall enforce:

- Positive ordered, received, picked, delivered, payment, and disposition quantities where the transaction represents positive action
- Separate signed correction transactions where required
- Header/line amount reconciliation at finalization
- Presented = accepted + rejected + held for receipts, with shortage/overage interpreted against PO separately
- Loaded = delivered + refused + damaged + short/returned reconciliation as defined by delivery result
- Remaining FIFO quantity between zero and original quantity
- Allocated quantity between zero and eligible on-hand
- Date and timestamp ordering by lifecycle
- Effective-through after effective-from
- Exactly one or at least one target for scoped relationship records
- No self-substitution
- No overlapping active primary assignments, prices, costs, credit profiles, or ownership interests
- Journal debit/credit validity and balanced posting
- Closed-period posting prohibition
- Unique source-event posting and idempotency keys

---

## 31. Data Volume Assumptions

Opening operational planning assumes:

- 80 Customer Locations
- Approximately 3,000 active Products
- Approximately 60 approved Suppliers
- 45–50 Employees
- 6 Trucks
- Approximately 40–45 weekday delivery stops

The schema shall comfortably support at least ten times opening master and annual transaction volume without redesign. This is a sizing expectation, not a requirement to partition prematurely.

Fast-growing tables are expected to be Scheduled Event, Random Draw when enabled, Audit Event, Inventory Movement, Warehouse Work, Delivery Line, Journal Line, and status/history tables.

---

## 32. DDL Delivery Sequence

Executable DDL should be delivered in migrations grouped as follows:

1. Database prerequisites, roles, schemas, and core reference tables
2. Core natural keys, Principal, units, Company, and document metadata
3. Party and Simulation foundations
4. HR organization and Employee foundation
5. Product, Supplier, Customer, and Credit masters
6. Pricing and contract relationships
7. Sales Orders and Purchasing
8. Inventory ledger, balance, Lot, and allocation
9. Receiving and warehouse work
10. Fleet, routing, and delivery
11. Quality, service, and returns
12. Finance foundation, GL, AR, AP, cash, debt, equity, assets
13. Payroll transactions
14. Reporting and audit
15. Cross-domain foreign keys, deferred validations, views, and final indexes
16. Opening reference data and deterministic test fixtures

Each migration is transactional when PostgreSQL permits and is validated against an empty database and the immediately preceding supported schema version.

---

## 33. Design Decisions Locked by This Specification

1. All operational tables are normalized to at least 3NF unless an approved exception exists.
2. Functional PostgreSQL schemas define ownership boundaries.
3. Singular lowercase table names and lowercase `snake_case` columns are used.
4. Durable operational primary keys use stable natural business numbers, codes, or governed composites.
5. Issued business numbers and governed codes are the primary keys, not alternate keys beside surrogate IDs.
6. Operational tables are continuous across Simulation Sessions and contain no simulation partition key.
7. Mutable masters, transaction headers, lines, and append-only events use defined common profiles.
8. Business status codes use normalized reference tables.
9. Effective-dated relationships use inclusive start and exclusive end.
10. Inventory Movement is authoritative history; Inventory Balance is a reconciled current-state table.
11. Allocation is separate from physical inventory movement.
12. FEFO controls picking and FIFO controls valuation.
13. Exact Customer-to-Lot shipment linkage is not stored.
14. Customer Invoice is created before departure and posted after accepted Delivery.
15. AR, AP, inventory, payroll, assets, debt, and cash are normalized subsidiary ledgers reconciled to GL.
16. Journal Entry and Journal Line implement double-entry accounting.
17. Completed business and event history is not cascade-deleted.
18. Polymorphic references are limited to approved cross-domain infrastructure cases.
19. Reference, audit, retention, indexing, and constraint expectations are part of every table design.
20. Executable DDL will follow the migration order in this document.

---

## 34. Recommended Next Deliverable

The next deliverable should be the **PostgreSQL DDL and Migration Implementation Plan**.

It should define:

- Repository folders and SQL-file naming
- Migration tool and version-table convention
- Exact migration batches and dependencies
- PostgreSQL roles and privileges
- Reference-data seed strategy
- Constraint and trigger implementation order
- Test-database creation and reset workflow
- DDL validation, linting, and automated integration tests
- Opening business-data load sequence

After that plan is approved, executable migrations can be implemented safely in controlled increments.

---

## 35. Completion Status

This document completes the relational schema and table-definition layer as of September 4, 2026.

It establishes the authoritative table catalog, natural and composite keys, normalized relationships, data types, constraints, continuous-business scope, indexes, and retention expectations required for executable PostgreSQL DDL.
