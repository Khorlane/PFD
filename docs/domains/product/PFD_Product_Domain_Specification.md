# \<business name>
# Product Domain Specification

**Version:** 1.0  
**Date:** September 4, 2026  
**Status:** Design baseline  
**Depends on:** PFD Core, Party, and Customer designs

## 1. Purpose

Define the products PFD may buy, store, price, sell, pick, and deliver. This document describes business behavior and logical information; it does not define PostgreSQL objects or executable code.

## 2. Scope

The Product domain owns:

- Product numbers, names, descriptions, brands, and categories
- Food-service and nonfood classifications
- Selling, purchasing, stocking, and handling units
- Pack configuration and unit conversion
- Ambient, refrigerated, and frozen handling profiles
- Shelf-life and expiration rules
- Lot and date-control requirements
- Barcode and external product identifiers
- Product dimensions, fixed weights, and warehouse characteristics
- Customer-facing availability restrictions
- Product substitutions and replacements
- Product activation, suspension, and inactivation

It does not own supplier terms, purchase orders, inventory quantities, warehouse locations, customer prices, sales orders, or accounting balances.

## 3. Governing Decisions

1. `product_number` is the permanent Product Master primary key.
2. Product numbers are controlled business identifiers; they are never reused.
3. No surrogate keys are used.
4. A product represents one commercially distinct item. Materially different size, brand, formula, temperature class, or pack is a different product.
5. Product attributes are stored once and referenced by purchasing, sales, inventory, warehouse, transportation, quality, and finance.
6. Multiple sell and purchase units are allowed, but every conversion must be exact and effective-dated.
7. `EACH`, `PACK`, `CASE`, and `PALLET` are count units. Split packs may be sold, but are not preferred.
8. Weight fields represent declared or fixed weight. PFD does not support warehouse catch-weight pricing or price-at-weigh processing.
9. Inventory is controlled by lot when required by product policy, regulation, supplier identification, recall exposure, or expiration.
10. FEFO is used for date-sensitive inventory; FIFO is the default otherwise.
11. Multiple lots may occupy one picking slot, but one lot is depleted before the next is picked unless an authorized exception applies.
12. The warehouse records when each lot/pallet is placed into a picking slot.
13. Products are inactivated rather than deleted; historical transactions retain the product definition used at the time.
14. Simulation uses the same Product Master and product policies as normal operation.

## 4. Product Identity

PFD assigns an eight-digit product number, initially beginning at `00000001`. Allocation is centralized and concurrency-safe.

Product Master contains stable identity and governance:

- Product number
- Operational product name
- Customer-facing description
- Brand and manufacturer reference when known
- Primary product category
- Food/nonfood designation
- Product status
- Introduction date
- Discontinuation date when applicable
- Replacement product when applicable
- Audit responsibility and timestamps

Manufacturer item numbers, GTINs, UPCs, supplier item numbers, and customer item numbers are alternate identifiers—not PFD primary keys.

## 5. Product Families and Categories

Opening top-level categories are:

| Code | Category |
|---|---|
| `CANNED_GOODS` | Shelf-stable canned food |
| `FROZEN_GOODS` | Frozen food |
| `FRESH_PRODUCE` | Fresh fruits and vegetables |
| `DRY_GROCERY` | Other shelf-stable food |
| `REFRIGERATED_GOODS` | Chilled food |
| `BEVERAGES` | Food-service beverages |
| `PAPER_PRODUCTS` | Disposable paper goods |
| `CLEANING_SANITATION` | Food-service cleaning and sanitation supplies |
| `FOOD_SERVICE_SUPPLIES` | Other consumable operating supplies |

Categories may form a hierarchy. A category cannot be its own ancestor. Each active product has one current primary category and may have additional reporting classifications.

## 6. Product Status

