# PFD Public Sample and Private Configuration Decision

**Status:** Approved  
**Date:** September 5, 2026

## Decision

PFD source code, database schema changes, design specifications, tests, and repository history must not contain real personal names, private business identity, private street addresses, credentials, financial identifiers, or other private operating data.

The public repository will contain a complete fictional sample-company baseline suitable for demonstration, testing, and deterministic simulation. The sample uses invented business, facility, owner, employee, customer, supplier, and financial data. Sample values must be clearly fictional and must not be copied from the private operating configuration.

A private local baseline may contain real names, addresses, and other approved operating information. It uses the same file formats, loader, validation, relational structures, and business rules as the public sample, but resides outside the public repository. Selecting a baseline is explicit; the software does not silently combine sample and private data.

## Business identity

Business legal name, display name, addresses, facilities, timezone, reporting currency, registrations, and related identity values are opening business data. Database schema changes create the structures and constraints but do not hard-code a particular business identity.

## Ownership and governance

The owner roster is configurable opening business data rather than fixed architecture.

- The approved operational baseline contains one or more effective owners.
- Each owner has a stable natural Owner Number and links to the applicable Party/Person.
- Ownership interests are effective-dated and total exactly 100 percent at every approved operational baseline time.
- Management responsibility is assigned independently from ownership percentage.
- An owner may or may not be an Employee.
- Reserved-matter approval thresholds are effective-dated governance configuration and must remain valid for the active owner roster.
- An affected owner cannot satisfy an independent-approval requirement for that owner's own compensation, distribution, or related-party matter.

The public sample may use any plausible fictional owner roster. Its number of owners, percentages, and assignments are sample data and do not constrain private configurations.

## Configuration boundary

- Schema and permanent database changes are common to all configurations.
- Public sample data is versioned separately from schema changes.
- Private data uses the same versioned templates and validations but remains outside the repository.
- Credentials and connection details are separate from business configuration.
- Generated reports, exports, logs, backups, and database dumps containing private data are not public-repository artifacts.
- Simulations use the selected baseline's ordinary business records and normal transaction logic without simulation-run identifiers in ordinary tables.

## Implementation consequence

Core schema construction creates `core.company` without inserting a named company. A selected opening dataset supplies the Company row and later identity, ownership, Party, Facility, and Address records. Structural verification tests the schema independently; baseline verification tests that the selected business configuration is complete, internally consistent, and approved.
