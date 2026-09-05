-- Change 0003: create initial Core reference tables and Principal Types.
-- Requires: 0002. Transaction: required.
-- Principal audit foreign keys are intentionally deferred to 0004.

SET LOCAL ROLE pfd_database_owner;

CREATE TABLE core.principal_type (
  principal_type_code text NOT NULL,
  display_name text NOT NULL,
  description text,
  sort_order integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  effective_from date NOT NULL,
  effective_through date,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_principal_type PRIMARY KEY (principal_type_code),
  CONSTRAINT ck_principal_type_code_format CHECK (principal_type_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_principal_type_name_nonblank CHECK (btrim(display_name) <> ''),
  CONSTRAINT ck_principal_type_sort_nonnegative CHECK (sort_order >= 0),
  CONSTRAINT ck_principal_type_dates CHECK (effective_through IS NULL OR effective_through > effective_from),
  CONSTRAINT ck_principal_type_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_principal_type_row_version CHECK (row_version > 0)
);

CREATE TABLE core.unit_class (
  unit_class_code text NOT NULL,
  display_name text NOT NULL,
  description text,
  sort_order integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  effective_from date NOT NULL,
  effective_through date,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_unit_class PRIMARY KEY (unit_class_code),
  CONSTRAINT ck_unit_class_code_format CHECK (unit_class_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_unit_class_name_nonblank CHECK (btrim(display_name) <> ''),
  CONSTRAINT ck_unit_class_sort_nonnegative CHECK (sort_order >= 0),
  CONSTRAINT ck_unit_class_dates CHECK (effective_through IS NULL OR effective_through > effective_from),
  CONSTRAINT ck_unit_class_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_unit_class_row_version CHECK (row_version > 0)
);

CREATE TABLE core.business_area (
  business_area_code text NOT NULL,
  display_name text NOT NULL,
  description text,
  sort_order integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  effective_from date NOT NULL,
  effective_through date,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_business_area PRIMARY KEY (business_area_code),
  CONSTRAINT ck_business_area_code_format CHECK (business_area_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_business_area_name_nonblank CHECK (btrim(display_name) <> ''),
  CONSTRAINT ck_business_area_sort_nonnegative CHECK (sort_order >= 0),
  CONSTRAINT ck_business_area_dates CHECK (effective_through IS NULL OR effective_through > effective_from),
  CONSTRAINT ck_business_area_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_business_area_row_version CHECK (row_version > 0)
);

CREATE TABLE core.transaction_type (
  transaction_type_code text NOT NULL,
  display_name text NOT NULL,
  description text,
  sort_order integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  effective_from date NOT NULL,
  effective_through date,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_transaction_type PRIMARY KEY (transaction_type_code),
  CONSTRAINT ck_transaction_type_code_format CHECK (transaction_type_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_transaction_type_name_nonblank CHECK (btrim(display_name) <> ''),
  CONSTRAINT ck_transaction_type_sort_nonnegative CHECK (sort_order >= 0),
  CONSTRAINT ck_transaction_type_dates CHECK (effective_through IS NULL OR effective_through > effective_from),
  CONSTRAINT ck_transaction_type_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_transaction_type_row_version CHECK (row_version > 0)
);

CREATE TABLE core.role_code (
  role_code text NOT NULL,
  display_name text NOT NULL,
  description text,
  sort_order integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  effective_from date NOT NULL,
  effective_through date,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_role_code PRIMARY KEY (role_code),
  CONSTRAINT ck_role_code_format CHECK (role_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_role_code_name_nonblank CHECK (btrim(display_name) <> ''),
  CONSTRAINT ck_role_code_sort_nonnegative CHECK (sort_order >= 0),
  CONSTRAINT ck_role_code_dates CHECK (effective_through IS NULL OR effective_through > effective_from),
  CONSTRAINT ck_role_code_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_role_code_row_version CHECK (row_version > 0)
);

INSERT INTO core.principal_type (
  principal_type_code, display_name, description, sort_order, is_active,
  effective_from, created_at, created_by_principal_code,
  updated_at, updated_by_principal_code, row_version
)
VALUES
  ('PERSON', 'Person', 'Authenticated human Principal', 10, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('SERVICE', 'Service', 'Application or integration service', 20, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('SCHEDULED_PROCESS', 'Scheduled Process', 'Scheduled processing actor', 30, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('DATABASE_BUILD', 'Database Build', 'Controlled database build process', 40, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('RECOVERY_PROCESS', 'Recovery Process', 'Controlled restart or recovery actor', 50, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1);

INSERT INTO core.unit_class (
  unit_class_code, display_name, description, sort_order, is_active,
  effective_from, created_at, created_by_principal_code,
  updated_at, updated_by_principal_code, row_version
)
VALUES
  ('COUNT', 'Count', 'Each, pack, case, or pallet quantity', 10, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('WEIGHT', 'Weight', 'Fixed recorded weight; not catch-weight pricing', 20, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('VOLUME', 'Volume', 'Volume or cube measure', 30, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('TIME', 'Time', 'Time or duration measure', 40, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('DISTANCE', 'Distance', 'Routing, mileage, or travel distance', 50, true, DATE '2026-01-01', clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1);
