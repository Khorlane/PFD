# Product PostgreSQL Build Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Physical database design; executable SQL not included  
**Build range:** Permanent changes `0023` through `0032`  
**Depends on:** Cumulative database design through change `0022`; Product Domain Specification

## 1. Purpose

Define the PostgreSQL structures and controls required to implement Product management. This is a design contract for a later SQL package; it does not modify a database.

## 2. Required Outcome

The build must provide normalized, effective-dated Product data for identity, descriptions, categories, brands, units, conversions, measurements, storage, handling, shelf life, lot control, identifiers, certifications, allergens, substitutions, customer restrictions, audit, reporting, and security.

`product.product` uses `product_number` as its primary key. No surrogate, identity, serial, UUID, or hidden substitute key is permitted.

## 3. Platform and Packaging

- PostgreSQL 15 or later on a supported release
- Existing `product`, `sales`, `party`, `core`, `quality`, `audit`, and `reporting` schemas
- Core Build through `0010` and Party/Customer design through `0022`
- Existing `btree_gist`, controlled number allocation, Principals, units, customers, and database-change history
- Cumulative manifest version `3.0.0`, containing immutable changes `0001–0022` and new changes `0023–0032`
- Each change runs transactionally under `pfd_database_owner` through the standard build runner

An existing database applies only pending changes. A clean database builds cumulatively through `0032`.

## 4. Standards

Identifiers use lowercase `snake_case`; governed codes use uppercase text matching `^[A-Z][A-Z0-9_]*$`. Names use `text` with explicit nonblank checks. Quantities use `numeric(19,6)`, money uses `numeric(19,4)`, dates use `date`, and events/effective instants use `timestamptz`.

Mutable tables use the established audit columns:

- `created_at`, `created_by_principal_code`
- `updated_at`, `updated_by_principal_code`
- positive `row_version`

Effective periods are half-open and cannot overlap for the same fact. Historical rows are closed or inactivated, not deleted.

## 5. Core Extensions

Change `0023` adds:

| Object | Required value |
|---|---|
| `core.number_sequence` | `PRODUCT`, no prefix, width 8, initial value 1 |
| `core.number_sequence` | `PRODUCT_AUDIT_EVENT`, prefix `PRE`, width 10, initial value 1 |
| `core.unit_class` | `LENGTH` |
| `core.unit_of_measure` | `INCH`, `FOOT` in `LENGTH` |

Product numbers therefore display as `00000001`. Assigned values are permanent and never reused. Cumulative verification must recognize the expanded Core unit baseline.

## 6. Reference Tables

Reference tables follow the Core reference-table pattern: code primary key, display name, description, sort order, active/effective dates, and audit columns.

Required Product references:

