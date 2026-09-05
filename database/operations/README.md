# PFD Core Database Operations

## Controlled build sequence

1. Install a supported PostgreSQL release and its `btree_gist` extension package.
2. As a cluster administrator, execute `bootstrap/00_create_cluster_roles.sql`.
3. As a cluster administrator, execute `bootstrap/01_create_pfd_database.sql`, supplying the reviewed database name.
4. Set passwords or certificates outside this package and configure an approved libpq service named, for example, `pfd_build`.
5. Connect as `pfd_change_executor` and run the build runner in `build-and-verify` mode.
6. Run `tests/core/run_core_tests.sql` in a disposable validation database.
7. Capture the manifest, build output, verification output, approver, operator, target, start time, and finish time in the deployment record.

Do not use the application role for builds. Do not give the application direct rights to update controlled number state or change history.

## Release and recovery

- Back up the database and validate restore procedures before production use.
- Forward correction is the default. Applied change files are immutable.
- If a change fails, its transaction rolls back and the build stops. Correct the unapplied file or add a new forward change according to release status.
- Point-in-time recovery is an infrastructure procedure, not a replacement for accounting reversal entries or business audit history.
- Verification is mandatory after build and after restore.

## Simulation rule

Business simulation uses the same permanent business tables and controls as normal operations. Temporary run-control or diagnostic state may use the `simulation` schema, but it must not duplicate Customer, Product, Inventory, Order, Shipment, Invoice, Receivable, Payable, or General Ledger masters and transactions.
