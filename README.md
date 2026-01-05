# VeriBound Enterprise
> **High-Assurance Data Governance Kernel**

VeriBound is a formally verified boundary enforcement engine. It prevents "Data Blind Spots" (values falling into undefined gaps) by using a strict mathematical schema rather than standard if-then logic.

## 🏗 Architecture
The system follows a "Kernel-Interface" separation:
* **`lib/runtime` (The Kernel):** Pure OCaml logic that enforces boundary definitions.
* **`lib/coq` (The Specification):** Formal proofs (in Coq/Flocq) defining the mathematical correctness of the boundaries.
* **`data/` (The Rules):** YAML-based domain definitions (e.g., Pharma, Nuclear).
* **`bin/` (The Interface):** CLI tool for inspecting values.

## 🚀 Quick Start

### 1. Build the Project
```bash
dune build
```

### 2. Run a Verification
Inspect a value against a domain (e.g., Pharma Dose Safety):
```bash
./_build/default/bin/main.exe inspect pharma_dose_safety 1.5
# ✅ RESULT: Therapeutic_Safe
```

### 3. The "Safety Gap" Demo
VeriBound correctly rejects values that fall between defined rules (Standard parsers often fail here):
```bash
./_build/default/bin/main.exe inspect pharma_dose_safety 3.5
# ✅ RESULT: Unknown (Refused)
```

## 📂 Project Structure
| Directory | Purpose |
|-----------|---------|
| `lib/`    | Core logic (Kernel) |
| `bin/`    | Executable entry point |
| `data/`   | Domain configuration files |
| `tests/`  | Integration tests |

## 🛡 Verification Status
* **Runtime:** OCaml 5.x (Type-safe)
* **Specification:** Coq 8.19+ (Mathematical Proofs preserved in `lib/coq`)