| Table | Opening codes |
|---|---|
| `product.product_kind` | `FOOD`, `NONFOOD` |
| `product.description_type` | `OPERATIONAL`, `CUSTOMER`, `SHORT`, `INVOICE` |
| `product.category_role` | `PRIMARY`, `REPORTING` |
| `product.product_status` | `PENDING_APPROVAL`, `ACTIVE`, `PURCHASE_HOLD`, `SALES_HOLD`, `QUALITY_HOLD`, `DISCONTINUED`, `INACTIVE` |
| `product.product_status_reason` | `NEW_PRODUCT_REVIEW`, `SETUP_COMPLETE`, `SUPPLY_ISSUE`, `SALES_RESTRICTION`, `QUALITY_REVIEW`, `RECALL`, `REPLACED`, `NO_DEMAND`, `MANAGEMENT_DECISION` |
| `product.product_unit_role` | `BASE_STOCK`, `DEFAULT_SELL`, `ALTERNATE_SELL`, `DEFAULT_PURCHASE`, `ALTERNATE_PURCHASE`, `PALLET` |
| `product.storage_class` | `AMBIENT`, `REFRIGERATED`, `FROZEN` |
| `product.temperature_scale` | `F`, `C` |
| `product.date_control_method` | `NOT_DATE_CONTROLLED`, `EXPIRATION_DATE`, `BEST_BY_DATE`, `USE_BY_DATE`, `PACK_DATE_PLUS_LIFE` |
| `product.lot_control_method` | `NONE`, `SUPPLIER_LOT`, `LOT`, `SUPPLIER_AND_LOT` |
| `product.rotation_method` | `FEFO`, `FIFO`, `MANUAL_APPROVAL` |
| `product.identifier_type` | `GTIN_14`, `UPC_A`, `EAN`, `MANUFACTURER_ITEM`, `LEGACY_ITEM` |
| `product.identifier_verification_status` | `UNVERIFIED`, `VERIFIED`, `REJECTED` |
| `product.certification_type` | `KOSHER`, `HALAL`, `ORGANIC`, `COUNTRY_OF_ORIGIN`, `OTHER` |
| `product.certification_status` | `PENDING`, `VERIFIED`, `REJECTED`, `EXPIRED` |
| `product.document_type` | `INGREDIENT`, `NUTRITION`, `SAFETY`, `SPECIFICATION`, `CERTIFICATION`, `COUNTRY_OF_ORIGIN` |
| `product.measurement_source` | `MANUFACTURER`, `SUPPLIER`, `VERIFIED` |
| `product.allergen_declaration_status` | `CONTAINS`, `MAY_CONTAIN`, `FREE_FROM`, `UNKNOWN` |
| `product.relationship_type` | `TEMPORARY_SUBSTITUTE`, `EQUIVALENT_SUBSTITUTE`, `CUSTOMER_APPROVAL_SUBSTITUTE`, `SUPERSEDED_BY`, `REPLACEMENT_PRODUCT` |
| `product.customer_product_rule_type` | `MINIMUM_REMAINING_LIFE`, `APPROVED_BRAND`, `PROHIBITED_BRAND`, `SELL_UNIT_RESTRICTION`, `SUBSTITUTION_PERMISSION`, `DIETARY_REQUIREMENT`, `ALLERGEN_RESTRICTION`, `CUSTOMER_ITEM_NUMBER` |
| `product.handling_requirement_type` | `FREEZE_PROTECTION`, `HUMIDITY_SENSITIVE`, `FRAGILE`, `CRUSH_RESTRICTED`, `KEEP_DRY`, `ODOR_SEPARATION`, `CHEMICAL_SEPARATION`, `FOOD_NONFOOD_SEGREGATION`, `PPE_REQUIRED` |
| `product.allergen` | Initial regulated/allergen list approved by Quality before build release |

Status/reason and rule/value compatibility tables prevent invalid combinations.

## 7. Categories and Brands

### 7.1 `product.category`

Primary key: `category_code`.

Columns include name, description, nullable `parent_category_code`, display order, active/effective fields, and audit columns. A self-FK supports hierarchy. A deferred constraint trigger prevents cycles.

Opening top-level rows:

`CANNED_GOODS`, `FROZEN_GOODS`, `FRESH_PRODUCE`, `DRY_GROCERY`, `REFRIGERATED_GOODS`, `BEVERAGES`, `PAPER_PRODUCTS`, `CLEANING_SANITATION`, `FOOD_SERVICE_SUPPLIES`.

### 7.2 `product.brand`

Primary key: `brand_code`.

Columns include brand name, optional manufacturer Organization Party, active/effective fields, and audit columns. Brand name is searchable but not a key. Manufacturer changes require effective history in `product.brand_manufacturer` keyed by `brand_code + effective_from`.

## 8. Product Master

### 8.1 `product.product`

| Column | Type | Null | Rule |
|---|---|---:|---|
| `product_number` | `text` | No | PK; exactly eight digits |
| `product_kind_code` | `text` | No | FK to Product Kind |
| `introduced_on` | `date` | No | Required |
| `discontinued_on` | `date` | Yes | Not before introduction |
| `is_inventory_item` | `boolean` | No | Normally true |
| audit columns | standard | No | Required |

Current status, description, category, brand, units, and policies are stored in their effective structures rather than duplicated here.

Indexes support Product Kind and introduction/discontinuation dates.

### 8.2 `product.product_description`

Primary key: `product_number + description_type_code + effective_from`.

Contains description text, effective period, and audit columns. Periods for the same Product and description type cannot overlap. Active products require current `OPERATIONAL`, `CUSTOMER`, and `INVOICE` descriptions. Invoice description has an enforced practical length suitable for output layout, not identity.

### 8.3 `product.product_status_history`

Primary key: `product_number + effective_from`.

Contains status, reason, explanation, approving Principal when required, effective period, and audit columns. Exactly one current status exists. Status transitions occur through controlled functions.

## 9. Product Classification

### 9.1 `product.product_category`

Primary key: `product_number + category_role_code + category_code + effective_from`.

An exclusion/constraint trigger permits exactly one current `PRIMARY` category and multiple reporting categories. Referenced categories must be active for new assignments.

### 9.2 `product.product_brand`

Primary key: `product_number + effective_from`.

Contains nullable brand code, effective period, and audit fields. Periods cannot overlap. A null brand explicitly means unbranded/private-label status and is not represented by a fake Brand row.

