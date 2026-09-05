-- Change 0005: create the configurable Company structure.
-- Requires: 0004. Transaction: required.

SET LOCAL ROLE pfd_database_owner;

CREATE TABLE core.company (
    company_code text NOT NULL,
    legal_name text NOT NULL,
    display_name text NOT NULL,
    default_currency_code text NOT NULL,
    business_timezone text NOT NULL,
    fiscal_year_start_month smallint NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL,
    created_by_principal_code text NOT NULL,
    updated_at timestamptz NOT NULL,
    updated_by_principal_code text NOT NULL,
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT pk_company PRIMARY KEY (company_code),
    CONSTRAINT fk_company_created_by FOREIGN KEY (created_by_principal_code) REFERENCES core.principal (principal_code),
    CONSTRAINT fk_company_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code),
    CONSTRAINT ck_company_code_format CHECK (company_code ~ '^[A-Z][A-Z0-9_]*$'),
    CONSTRAINT ck_company_legal_name_nonblank CHECK (btrim(legal_name) <> ''),
    CONSTRAINT ck_company_display_name_nonblank CHECK (btrim(display_name) <> ''),
    CONSTRAINT ck_company_currency_format CHECK (default_currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_company_timezone_nonblank CHECK (btrim(business_timezone) <> ''),
    CONSTRAINT ck_company_fiscal_start_month CHECK (fiscal_year_start_month BETWEEN 1 AND 12),
    CONSTRAINT ck_company_audit_times CHECK (updated_at >= created_at),
    CONSTRAINT ck_company_row_version CHECK (row_version > 0)
);
