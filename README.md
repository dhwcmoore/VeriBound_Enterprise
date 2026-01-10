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
dune exec -- bin/main.exe inspect pharma_dose_safety 1.5
# ✅ RESULT: Therapeutic_Safe
```

Or use the built executable directly:
```bash
./_build/default/bin/main.exe inspect pharma_dose_safety 1.5
```

### 3. The "Safety Gap" Demo
VeriBound correctly rejects values that fall between defined rules (Standard parsers often fail here):
```bash
dune exec -- bin/main.exe inspect pharma_dose_safety 3.5
# ✅ RESULT: Unknown (Refused)
```

## 🧪 Testing

### Run Individual Tests
```bash
# Test domain loader
ocamlfind ocamlopt -package yojson -linkpkg -I +str str.cmxa -I _build/default/lib/runtime veribound_kernel.cmxa test_domain_loader.ml -o test_domain_loader && ./test_domain_loader

# Test module access
ocamlfind ocamlopt -package yojson -linkpkg -I +str str.cmxa -I _build/default/lib/runtime veribound_kernel.cmxa test_module_access.ml -o test_module_access && ./test_module_access

# Test integration
ocamlfind ocamlopt -package yojson -linkpkg -I +str str.cmxa -I _build/default/lib/runtime veribound_kernel.cmxa test_integration.ml -o test_integration && ./test_integration
```

### Verify All Domains
Test the CLI against all available domains:
```bash
dune exec -- bin/main.exe inspect diabetes 150
dune exec -- bin/main.exe inspect basel_iii 2.0
dune exec -- bin/main.exe inspect nuclear_reactor 335.0
dune exec -- bin/main.exe inspect aqi 250
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
dune exec -- bin/main.exe inspect basel_iii 2.0
# ✅ RESULT: Insolvent_Regulatory_Breach
```

### 2. ☢️ Nuclear Safety (PWR Reactor)
Trigger emergency shutdown (SCRAM) when core temperature exceeds limits.
```bash
dune exec -- bin/main.exe inspect nuclear_reactor 335.0
# ✅ RESULT: CRITICAL_SCRAM_IMMEDIATE
```

### 3. 💊 Pharma Dose Safety
Verify medication dosages are within therapeutic range.
```bash
dune exec -- bin/main.exe inspect pharma_dose_safety 1.5
# ✅ RESULT: Therapeutic_Safe
```

### 4. 🌍 Air Quality Index (AQI)
Monitor environmental air quality compliance.
```bash
dune exec -- bin/main.exe inspect aqi 250
```

### 5. 🏥 Diabetes Management
Blood glucose boundary enforcement for patient safety.
```bash
dune exec -- bin/main.exe inspect diabetes 150
```

## 📋 Complete List of Domains
- aml_cash (Anti-Money Laundering)
- aqi, aqi_fixed (Air Quality Index)
- basel_corporate, basel_iii, basel_iii_capital_adequacy (Financial Regulation)
- blood_pressure (Medical)
- ccar_capital_ratios, ccar_loss_rates, ccar_stress_testing, ccar_stress (Banking Stress Tests)
- clinical_trial_safety (Pharma)
- diabetes (Medical)
- frtb_market_risk (Financial Risk)
- liquidity_risk_lcr_nsfr (Banking Liquidity)
- medical, medical_device_performance (Medical Devices)
- mifid2_best_execution (Financial Compliance)
- nuclear_emergency_action_levels, nuclear_radiation_limits, nuclear_reactor, nuclear_reactor_protection (Nuclear Safety)
- pharma_dose_safety (Pharma)
