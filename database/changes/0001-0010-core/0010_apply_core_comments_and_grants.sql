-- Change 0010: apply Core comments, grants, revocations, and default privileges.
-- Requires: 0009. Transaction: required.

SET LOCAL ROLE pfd_database_owner;

COMMENT ON SCHEMA core IS 'Shared PFD governance, natural keys, units, and database change control.';
COMMENT ON TABLE core.database_change IS 'Immutable history of permanent SQL changes applied to this PFD database.';
COMMENT ON COLUMN core.database_change.change_number IS 'Four-digit natural primary key matching the permanent SQL file sequence.';
COMMENT ON TABLE core.principal IS 'Responsible human or process identity used in audit columns; contains no authentication secret.';
COMMENT ON TABLE core.company IS 'Configurable legal and operating identity of the simulated business.';
COMMENT ON TABLE core.unit_of_measure IS 'Approved fixed units; does not enable catch-weight pricing.';
COMMENT ON TABLE core.approval_authority IS 'Effective-dated authorization by business area, transaction type, role, and amount range.';
COMMENT ON TABLE core.number_sequence IS 'Controlled allocator for permanent business numbers; MAX plus one is prohibited.';
COMMENT ON FUNCTION core.allocate_business_number(text, text) IS 'Atomically allocates one permanent PFD business number under row lock.';

REVOKE ALL ON SCHEMA core FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA core FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA core FROM PUBLIC;

GRANT USAGE ON SCHEMA core TO pfd_change_executor, pfd_application, pfd_reporting, pfd_support_readonly;
GRANT SELECT ON core.database_change TO pfd_change_executor;

GRANT SELECT ON core.company, core.principal_type, core.unit_class,
        core.business_area, core.transaction_type, core.role_code,
        core.unit_of_measure, core.approval_authority
  TO pfd_application;
GRANT SELECT ON core.number_sequence TO pfd_application;
GRANT EXECUTE ON FUNCTION core.allocate_business_number(text, text) TO pfd_application;

GRANT SELECT ON core.company, core.principal_type, core.unit_class,
        core.business_area, core.transaction_type, core.role_code,
        core.unit_of_measure
  TO pfd_reporting;

GRANT SELECT ON ALL TABLES IN SCHEMA core TO pfd_support_readonly;

ALTER DEFAULT PRIVILEGES FOR ROLE pfd_database_owner IN SCHEMA core
  REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE pfd_database_owner IN SCHEMA core
  REVOKE ALL ON FUNCTIONS FROM PUBLIC;

DO $pfd$
DECLARE
  schema_name text;
BEGIN
  FOREACH schema_name IN ARRAY ARRAY[
    'party', 'simulation', 'hr', 'product', 'sales', 'credit', 'purchasing',
    'inventory', 'warehouse', 'transport', 'quality', 'service', 'finance',
    'reporting', 'audit', 'staging'
  ]
  LOOP
    EXECUTE format('REVOKE ALL ON SCHEMA %I FROM PUBLIC', schema_name);
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO pfd_application', schema_name);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE pfd_database_owner IN SCHEMA %I REVOKE ALL ON TABLES FROM PUBLIC', schema_name);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE pfd_database_owner IN SCHEMA %I REVOKE ALL ON FUNCTIONS FROM PUBLIC', schema_name);
  END LOOP;
END
$pfd$;
