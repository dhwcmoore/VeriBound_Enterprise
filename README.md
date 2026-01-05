# VeriBound Enterprise
> **Copyright © 2026 Duston Moore. All Rights Reserved.**
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18155887.svg)](https://doi.org/10.5281/zenodo.18155887)
> *Licensed under the MIT License.*

---

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

## 🌍 Supported Domains (Demo)
The kernel is domain-agnostic. Current configuration files include:

### 1. 🏦 Finance (Basel III)
Protect against bank insolvency by enforcing capital requirements.
```bash
./_build/default/bin/main.exe inspect basel_iii 2.0
# ✅ RESULT: Insolvent_Regulatory_Breach
```

### 2. ☢️ Nuclear Safety (PWR Reactor)
Trigger emergency shutdown (SCRAM) when core temperature exceeds limits.
```bash
./_build/default/bin/main.exe inspect nuclear_reactor 335.0
# ✅ RESULT: CRITICAL_SCRAM_IMMEDIATE
```
