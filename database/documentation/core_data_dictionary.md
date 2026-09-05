# PFD Core Data Dictionary

All Core keys are stable, meaningful business or governance codes. No serial, identity, UUID, or hidden surrogate primary keys are used.

| Table | Natural primary key | Purpose |
|---|---|---|
| `core.database_change` | `change_number` | Immutable record of permanent SQL changes. |
| `core.principal_type` | `principal_type_code` | Classifies responsible people and processes. |
| `core.unit_class` | `unit_class_code` | Classifies count, weight, volume, time, and distance units. |
| `core.business_area` | `business_area_code` | Shared responsibility domain. |
| `core.transaction_type` | `transaction_type_code` | Shared controlled-transaction classification. |
| `core.role_code` | `role_code` | Shared business or technical responsibility role. |
| `core.principal` | `principal_code` | Audit identity for a responsible human or process; never an authentication-secret store. |
| `core.company` | `company_code` | Configurable legal and operating company identity supplied by the selected opening dataset. |
| `core.unit_of_measure` | `unit_code` | Approved fixed units for products, logistics, and labor. |
| `core.approval_authority` | `authority_code`, `effective_from` | Effective-dated authority by business area, transaction, role, and amount. |
| `core.number_sequence` | `sequence_code` | Locked state for controlled allocation of permanent business numbers. |

## Common governance fields

Reference and master rows use `is_active` instead of deletion. Effective-dated reference tables use `effective_from` and optional `effective_through`. Mutable tables carry responsible Principal codes, timestamps, and a positive `row_version` for future optimistic concurrency controls.

## Number allocation

Applications call `core.allocate_business_number(sequence_code, principal_code)`. The function locks the named row, returns the next formatted value, advances the state, and records who allocated it. Direct application updates to `core.number_sequence` are prohibited.

## Weight boundary

`WEIGHT` and its units record fixed quantities and specifications. The Core model does not enable warehouse catch-weight pricing or price-at-weigh workflows, consistent with PFD's operating decision.
