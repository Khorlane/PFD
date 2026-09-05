-- Change 0008: create controlled business-number allocation.
-- Requires: 0007. Transaction: required.

SET LOCAL ROLE pfd_database_owner;

CREATE TABLE core.number_sequence (
    sequence_code text NOT NULL,
    prefix text,
    next_value bigint NOT NULL,
    display_width smallint NOT NULL,
    last_allocated_at timestamptz,
    last_allocated_by_principal_code text,
    updated_at timestamptz NOT NULL,
    updated_by_principal_code text NOT NULL,
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT pk_number_sequence PRIMARY KEY (sequence_code),
    CONSTRAINT fk_number_sequence_last_allocated_by FOREIGN KEY (last_allocated_by_principal_code) REFERENCES core.principal (principal_code),
    CONSTRAINT fk_number_sequence_updated_by FOREIGN KEY (updated_by_principal_code) REFERENCES core.principal (principal_code),
    CONSTRAINT ck_number_sequence_code_format CHECK (sequence_code ~ '^[A-Z][A-Z0-9_]*$'),
    CONSTRAINT ck_number_sequence_prefix_format CHECK (prefix IS NULL OR prefix ~ '^[A-Z0-9-]+$'),
    CONSTRAINT ck_number_sequence_next_positive CHECK (next_value > 0),
    CONSTRAINT ck_number_sequence_width CHECK (display_width BETWEEN 1 AND 18),
    CONSTRAINT ck_number_sequence_last_allocation_pair CHECK (
        (last_allocated_at IS NULL) = (last_allocated_by_principal_code IS NULL)
    ),
    CONSTRAINT ck_number_sequence_row_version CHECK (row_version > 0)
);

CREATE FUNCTION core.allocate_business_number(
    requested_sequence_code text,
    allocating_principal_code text
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, core
AS $pfd$
DECLARE
    selected_prefix text;
    selected_value bigint;
    selected_width smallint;
BEGIN
    IF requested_sequence_code IS NULL OR btrim(requested_sequence_code) = '' THEN
        RAISE EXCEPTION 'Sequence Code is required';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM core.principal
        WHERE principal_code = allocating_principal_code
          AND is_active
    ) THEN
        RAISE EXCEPTION 'Unknown or inactive allocating Principal: %', allocating_principal_code;
    END IF;

    SELECT prefix, next_value, display_width
      INTO selected_prefix, selected_value, selected_width
      FROM core.number_sequence
     WHERE sequence_code = requested_sequence_code
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown Number Sequence: %', requested_sequence_code;
    END IF;

    UPDATE core.number_sequence
       SET next_value = selected_value + 1,
           last_allocated_at = clock_timestamp(),
           last_allocated_by_principal_code = allocating_principal_code,
           updated_at = clock_timestamp(),
           updated_by_principal_code = allocating_principal_code,
           row_version = row_version + 1
     WHERE sequence_code = requested_sequence_code;

    RETURN coalesce(selected_prefix, '') || lpad(selected_value::text, selected_width, '0');
END
$pfd$;

REVOKE ALL ON FUNCTION core.allocate_business_number(text, text) FROM PUBLIC;

