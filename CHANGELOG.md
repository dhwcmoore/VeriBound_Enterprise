# Changelog

## v2.0 — 2026-01-10

High level summary of changes included in this release:

- **YAML parser improvements**: Added support for `categories:` schemas by heuristically extracting the first numeric range field (e.g., `adverse_event_rate: [a,b]`) to convert categories into ranges.
- **Safety behavior**: Values outside defined ranges correctly return `Unknown` to refuse unsafe classification (safety-gap detection preserved).
- **Test suite overhaul**: Replaced legacy test harness with an Alcotest-based suite (`tests/test_alcotest.ml`) covering representative domains, edge cases, parse errors, and known safety gaps.
- **CI**: Added GitHub Actions workflow to build the project and run Alcotest tests on push/PR to `main` (`.github/workflows/ci.yml`).
- **Tools & utilities**: Added `bin/scan_domains.exe` to scan and report which domain YAMLs load and how many boundaries were extracted.
- **Documentation**: Added `CONTRIBUTING.md` with parsing guidelines and examples; updated `README.md` to reflect current features and testing workflow.
- **Housekeeping**: Removed deprecated legacy test harness (`tests/test_classifications.ml`) to consolidate on Alcotest.

For details, see the individual commits in this release.
