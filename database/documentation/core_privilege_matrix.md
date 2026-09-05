# PFD Core Privilege Matrix

| Role | Login | Inherits owner | Core access |
|---|---:|---:|---|
| `pfd_database_owner` | No | Not applicable | Owns controlled database objects. |
| `pfd_change_executor` | Yes | No | May explicitly assume owner only during an approved build. |
| `pfd_application` | Yes | No | Reads approved Core masters and references; executes controlled number allocation. |
| `pfd_reporting` | Yes | No | Reads non-sensitive Core reference and company data. |
| `pfd_support_readonly` | Yes | No | Reads all Core tables for authorized diagnostics. |
| `pfd_backup_operator` | Yes | No | No application-data grants in this package; infrastructure backup rights are platform-specific. |
| `PUBLIC` | Not applicable | No | No Core schema, table, or function access. |

Passwords, certificates, authentication mapping, role membership approval, and environment-specific backup permissions remain deployment controls and are intentionally absent from SQL source.
