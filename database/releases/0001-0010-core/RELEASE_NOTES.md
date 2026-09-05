# Release Notes — 1.0.0

Initial executable Core Build for the PFD PostgreSQL database:

- establishes least-privilege cluster roles and a new UTF-8 database;
- creates functional schemas for future business modules;
- creates normalized Core governance tables using natural primary keys;
- creates the configurable Company structure and seeds approved principal, unit, business-area, role, and transaction classifications;
- enforces append-only change history and controlled business-number allocation;
- provides effective-dated approval-authority structure;
- includes a checksummed manifest, validation runner, read-only verification, rollback-contained tests, and guarded disposable-database operations; and
- preserves the rule that simulation uses the actual persistent business tables.

No operational Customer, Supplier, Product, Inventory, Sales, Warehouse, Transport, or Accounting tables are created in this release. Those belong to subsequent domain builds.
