-- Change 0007: create effective-dated Approval Authority.
-- Requires: 0006. Transaction: required.
-- btree_gist is used solely for concurrent-safe temporal non-overlap.

SET LOCAL ROLE pfd_database_owner;

CREATE EXTENSION btree_gist;

CREATE TABLE core.approval_authority (
  authority_code text NOT NULL,
  effective_from timestamptz NOT NULL,
  effective_through timestamptz,
  business_area_code text NOT NULL,
  transaction_type_code text NOT NULL,
  role_code text NOT NULL,
  minimum_amount numeric(19,4),
  maximum_amount numeric(19,4),
  required_approval_count smallint NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL,
  created_by_principal_code text NOT NULL,
  updated_at timestamptz NOT NULL,
  updated_by_principal_code text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_approval_authority PRIMARY KEY (authority_code, effective_from),
  CONSTRAINT fk_approval_authority_business_area FOREIGN KEY (business_area_code) REFERENCES core.business_area (business_area_code),
  CONSTRAINT fk_approval_authority_transaction_type FOREIGN KEY (transaction_type_code) REFERENCES core.transaction_type (transaction_type_code),
  CONSTRAINT fk_approval_authority_role_code FOREIGN KEY (role_code) REFERENCES core.role_code (role_code),
  CONSTRAINT fk_approval_authority_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
  CONSTRAINT fk_approval_authority_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code),
  CONSTRAINT ck_approval_authority_code_format CHECK (authority_code ~ '^[A-Z][A-Z0-9_]*$'),
  CONSTRAINT ck_approval_authority_dates CHECK (effective_through IS NULL OR effective_through > effective_from),
  CONSTRAINT ck_approval_authority_minimum CHECK (minimum_amount IS NULL OR minimum_amount >= 0),
  CONSTRAINT ck_approval_authority_maximum CHECK (maximum_amount IS NULL OR maximum_amount >= 0),
  CONSTRAINT ck_approval_authority_amount_range CHECK (
    minimum_amount IS NULL OR maximum_amount IS NULL OR maximum_amount >= minimum_amount
  ),
  CONSTRAINT ck_approval_authority_count CHECK (required_approval_count BETWEEN 1 AND 4),
  CONSTRAINT ck_approval_authority_audit_times CHECK (updated_at >= created_at),
  CONSTRAINT ck_approval_authority_row_version CHECK (row_version > 0),
  CONSTRAINT ex_approval_authority_no_overlap EXCLUDE USING gist (
    authority_code WITH =,
    tstzrange(effective_from, effective_through, '[)') WITH &&
  ) WHERE (is_active)
);

CREATE INDEX ix_approval_authority_lookup
  ON core.approval_authority (
    business_area_code, transaction_type_code, role_code, effective_from
  );