| Status | Meaning |
|---|---|
| `PENDING_APPROVAL` | Definition is incomplete or under review. |
| `ACTIVE` | Available for permitted purchasing and selling. |
| `PURCHASE_HOLD` | Existing inventory may sell, but replenishment is blocked. |
| `SALES_HOLD` | Purchasing or disposition may continue, but new sales are blocked. |
| `QUALITY_HOLD` | Buying, allocation, picking, and selling are blocked pending Quality review. |
| `DISCONTINUED` | No routine replenishment; remaining stock follows approved disposition. |
| `INACTIVE` | Product is closed to new activity; history remains. |

Status changes are effective-dated and require a reason. Quality holds override commercial availability.

## 7. Units and Pack Configuration

### 7.1 Product Units

A product identifies its:

- Base stocking unit
- Default selling unit
- Default purchasing unit
- Optional alternate selling and purchasing units

All units reference the approved Core Unit of Measure list.

### 7.2 Exact Conversion

Each product/unit relationship states the exact quantity of base units represented. Examples:

- 1 case = 6 #10 cans
- 1 pack = 12 each
- 1 pallet = 48 cases

Conversions must be positive, effective-dated, and nonoverlapping. Fractional conversion is permitted only where the product and unit policy explicitly allow it.

### 7.3 Split Packs

Split-pack capability is recorded by product and sell unit. It includes:

- Whether splitting is permitted
- Minimum sell quantity
- Quantity increment
- Whether repacking or relabeling is required
- Whether a split-pack charge may apply

The standard preference is to sell unopened cases or packs. Customer demand, product integrity, sanitation, traceability, and labor cost determine whether a split is accepted.

## 8. Weight, Dimensions, and Cube

Each applicable product/unit combination records:

- Declared net weight
- Gross shipping weight
- Length, width, and height
- Cube
- Units used for each measurement
- Measurement source and effective date

Gross weight must not be less than net weight. Dimensions and cube must be positive. Cube may be calculated from dimensions but the source values are retained.

Variable-weight products may be received only if they can be purchased, stocked, sold, and invoiced using an agreed fixed unit or declared quantity. The warehouse does not weigh an individual item, determine its price, send that price to the office, and revise the truck invoice.

## 9. Temperature and Handling

Opening storage classes are:

- `AMBIENT`
- `REFRIGERATED`
- `FROZEN`

Each product has one current storage class and may define:

- Required temperature range
- Freeze protection
- Humidity sensitivity
- Fragile or crush restrictions
- Keep-dry requirement
- Odor or chemical separation requirement
- Food/nonfood segregation
- Maximum stack or pallet limits
- Special personal protective equipment or handling notes

Temperature limits use one governed scale and cannot conflict with the storage class.

## 10. Shelf Life and Date Control

Date-control methods are:

- `NOT_DATE_CONTROLLED`
- `EXPIRATION_DATE`
- `BEST_BY_DATE`
- `USE_BY_DATE`
- `PACK_DATE_PLUS_LIFE`

Each applicable product defines:

- Total expected shelf life
- Minimum remaining life accepted at receiving
- Minimum remaining life required at allocation
- Minimum remaining life required at shipment
- Customer-specific remaining-life requirements when agreed
- Disposition threshold

A pallet of canned green beans may be date-controlled even though most PFD inventory is nonperishable. Product durability does not justify ignoring an expiration or best-by date.

Inventory expected to expire in two days is not shipped automatically. Shipment is allowed only if the product remains safe and compliant through expected consumption, satisfies customer requirements, and receives any required Quality or management approval. Otherwise it is held for disposition.

## 11. Lot Control and Rotation

Lot-control methods are:

- `NONE`
- `SUPPLIER_LOT`
- `PFD_LOT`
- `SUPPLIER_AND_PFD_LOT`

Lot-controlled products preserve supplier lot, manufacturer lot when provided, received date, applicable product dates, and traceability through receipt, storage, allocation, shipment, return, hold, and recall.

Rotation rules are:

- `FEFO` for date-sensitive products
- `FIFO` when receipt sequence governs
- `MANUAL_APPROVAL` only for documented exceptions

