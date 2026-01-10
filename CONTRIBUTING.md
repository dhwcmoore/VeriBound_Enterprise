# Contributing to VeriBound

Thanks for helping improve VeriBound! This document explains best practices for adding or editing domain YAMLs, how the runtime parses them, and how to add tests.

## Supported YAML formats
VeriBound supports two primary domain YAML styles:

1. `boundaries:` — explicit list of ranges. Preferred for clarity.

Example:

```yaml
---
domain:
  name: "Example Range Domain"
  unit: "units"

boundaries:
  - range: [0.0, 1.0]
    category: "Low"
  - range: [1.0, 5.0]
    category: "Medium"
  - range: [5.0, 10.0]
    category: "High"

global_bounds: [0.0, 10.0]
```

2. `categories:` — named categories with associated numeric fields (e.g., `adverse_event_rate`, `accuracy_percent`). The loader heuristically uses the *first numeric range field encountered* in the category as the classification range.

Example:

```yaml
---
domain:
  name: "Clinical Trial Safety"
  regulatory_authority: "FDA"

categories:
  - name: "No_Adverse_Events_CONTINUE"
    adverse_event_rate: [0.0, 0.05]
  - name: "Expected_Adverse_Events_MONITOR"
    adverse_event_rate: [0.05, 0.15]
```

Notes on heuristics & safety:
- The parser is intentionally conservative. If no clear numeric range is found in a category entry, that category will be ignored during conversion and may yield `Unknown` at runtime for values in that region.
- Values outside any category or explicit boundary produce `Unknown` results (the system refuses to classify) — this is by design to prevent unsafe assumptions.
- Ranges are treated as left-inclusive, right-exclusive: `[low, high)`.

## Adding or updating a domain
1. Add the YAML file to `data/`. Prefer `boundaries:` when possible.
2. Run `dune exec -- bin/scan_domains.exe` to verify the loader extracts boundaries correctly.
3. Add/update a test case in `tests/test_alcotest.ml` (see Tests section below) to cover a representative value and an edge case.
4. Submit a PR. CI runs the test suite automatically.

## Tests
We use Alcotest for test assertions. Add a test as a case in `tests/test_alcotest.ml` and follow the existing pattern:

- Each test is a tuple (filename, input_value, expected_category_string).
- If you expect a parse error, use the expected string `"Parse_Error"`.

Run tests locally:

```bash
dune build && dune exec -- tests/test_alcotest.exe
```

Or run the full Dune test runner:

```bash
dune runtest
```

## Coding Style & PRs
- Keep changes small and focused.
- Add tests for feature changes or bug fixes.
- CI must pass before merging.

Thanks — and welcome! If you'd like more detailed examples added to this guide, I can expand it.