## 10. Product Units and Conversions

### 10.1 `product.product_unit`

Primary key: `product_number + unit_code + effective_from`.

Columns:

- Product and Core unit code
- `quantity_in_base_unit numeric(19,6)`
- Whole-quantity-required flag
- Split permitted flag
- Minimum sell quantity
- Sell increment
- Repacking/relabeling-required flag
- Split-charge-eligible flag
- Effective period and audit columns

Rules:

- Quantity and increments are positive.
- The base unit conversion equals exactly 1.
- Every conversion points directly to the one current base unit; conversion graphs are not chained.
- Count units normally require whole quantities.
- Split fields are valid only for sellable units.
- Periods for Product and Unit cannot overlap.

### 10.2 `product.product_unit_role_assignment`

Primary key: `product_number + product_unit_role_code + unit_code + effective_from`.

Exactly one current `BASE_STOCK`, `DEFAULT_SELL`, and `DEFAULT_PURCHASE` role is required for an active stocked Product. Multiple alternate roles are allowed. Role assignment requires a current Product Unit row covering the assignment period.

### 10.3 Pallet Configuration

`product.product_pallet_configuration` uses primary key:

`product_number + pallet_configuration_code + effective_from`.

It records cases per layer, layers per pallet, total cases, optional pallet unit, maximum stack count, and whether the pallet is the default inbound configuration. Values must be positive and internally consistent.

## 11. Fixed Measurements

`product.product_unit_measurement` primary key:

`product_number + unit_code + effective_from`.

Columns include:

- Net weight and weight unit
- Gross weight and weight unit
- Length, width, height, and common length unit
- Cube and volume unit
- Measurement source code
- Effective period and audit columns

Checks require positive populated values, gross weight not less than net weight, and complete dimension groups. Derived cube may be checked within an approved rounding tolerance.

No column represents a warehouse-measured selling price or catch-weight extension.

## 12. Handling Profile

### 12.1 `product.product_handling_profile`

Primary key: `product_number + effective_from`.

Columns include storage class, optional minimum/maximum temperature, temperature scale, maximum stack count, food/nonfood segregation flag, and effective/audit fields.

Rules:

- Minimum temperature cannot exceed maximum.
- Temperature scale is required when a limit exists.
- Storage-class temperature bounds must fall within Quality-approved configuration.
- Periods cannot overlap.

### 12.2 `product.product_handling_requirement`

Primary key:

`product_number + handling_requirement_type_code + effective_from`.

Stores required flag, structured value where defined, explanation, effective period, and audit columns. Multiple different requirements may be current; the same requirement type cannot overlap.

## 13. Shelf-Life and Lot Policies

### 13.1 `product.product_shelf_life_policy`

Primary key: `product_number + effective_from`.

Columns:

- Date-control method
- Optional total shelf-life days
- Minimum remaining days at receiving
- Minimum remaining days at allocation
- Minimum remaining days at shipment
- Disposition threshold days
- Approval-required-below-shipment-minimum flag
- Effective period and audit columns

Rules enforce nonnegative thresholds and logical ordering. `PACK_DATE_PLUS_LIFE` requires total shelf-life days. `NOT_DATE_CONTROLLED` requires date thresholds to be null.

Shipment below the normal threshold requires a controlled exception and never bypasses safety, regulatory, or customer requirements.

### 13.2 `product.product_lot_policy`

Primary key: `product_number + effective_from`.

Contains lot-control method, rotation method, supplier/manufacturer lot requirements, mixed-lot-slot permission, deplete-current-lot-first flag, and effective/audit fields.

Rules:

- Date-controlled Products normally use `FEFO`.
- `NONE` cannot require supplier/manufacturer lot capture.
- `MANUAL_APPROVAL` requires an exception reason during allocation or picking.
- Mixed-lot slots do not waive lot identity or rotation controls.

## 14. Identifiers

`product.product_identifier` primary key:

`product_number + identifier_type_code + identifier_value + effective_from`.

Columns include optional issuer Organization Party, applicable unit code, normalized value, verification status/date/Principal, effective period, and audit columns.

Rules:

- GTIN, UPC, and EAN values pass format/check-digit validation.
- A current verified global identifier/unit cannot identify multiple Products.
- Manufacturer identifiers are unique within manufacturer and unit context.
- Periods for the same identifier assignment cannot overlap.
- Supplier and customer item numbers remain in their relationship domains, not this global table.

Indexes support lookup by normalized identifier and issuer.

## 15. Certifications, Documents, and Allergens

### 15.1 `product.product_certification`

