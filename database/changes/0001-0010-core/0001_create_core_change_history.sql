-- Change 0001: create Core schema and permanent database change history.
-- Requires: completed bootstrap. Transaction: required.
-- Recovery: transaction rollback before commit; forward correction after shared use.

SET LOCAL ROLE pfd_database_owner;

CREATE SCHEMA core AUTHORIZATION pfd_database_owner;

CREATE TABLE core.database_change (
    change_number text NOT NULL,
    change_name text NOT NULL,
    file_name text NOT NULL,
    file_checksum text NOT NULL,
    applied_at timestamptz NOT NULL,
    applied_by_principal_code text NOT NULL,
    execution_duration_ms bigint NOT NULL,
    application_release text,
    manifest_name text NOT NULL,
    manifest_version text NOT NULL,
    notes text,
    CONSTRAINT pk_database_change PRIMARY KEY (change_number),
    CONSTRAINT uq_database_change_file_name UNIQUE (file_name),
    CONSTRAINT ck_database_change_number_format CHECK (change_number ~ '^[0-9]{4}$'),
    CONSTRAINT ck_database_change_name_nonblank CHECK (btrim(change_name) <> ''),
    CONSTRAINT ck_database_change_file_name_nonblank CHECK (btrim(file_name) <> ''),
    CONSTRAINT ck_database_change_checksum_format CHECK (file_checksum ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_database_change_duration_nonnegative CHECK (execution_duration_ms >= 0),
    CONSTRAINT ck_database_change_actor_nonblank CHECK (btrim(applied_by_principal_code) <> ''),
    CONSTRAINT ck_database_change_manifest_nonblank CHECK (
        btrim(manifest_name) <> '' AND btrim(manifest_version) <> ''
    )
);

REVOKE ALL ON TABLE core.database_change FROM PUBLIC;

CREATE FUNCTION core.reject_database_change_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $pfd$
BEGIN
    RAISE EXCEPTION 'core.database_change is append-only; apply a forward change';
END
$pfd$;

CREATE TRIGGER tr_database_change_append_only
BEFORE UPDATE OR DELETE ON core.database_change
FOR EACH ROW EXECUTE FUNCTION core.reject_database_change_mutation();

REVOKE ALL ON FUNCTION core.reject_database_change_mutation() FROM PUBLIC;
