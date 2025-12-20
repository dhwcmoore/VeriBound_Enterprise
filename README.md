# VeriBound

A mathematically verified boundary classification system for critical applications in healthcare, finance, environmental monitoring, and nuclear safety.

## What is VeriBound?

VeriBound classifies numeric values into predefined categories with mathematical certainty. The core classification logic is proven correct using the Coq theorem prover with Flocq for floating-point reasoning. This guarantees that edge cases, boundary overlaps, and classification algorithms behave exactly as specified.

**Why this matters:** In critical systems, incorrect classifications can be catastrophic. Traditional boundary logic uses ad-hoc if/else statements with no formal guarantees. VeriBound centralizes this logic into a verified framework where the classification algorithms are backed by formal proofs.

This system implements ideas from the paper "Boundary Discipline and the Structural Limits of Internal Certification," which establishes that internal verification cannot guarantee external safety without explicit boundary enforcement.

## Quick Start

```bash
git clone https://github.com/dhwcmoore/VeriBound_process_design.git
cd VeriBound_process_design
dune build
```

Try a classification:

```bash
dune exec -- bin/main.exe inspect diabetes 6.0
# Returns: Prediabetes
```

Test all domains:

```bash
dune exec -- bin/main.exe test-pipeline --all-domains
```

## How Boundaries Work

**Diabetes Classification (HbA1c %):**

```
[0.0──5.7]──[5.7──6.5]──[6.5──14.0]
  Normal    Prediabetes   Diabetes
                ↑
        Your value: 6.0 → Prediabetes
```

The system mathematically verifies that every value maps to exactly one category (mutual exclusion) and that every valid input is classified (complete coverage).

## Example Classifications

**Diabetes (HbA1c %)**
```bash
dune exec -- bin/main.exe inspect diabetes 5.0   # Normal
dune exec -- bin/main.exe inspect diabetes 6.0   # Prediabetes
dune exec -- bin/main.exe inspect diabetes 7.0   # Diabetes
```

**Blood Pressure (systolic mmHg)**
```bash
dune exec -- bin/main.exe inspect blood_pressure 90.0    # Normal
dune exec -- bin/main.exe inspect blood_pressure 140.0   # High
```

**Air Quality Index**
```bash
dune exec -- bin/main.exe inspect aqi 50.0    # Moderate
dune exec -- bin/main.exe inspect aqi 150.0   # Unhealthy
```

**Financial Risk (Basel III capital ratios)**
```bash
dune exec -- bin/main.exe inspect basel_iii_capital_adequacy 8.0   # Adequate
dune exec -- bin/main.exe inspect basel_iii_capital_adequacy 6.0   # Undercapitalized
```

## Commands

**Inspect** - Classify a value:
```bash
dune exec -- bin/main.exe inspect DOMAIN VALUE
```

**Verify** - Check domain integrity:
```bash
dune exec -- bin/main.exe verify diabetes
```

**Test Pipeline** - Run all domain tests:
```bash
dune exec -- bin/main.exe test-pipeline --all-domains
```

Add `--show-process` to any command to see detailed steps.

## Supported Domains (21 total)

**Healthcare & Medical (4)**
- `diabetes` - HbA1c classification (Normal/Prediabetes/Diabetes)
- `blood_pressure` - Hypertension staging
- `medical` - General medical thresholds
- `clinical_trial_safety` - Clinical trial safety boundaries

**Financial Risk & Compliance (8)**
- `basel_iii_capital_adequacy`
- `aml_cash`
- `ccar_capital_ratios`
- `ccar_loss_rates`
- `frtb_market_risk`
- `liquidity_risk_lcr_nsfr`
- `mifid2_best_execution`
- `basel_corporate`

**Environmental Monitoring (2)**
- `aqi` - Air Quality Index
- `aqi_fixed`

**Nuclear Safety (3)**
- `nuclear_emergency_action_levels`
- `nuclear_radiation_limits`
- `nuclear_reactor_protection`

**Pharmaceutical (2)**
- `pharma_dose_safety`
- `medical_device_performance`

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         CLI (bin/)                          │
├─────────────────────────────────────────────────────────────┤
│                  Engine Interface (OCaml)                   │
│         mathematical_extraction/engine_interface/           │
├──────────────────────────┬──────────────────────────────────┤
│   Domain Manager         │      Boundary Classifier         │
│   (YAML loader)          │      (verified logic)            │
├──────────────────────────┴──────────────────────────────────┤
│              Mathematical Verification (Coq)                │
│            mathematical_extraction/flocq_proofs/            │
├─────────────────────────────────────────────────────────────┤
│                  Domain Definitions (YAML)                  │
│              boundary_logic/domain_definitions/             │
└─────────────────────────────────────────────────────────────┘
```

**Classification Process:**
1. Parse command
2. Load domain YAML from `boundary_logic/domain_definitions/`
3. Validate input against global bounds
4. Classify via verified logic
5. Return structured result with confidence and engine ID

## Domain Definition Format

Example: Diabetes (HbA1c)

```yaml
name: "Diabetes (HbA1c)"
unit: "%"
description: "Hemoglobin A1c (percent)"
global_bounds: [0.0, 14.0]
boundaries:
  - range: [0.0, 5.7]
    category: "Normal"
    color: "green"
  - range: [5.7, 6.5]
    category: "Prediabetes"
    color: "yellow"
  - range: [6.5, 14.0]
    category: "Diabetes"
    color: "red"
```

## Classification Result Type

```ocaml
type classification_result = {
  input_value: string;
  category: string;
  confidence: string;
  engine: string;
}
```

Example output:
```
Classification Result for diabetes = 6.00:
  Category: Prediabetes
  Confidence: Runtime_Fast
```

## Dependencies

- OCaml (>= 4.14)
- Dune (>= 3.0)
- Coq (for mathematical verification)
- Yojson

## Validation

Validated against 25,739 clinical records from NHANES 2017-2018 data, demonstrating robustness with real-world clinical noise, demographic stratification, and multimodal data integration. See the paper "Formal Verification of Statistical Class Boundaries" for details.

## Adding a New Domain

1. Create YAML file in `boundary_logic/domain_definitions/`
2. Follow the format above (boundaries must be non-overlapping and complete)
3. Verify: `dune exec -- bin/main.exe verify <domain>`
4. Test: `dune build @all`

Always run `./test_all_domains.sh` before committing.

## Current Status

- **Version:** 2.1.0 (Production Ready)
- **Build:** Compiles
- **Tests:** Passing
- **Domains:** 21 operational
- **Coq:** Integrated (VerifiedBoundaryHelpers.vo)

## License

Apache-2.0. © 2025 Duston Moore

## Contact

Duston Moore  
dhwcmoore@gmail.com  
GitHub: [dhwcmoore](https://github.com/dhwcmoore)