The system recommends inventory according to the rule. Warehouse confirmation records the actual lot picked. Picking from the next lot before depleting the current approved lot requires a reason when both occupy the same picking slot.

## 12. Pallet and Picking-Slot Behavior

Product data defines whether stock normally arrives as full pallets, cases, packs, or eaches and whether mixed-lot storage is allowed.

Warehouse and Inventory domains own actual pallets, lots, locations, and movement events. They must reference Product policy and record:

- When each lot or pallet enters a picking slot
- Which picking slot it entered
- Quantity placed
- Responsible worker or process
- Removal or depletion time
- Any rotation override

Multiple lots may exist in one picking slot. Procedures direct workers to deplete one lot before moving to the next, using FEFO or FIFO as applicable.

## 13. Product Dates and Customer Rules

Customer-specific product restrictions may specify:

- Minimum remaining shelf life
- Approved or prohibited brand
- Pack or sell-unit restriction
- Substitution permission
- Dietary, allergen, religious, contractual, or institutional requirement
- Required customer item number

The Product domain defines the restriction types. Sales owns the customer/product agreement, and order validation enforces it.

## 14. Food Safety and Regulatory Attributes

Applicable products record governed facts needed for safe distribution:

- Food or nonfood
- Allergen declarations
- Ingredient and nutrition document references
- Country of origin when required
- Kosher, halal, organic, or other certification metadata
- Hazardous or chemical handling classification for nonfood products
- Recall-contact manufacturer information
- Required traceability level

Documents are maintained in approved document storage with references, version, effective dates, and integrity checksums. Product Master does not become an uncontrolled document repository.

## 15. Barcodes and Alternate Identifiers

A product may have multiple identifiers by unit and effective period:

- GTIN-14
- UPC-A
- EAN
- Manufacturer item number
- Supplier item number
- Customer item number
- Legacy PFD product number

Identifiers record issuer/type, value, applicable unit, owner Party when relevant, effective period, and verification status.

A current globally governed barcode cannot identify two active PFD products for the same unit. Supplier and customer item numbers are unique only within the issuing Party's context.

## 16. Product–Supplier Boundary

The Product domain may identify the manufacturer Party and generic approved-source requirements. The Purchasing domain owns:

- Supplier-product association
- Supplier item number
- Supplier pack and minimum order
- Purchase cost and allowances
- Lead time
- Supplier priority
- Approved supplier status

One PFD product may have multiple approved suppliers when the physical item is genuinely interchangeable. A supplier variation that changes brand, formula, pack, traceability, or customer acceptability requires a distinct PFD product or an explicit substitution relationship.

## 17. Substitution and Replacement

Relationships include:

- Temporary substitute
- Equivalent substitute
- Customer-approval-required substitute
- Superseded by
- Replacement product

Each relationship is directional, effective-dated, and includes approval requirements. A substitution does not change an order silently. Sales validates customer permission, price, availability, allergen and dietary restrictions, pack difference, and delivery impact.

## 18. Product Lifecycle

Activation requires:

- Product number and approved description
- Primary category
- Food/nonfood designation
- Stocking, selling, and purchasing units with exact conversions
- Storage and handling class
- Lot and date-control policy
- Rotation method
- Applicable fixed weights and dimensions
- Tax and accounting classifications required by later domains
- At least one approved source before purchasing
- Required safety and certification records

Discontinuation identifies the replacement, last-buy policy, sale-through or disposition plan, and approval. Inactivation is allowed only after operational use has ended; open orders and inventory remain historically valid.

## 19. Logical Structures

