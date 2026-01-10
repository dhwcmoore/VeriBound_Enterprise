# VeriBound Enterprise  — High-Assurance Boundary Enforcement 

**VeriBound** is a mathematically verified boundary enforcement kernel that prevents "data blind spots" by using formally proven boundary definitions rather than ad-hoc conditional logic.

---

##  Highlights (What changed)
- **Improved YAML support:** Parser supports both `boundaries:` (explicit ranges) and `categories:` schemas commonly used in domain definitions. For `categories:`, the parser heuristically picks the first numeric range field (e.g., `adverse_event_rate: [a,b]`) as the classification range.
- **Safety-first behavior:** Values that fall outside any defined range correctly yield `Unknown` (refusal), surfacing safety gaps as intended.
- **Test coverage:** Representative classification tests (including edge cases, safety gaps, negative values, and parse errors) are in `tests/test_classifications.ml` (legacy), and a richer, structured test suite is implemented with **Alcotest** in `tests/test_alcotest.ml`.
- **CI:** A GitHub Actions workflow (`.github/workflows/ci.yml`) builds the project and runs both the legacy and Alcotest suites on push/PR to `main`.
- **Utilities:** `bin/scan_domains.exe` scans all YAMLs in `data/` and reports which domains load and how many boundaries were extracted.

---

##  Quick Start

### 1) Build
```bash
dune build
```

### 2) Inspect a value (CLI)
```bash
dune exec -- bin/main.exe inspect <domain> <value>
# Example
dune exec -- bin/main.exe inspect pharma_dose_safety 1.5
# → RESULT: Therapeutic_Safe
```

### 3) Run the scanner (reports loader status for each YAML)
```bash
dune exec -- bin/scan_domains.exe
```

### 4) Run tests locally
```bash
dune exec -- tests/test_alcotest.exe
# or run the full dune build and the test runner
dune build && dune runtest
```

---

##  Supported YAML formats & heuristics
- `boundaries:` — Expected explicit list of `- range: [low, high]` entries with a subsequent `category:` line.
- `categories:` — Each category may include named numeric range fields (e.g., `adverse_event_rate: [a,b]`, `accuracy_percent: [l,u]`); the current parser uses the **first numeric range** found in a category as its range.

Notes:
- The parser is intentionally conservative: missing numeric ranges, overlapping/malformed ranges, or values outside `global_bounds` are surfaced as `Unknown` to avoid unsafe assumptions.

---

##  Test & CI
- Tests: Alcotest-based suite `tests/test_alcotest.ml` contains representative and edge-case checks (e.g., safety gaps, upper/lower bound exclusivity, parse errors).
- CI: `.github/workflows/ci.yml` builds the project and runs the Alcotest suite (and `dune runtest`) on push/PR to `main`.

If you want richer test output, we use Alcotest for deterministic, well-formatted test results.

---

##  Verification & Formal Guarantees
- The Coq sources in `lib/coq/` (e.g., `SafetyCore.v`, domain-specific proofs) hold the formal specifications and safety theorems.
- Extracted parameters (via `extraction` scripts) are used to keep runtime values consistent with the proven specs.

---

##  Project layout
| Directory | Purpose |
|-----------|---------|
| `lib/`    | Kernel & runtime logic |
| `lib/coq` | Formal specs & proofs (Coq / Flocq) |
| `bin/`    | CLI tools (`main.exe`, `scan_domains.exe`) |
| `data/`   | Domain YAML definitions |
| `tests/`  | Lightweight classification tests |

---

##  Contributing
- Add new domain YAMLs under `data/`. Prefer `boundaries:` for explicit ranges. If you use `categories:`, include a clear numeric range field.
- Add a test case in `tests/test_alcotest.ml` for the representative value you expect.
- Push and open a PR — CI will run the test suite automatically.

---