Primary key: `product_number + certification_type_code + certificate_number`.

Stores issuing Party, issue/expiration dates, verification status and Principal, document reference, SHA-256 checksum, and audit fields. Verified status requires document evidence. Expired certifications cannot satisfy active Product requirements.

### 15.2 `product.product_allergen`

Primary key: `product_number + allergen_code + effective_from`.

Stores declaration status, source document reference, effective period, and audit fields. Periods for the same Product/allergen cannot overlap.

### 15.3 `product.product_document`

Primary key: `product_number + document_type_code + document_version`.

Stores controlled references for ingredient, nutrition, safety, specification, certification, and country-of-origin documents. It stores metadata and checksum—not unrestricted document bytes.

## 16. Product Relationships

`product.product_relationship` primary key:

`from_product_number + to_product_number + relationship_type_code + effective_from`.

Both Products must differ. Periods for the same relationship cannot overlap. Replacement and supersession relationships cannot form cycles. Relationship metadata includes customer approval, Quality approval, pack-equivalence, and effective dates.

Substitution never changes an order silently; Sales validates customer permission and commercial impact.

## 17. Customer Product Rules

`sales.customer_product_rule` primary key:

`customer_number + product_number + customer_product_rule_type_code + effective_from`.

Optional Customer Location narrows a rule to one site. Structured columns support remaining-life days, permitted sell unit, related brand, boolean permission, customer item number, and explanatory text. A rule-type definition determines which value is required.

Periods for the same Customer/Product/Location/rule type cannot overlap. Location must belong to Customer. Quality approval is required for allergen or safety-related rules.

## 18. Controlled Functions

Required behavior is provided through transaction-safe functions, with final signatures determined during SQL implementation:

- `product.create_pending_product(...) returns product_number`
- `product.set_product_description(...)`
- `product.set_product_status(...)`
- `product.assign_product_category(...)`
- `product.assign_product_brand(...)`
- `product.define_product_unit(...)`
- `product.assign_product_unit_role(...)`
- `product.set_product_measurement(...)`
- `product.set_handling_profile(...)`
- `product.set_shelf_life_policy(...)`
- `product.set_lot_policy(...)`
- `product.record_product_identifier(...)`
- `product.record_product_certification(...)`
- `product.set_product_allergen(...)`
- `product.set_product_relationship(...)`
- `sales.set_customer_product_rule(...)`
- `product.activate_product(...)`
- `product.discontinue_product(...)`

Each function validates active references and responsible Principal, locks the stable Product row, closes and opens effective periods atomically, checks expected row version, records audit, uses a safe fixed `search_path`, and is unavailable to `PUBLIC`.

## 19. Activation Validation

`product.activate_product` refuses activation unless:

1. Required descriptions exist.
2. One current primary category exists.
3. Product Kind and current status are valid.
4. One current base, default sell, and default purchase unit exists.
5. Every unit converts directly and exactly to the base unit.
6. Required measurements exist.
7. A handling profile exists.
8. Shelf-life, lot, and rotation policies are internally consistent.
9. Required identifiers and safety attributes exist.
10. Required Quality and Operations approvals exist.
11. At least one approved supplier source exists before purchasing is enabled; until the Purchasing domain is built, Product may activate for design/testing but remains on Purchase Hold.

The function returns all failed prerequisites where practical.

## 20. Audit

`audit.product_event` uses `product_audit_event_number` as its primary key, allocated from `PRODUCT_AUDIT_EVENT`.

It records event type, timestamp, responsible Principal, Product, optional Customer, business effective time, reason, approval reference, correlation code, and a sanitized `jsonb` before/after summary. It is append-only; update and delete are blocked.

Audit JSON supports investigation but does not replace normalized effective records or transaction snapshots.

## 21. Concurrency and Integrity

- Product creation uses controlled number allocation.
- Effective changes lock the Product before closing/opening history.
- GiST exclusion constraints prevent overlapping facts.
- Expected `row_version` prevents lost updates.
- Category and replacement cycles are rejected by deferred constraint triggers.
- A single current base-unit assignment is enforced at transaction end.
- Concurrent identifier assignment cannot give one verified barcode to two Products.
- No direct application update may bypass controlled status, shelf-life, lot, or safety changes.

## 22. Indexes and Views

Indexes must support:

- Product by kind and current status
- Normalized descriptions
- Category hierarchy and current primary category
- Brand and manufacturer
- Current unit roles and conversions
- Storage class and handling requirements
- Date-control, lot-control, and rotation methods
- Identifier lookup
- Certifications by expiration/status
- Allergen lookup
- Substitution/replacement in both directions
- Customer rules by Customer, Product, and Location
- Audit events by Product, type, and time

