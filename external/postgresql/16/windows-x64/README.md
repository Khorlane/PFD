# PostgreSQL 16 Client for Windows x64

This directory contains the approved PostgreSQL client files used to compile and run PFD on 64-bit Windows.

Source version: PostgreSQL 16.14, Windows x64.

Included development files:

- `include/libpq-fe.h`
- `include/postgres_ext.h`
- `include/pg_config_ext.h`
- `lib/libpq.lib`

Included runtime files:

- `bin/libpq.dll`
- `bin/libssl-3-x64.dll`
- `bin/libcrypto-3-x64.dll`
- `bin/libintl-9.dll`
- `bin/libiconv-2.dll`
- `bin/libwinpthread-1.dll`

The runtime list was checked from the native DLL dependency chain. Windows system libraries and the Microsoft Visual C++ runtime are not duplicated here.

Vendor-provided licensing notices are retained under `licenses`.

Do not place PostgreSQL server binaries, database clusters, logs, passwords, or private configuration in this directory.
