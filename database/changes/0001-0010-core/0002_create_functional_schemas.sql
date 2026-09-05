-- Change 0002: create approved functional schemas.
-- Requires: 0001. Transaction: required.

SET LOCAL ROLE pfd_database_owner;

CREATE SCHEMA party AUTHORIZATION pfd_database_owner;
CREATE SCHEMA simulation AUTHORIZATION pfd_database_owner;
CREATE SCHEMA hr AUTHORIZATION pfd_database_owner;
CREATE SCHEMA product AUTHORIZATION pfd_database_owner;
CREATE SCHEMA sales AUTHORIZATION pfd_database_owner;
CREATE SCHEMA credit AUTHORIZATION pfd_database_owner;
CREATE SCHEMA purchasing AUTHORIZATION pfd_database_owner;
CREATE SCHEMA inventory AUTHORIZATION pfd_database_owner;
CREATE SCHEMA warehouse AUTHORIZATION pfd_database_owner;
CREATE SCHEMA transport AUTHORIZATION pfd_database_owner;
CREATE SCHEMA quality AUTHORIZATION pfd_database_owner;
CREATE SCHEMA service AUTHORIZATION pfd_database_owner;
CREATE SCHEMA finance AUTHORIZATION pfd_database_owner;
CREATE SCHEMA reporting AUTHORIZATION pfd_database_owner;
CREATE SCHEMA audit AUTHORIZATION pfd_database_owner;
CREATE SCHEMA staging AUTHORIZATION pfd_database_owner;

REVOKE ALL ON SCHEMA public FROM PUBLIC;