Required reporting views:

- `reporting.current_product`
- `reporting.current_product_unit`
- `reporting.current_product_handling`
- `reporting.current_product_shelf_life`
- `reporting.current_product_lot_policy`
- `reporting.product_setup_readiness`
- `reporting.product_certification_expiration`
- `reporting.product_substitution`
- `reporting.customer_product_restriction`

## 23. Privileges

| Role | Access |
|---|---|
| `pfd_database_owner` | Owns objects; remains `NOLOGIN` |
| `pfd_change_executor` | Assumes owner only for approved builds |
| `pfd_application` | Reads approved Product data and executes controlled functions; no protected direct writes |
| `pfd_reporting` | Reads reporting views and nonsensitive references |
| `pfd_support_readonly` | Authorized diagnostic read access |
| `PUBLIC` | No Product-domain access |

Quality-controlled fields and hold functions require Quality authority. Purchasing cannot release a Quality Hold. Reporting views exclude protected supplier arrangements and restricted document details.

## 24. Permanent Change Order

| Change | Content |
|---|---|
| `0023` | Add Product/audit number sequences and required Core units |
| `0024` | Create and seed Product references, categories, and brands |
| `0025` | Create Product Master, descriptions, status, category, and brand history |
| `0026` | Create Product Unit, role assignment, pallet configuration, and measurements |
| `0027` | Create handling profile and handling requirements |
| `0028` | Create shelf-life and lot policies |
| `0029` | Create identifiers, certifications, documents, and allergens |
| `0030` | Create Product relationships and Customer Product rules |
| `0031` | Create controlled functions, audit events, reporting views, and temporal/cycle guards |
| `0032` | Apply comments, privileges, default privileges, and final assertions |

## 25. Verification

Read-only verification must prove:

- Contiguous change history through `0032`
- Manifest and prior-change checksums
- Required objects, natural keys, FKs, checks, exclusions, triggers, functions, and views
- No surrogate/identity/serial/UUID keys
- Exact required reference codes
- Product number and audit number formats
- One current base/default sell/default purchase unit per active Product
- Nonoverlapping effective records
- No category or replacement cycles
- Append-only audit history
- Correct privilege matrix
- No catch-weight price or simulation-session columns
- Updated Core unit verification includes `LENGTH`, `INCH`, and `FOOT`

## 26. Behavioral Tests

Rollback-contained tests in a disposable database must:

1. Allocate unique eight-digit Product numbers.
2. Create and activate a complete Product.
3. Reject activation with missing descriptions, units, handling, or policies.
4. Reject duplicate natural keys and invalid references.
5. Reject overlapping effective periods.
6. Reject multiple current base/default units.
7. Reject zero, negative, chained, or contradictory conversions.
8. Validate case, pack, each, and pallet examples.
9. Enforce split-pack minimum and increment rules.
10. Reject invalid weight, dimensions, cube, and temperature ranges.
11. Enforce FEFO for date-controlled Product policy.
12. Permit a canned-good Product to carry expiration control.
13. Reject inconsistent remaining-life thresholds and validate the approval-required policy flag.
14. Validate lot-policy combinations, including mixed-lot and deplete-current-lot-first settings; actual receipt and picking enforcement is tested in later Inventory and Warehouse builds.
15. Validate GTIN/UPC check digits and uniqueness.
16. Reject expired certification as current evidence.
17. Reject category and replacement cycles.
18. Enforce customer-specific remaining-life and substitution rules.
19. Block unauthorized Quality Hold release.
20. Block audit update/delete and direct protected writes.
21. Prove concurrent Product-number allocation.
22. Prove concurrent temporal changes cannot overlap.
23. Verify simulation uses ordinary Product Master without a simulation key.

## 27. Acceptance Criteria

The later executable build is accepted when clean and incremental builds reach `0032`, rerun with no changes, pass every checksum, verification, behavioral, concurrency, and privilege test, and demonstrate:

- `product_number` is the Product primary key.
- Product history is normalized and nonoverlapping.
- Unit conversion is exact and unambiguous.
- Fixed weight is supported without catch-weight pricing.
- Shelf life, lot control, FEFO/FIFO, mixed-lot slots, and lot-placement requirements are preserved for downstream domains.
- Product safety and Quality controls cannot be bypassed.
- Simulation and normal operation share Product Master.

## 28. Next Design Work

After this specification, the next design document should be the **Supplier and Purchasing Domain Specification**. Executable Product SQL remains deferred until we leave Design Land.