| Structure | Natural primary key | Purpose |
|---|---|---|
| Product | `product_number` | Stable Product Master identity |
| Product Name/Description | `product_number + description_type + effective_from` | Effective customer and operational text |
| Category | `category_code` | Governed hierarchy |
| Product Category | `product_number + category_role + effective_from` | Primary/additional classifications |
| Product Status History | `product_number + effective_from` | Effective lifecycle status |
| Product Unit | `product_number + unit_code + effective_from` | Unit role and exact base conversion |
| Product Unit Measurement | `product_number + unit_code + effective_from` | Weight, dimensions, and cube |
| Product Handling Profile | `product_number + effective_from` | Temperature and handling rules |
| Product Shelf-Life Policy | `product_number + effective_from` | Date method and remaining-life thresholds |
| Product Lot Policy | `product_number + effective_from` | Lot method and rotation rule |
| Product Identifier | `identifier_type + issuer_party_number + identifier_value + effective_from` | Barcode or alternate identifier |
| Product Certification | `product_number + certification_type + certificate_number` | Certification metadata |
| Product Allergen | `product_number + allergen_code + effective_from` | Effective allergen declaration |
| Product Relationship | `from_product_number + to_product_number + relationship_type + effective_from` | Substitution or replacement |
| Customer Product Rule | `customer_number + product_number + rule_type + effective_from` | Customer-specific restriction |

Stable business numbers and governed composite keys are used throughout.

## 20. Integrity and History

- Effective periods for the same fact cannot overlap.
- Every unit conversion resolves exactly to the product's base unit.
- Conversion loops or contradictory paths are rejected.
- One current primary category, storage class, status, shelf-life policy, and lot policy exists per active product.
- Date-controlled products cannot use rotation method `FIFO` when FEFO is required.
- Lot-controlled inventory cannot bypass lot capture.
- Historical product descriptions and pack definitions are preserved for transaction snapshots.
- Material changes identify the responsible Principal, business effective time, reason, and approval where required.

## 21. Responsibilities

| Decision | Responsibility |
|---|---|
| Create product candidate | Purchasing or Sales |
| Approve Product Master | Operations/Purchasing |
| Approve food-safety attributes or hold | Quality |
| Approve units and pack conversion | Operations/Purchasing |
| Approve storage and handling | Warehouse and Quality |
| Approve customer-specific restriction | Sales, with Quality where applicable |
| Approve substitution | Sales and Operations; Quality when safety-related |
| Discontinue or inactivate | Operations/Purchasing with Finance review |

## 22. Business-to-IT Support

| Business capability | Product support |
|---|---|
| Sell correct items | Stable product identity, descriptions, units, customer restrictions |
| Purchase efficiently | Purchase units, pack configuration, approved-source boundary |
| Control inventory | Lot/date policy, rotation method, fixed units |
| Pick accurately | Barcodes, units, slot handling policy, actual-lot confirmation |
| Protect food safety | Temperature, shelf life, allergen, certification, recall traceability |
| Deliver profitably | Weight, cube, pallet configuration, handling class |
| Invoice accurately | Exact sell units; no warehouse catch-weight repricing |
| Manage change | Effective histories, holds, replacements, audit responsibility |

## 23. Reports

Required reporting includes:

- Active products by category and storage class
- Products missing required setup
- Products on sales, purchase, or quality hold
- Date- and lot-controlled products
- Products approaching discontinuation
- Split-pack-enabled products
- Products missing weight, dimensions, barcode, or approved source
- Customer product restrictions
- Product substitutions and replacements
- Product Master change history

## 24. Security

- Purchasing maintains commercial product setup within authority.
- Quality controls food-safety attributes and Quality holds.
- Warehouse may view handling policy but cannot redefine products.
- Sales may view products and maintain authorized customer-product rules.
- Reporting excludes protected supplier agreements and restricted documents.
- Controlled functions enforce material changes and write audit events.
- `PUBLIC` receives no Product-domain database access.

## 25. Remaining Configuration

The following do not block the design:

- Opening product catalog and product numbers
- Exact category hierarchy below the opening categories
- Product-specific shelf-life thresholds
- Initial barcodes, weights, dimensions, packs, and pallet quantities
- Certification/document-storage provider
- Customer-specific product rules

## 26. Next Step

The next design deliverable is the **PFD Product PostgreSQL Build Specification**. It will define the normalized PostgreSQL structures, constraints, indexes, reference data, functions, verification, and tests required to implement this domain—without yet producing executable SQL.
