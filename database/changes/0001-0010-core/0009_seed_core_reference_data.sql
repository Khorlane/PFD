-- Change 0009: load and reconcile approved Core reference data.
-- Requires: 0008. Transaction: required.

SET LOCAL ROLE pfd_database_owner;

DO $pfd$
BEGIN
  IF (SELECT count(*) FROM core.principal_type) <> 5 THEN
    RAISE EXCEPTION 'Principal Type bootstrap rows do not match the approved set';
  END IF;
  IF (SELECT count(*) FROM core.unit_class) <> 5 THEN
    RAISE EXCEPTION 'Unit Class bootstrap rows do not match the approved set';
  END IF;
END
$pfd$;

INSERT INTO core.business_area (
  business_area_code, display_name, description, sort_order, is_active,
  effective_from, created_at, created_by_principal_code,
  updated_at, updated_by_principal_code, row_version
)
VALUES
  ('GENERAL_MANAGEMENT', 'General Management', 'Company-wide management and owner governance', 10, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('SALES', 'Sales', 'Customer development, pricing, and commercial responsibility', 20, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('CREDIT', 'Credit', 'Customer credit, collection, and exposure control', 30, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('PURCHASING', 'Purchasing', 'Supplier and purchasing responsibility', 40, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('INVENTORY', 'Inventory', 'Inventory quantity, status, and valuation responsibility', 50, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('WAREHOUSE', 'Warehouse', 'Receiving, storage, picking, staging, and loading', 60, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('TRANSPORTATION', 'Transportation', 'Fleet, dispatch, routing, and delivery', 70, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('QUALITY', 'Quality', 'Food safety and quality control', 80, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('CUSTOMER_SERVICE', 'Customer Service', 'Customer order support, cases, and returns', 90, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('FINANCE', 'Finance', 'Accounting, cash, receivables, payables, assets, and reporting', 100, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('HUMAN_RESOURCES', 'Human Resources', 'Employment, scheduling, time, and payroll governance', 110, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('INFORMATION_TECHNOLOGY', 'Information Technology', 'Systems, database, security, and recovery', 120, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1);

INSERT INTO core.role_code (
  role_code, display_name, description, sort_order, is_active,
  effective_from, created_at, created_by_principal_code,
  updated_at, updated_by_principal_code, row_version
)
VALUES
  ('GENERAL_MANAGER', 'General Manager', 'General management authority', 10, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('SALES_MANAGER', 'Sales Manager', 'Sales and commercial authority', 20, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('OPERATIONS_PURCHASING_MANAGER', 'Operations/Purchasing Manager', 'Operations and purchasing authority', 30, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('FINANCE_ADMIN_MANAGER', 'Finance/Admin Manager', 'Finance and administration authority', 40, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('DATABASE_ADMINISTRATOR', 'Database Administrator', 'Controlled database administration', 50, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('COMPUTER_OPERATOR', 'Computer Operator', 'Controlled operational processing', 60, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('DATABASE_BUILD_PROCESS', 'Database Build Process', 'Approved database build execution', 70, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('APPLICATION_SERVICE', 'Application Service', 'Approved application service processing', 80, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1);

INSERT INTO core.transaction_type (
  transaction_type_code, display_name, description, sort_order, is_active,
  effective_from, created_at, created_by_principal_code,
  updated_at, updated_by_principal_code, row_version
)
VALUES
  ('DATABASE_CHANGE', 'Database Change', 'Approved structural or reference-data database change', 10, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('OWNER_DISTRIBUTION', 'Owner Distribution', 'Distribution of company funds to owners', 20, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('CAPITAL_EXPENDITURE', 'Capital Expenditure', 'Purchase or improvement of a capital asset', 30, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('MANUAL_JOURNAL', 'Manual Journal', 'Manually prepared General Ledger entry', 40, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('SUPPLIER_PAYMENT', 'Supplier Payment', 'Approved disbursement to a supplier', 50, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('CREDIT_EXCEPTION', 'Credit Exception', 'Temporary approved customer credit exception', 60, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1);

