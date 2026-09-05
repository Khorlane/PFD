# PFD

PFD is an open-source simulation of a regional food-distribution business. The project combines a normalized PostgreSQL system of record with a planned C++23/MFC Windows desktop application and deterministic business simulation.

## Project status

The business and database design baseline is complete. The executable PostgreSQL Core Build currently covers changes `0001` through `0010`. An initial Visual Studio 2026 C++23/MFC solution and desktop greeting are available; business workflows and later database domains have not yet been implemented.

## Visual Studio solution

Open `Pfd.slnx` in Visual Studio Community 2026. The solution contains:

- `PfdDesktop` — Windows-only MFC executable and current startup project
- `PfdDomain` — portable business entities, rules, and transaction logic
- `PfdDatabase` — portable database-access boundary for the planned `libpq` RAII layer
- `PfdSimulation` — portable simulation engine boundary
- `PfdReporting` — portable reporting and calculation boundary
- `PfdPlatform` — operating-system-specific implementation boundary
- `PfdTests` — lightweight test executable until broader test infrastructure is implemented

The solution targets Debug/x64 and Release/x64 with MSVC `v145`, C++23, MSBuild, and no CMake or vcpkg integration. Build output is written below `out/`.

## Data policy

The public repository contains only fictional sample data. Real names, addresses, credentials, financial identifiers, operational exports, reports, logs, and database backups must remain outside the repository.

A private local baseline may use the same formats and validation rules as the public sample baseline, but it must be stored outside the repository and selected explicitly.

## License

PFD is released under the Zero-Clause BSD (`0BSD`) license. See `LICENSE`.
