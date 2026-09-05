-- Change 0006: create Unit of Measure and opening fixed units.
-- Requires: 0005. Transaction: required.

SET LOCAL ROLE pfd_database_owner;

CREATE TABLE core.unit_of_measure (
  unit_code text NOT NULL,
  unit_name text NOT NULL,
  unit_class_code text NOT NULL,
  decimal_scale smallint NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_unit_of_measure PRIMARY KEY (unit_code),
  CONSTRAINT fk_unit_of_measure_class FOREIGN KEY (unit_class_code) REFERENCES core.unit_class (unit_class_code),
  CONSTRAINT fk_unit_of_measure_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
  CONSTRAINT fk_unit_of_measure_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code),
  CONSTRAINT ck_unit_of_measure_code_format CHECK (unit_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_unit_of_measure_name_nonblank CHECK (btrim(unit_name) <> ''),
  CONSTRAINT ck_unit_of_measure_decimal_scale CHECK (decimal_scale BETWEEN 0 AND 6),
  CONSTRAINT ck_unit_of_measure_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_unit_of_measure_row_version CHECK (row_version > 0)
);

CREATE INDEX ix_unit_of_measure_class_active
  ON core.unit_of_measure (unit_class_code, is_active);

INSERT INTO core.unit_of_measure (
  unit_code, unit_name, unit_class_code, decimal_scale, is_active,
  created_at, created_by_principal_code, updated_at, updated_by_principal_code, row_version
)
VALUES
  ('EACH', 'Each', 'COUNT', 0, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('PACK', 'Pack', 'COUNT', 0, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('CASE', 'Case', 'COUNT', 0, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('PALLET', 'Pallet', 'COUNT', 0, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('POUND', 'Pound', 'WEIGHT', 4, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('OUNCE', 'Ounce', 'WEIGHT', 4, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('CUBIC_FOOT', 'Cubic Foot', 'VOLUME', 6, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('MILE', 'Mile', 'DISTANCE', 4, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('HOUR', 'Hour', 'TIME', 4, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1);

