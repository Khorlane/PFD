-- Change 0004: create Principal and complete deferred audit foreign keys.
-- Requires: 0003. Transaction: required.

SET LOCAL ROLE pfd_database_owner;

CREATE TABLE core.principal (
  principal_code text NOT NULL,
  principal_type_code text NOT NULL,
  display_name text NOT NULL,
  external_subject text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_principal PRIMARY KEY (principal_code),
  CONSTRAINT fk_principal_principal_type FOREIGN KEY (principal_type_code)
    REFERENCES core.principal_type (principal_type_code),
  CONSTRAINT uq_principal_external_subject UNIQUE (external_subject),
  CONSTRAINT ck_principal_code_format CHECK (principal_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_principal_display_name_nonblank CHECK (btrim(display_name) <> ''),
  CONSTRAINT ck_principal_external_subject_nonblank CHECK (external_subject IS NULL OR btrim(external_subject) <> ''),
  CONSTRAINT ck_principal_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_principal_row_version CHECK (row_version > 0)
);

INSERT INTO core.principal (
  principal_code, principal_type_code, display_name, external_subject, is_active,
  created_at, created_by_principal_code, updated_at, updated_by_principal_code, row_version
)
VALUES
  ('DATABASE_BUILD', 'DATABASE_BUILD', 'PFD Database Build', NULL, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('SYSTEM_SERVICE', 'SERVICE', 'PFD System Service', NULL, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('SCHEDULED_PROCESS', 'SCHEDULED_PROCESS', 'PFD Scheduled Process', NULL, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1),
  ('RECOVERY_PROCESS', 'RECOVERY_PROCESS', 'PFD Recovery Process', NULL, true, clock_timestamp(), 'DATABASE_BUILD', clock_timestamp(), 'DATABASE_BUILD', 1);

ALTER TABLE core.principal
  ADD CONSTRAINT fk_principal_created_by FOREIGN KEY (created_by_principal_code)
    REFERENCES core.principal (principal_code),
  ADD CONSTRAINT fk_principal_updated_by FOREIGN KEY (updated_by_principal_code)
    REFERENCES core.principal (principal_code);

ALTER TABLE core.database_change
  ADD CONSTRAINT fk_database_change_applied_by FOREIGN KEY (applied_by_principal_code)
    REFERENCES core.principal (principal_code);

ALTER TABLE core.principal_type
  ADD CONSTRAINT fk_principal_type_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
  ADD CONSTRAINT fk_principal_type_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code);

ALTER TABLE core.unit_class
  ADD CONSTRAINT fk_unit_class_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
  ADD CONSTRAINT fk_unit_class_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code);

ALTER TABLE core.business_area
  ADD CONSTRAINT fk_business_area_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
  ADD CONSTRAINT fk_business_area_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code);

ALTER TABLE core.transaction_type
  ADD CONSTRAINT fk_transaction_type_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
  ADD CONSTRAINT fk_transaction_type_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code);

ALTER TABLE core.role_code
  ADD CONSTRAINT fk_role_code_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
  ADD CONSTRAINT fk_role_code_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code);

CREATE INDEX ix_principal_type_active ON core.principal (principal_type_code, is_active);
