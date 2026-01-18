# VeriBound Enterprise

**A formally verified boundary enforcement kernel in OCaml and Coq.**

VeriBound prevents a specific class of failure: computations that are internally correct but externally invalid because they have been applied outside the boundary where their assumptions hold. The system makes these boundaries explicit, enforces them at the type level where possible, and refuses to produce results when boundary conditions are violated.

---

## The Problem This Solves

Consider a classification system that assigns risk categories based on numeric thresholds. A naive implementation checks whether a value falls within predefined ranges and returns the corresponding category. This works until someone passes a value that falls outside all defined ranges, or until the ranges themselves contain gaps or overlaps that the original developer did not anticipate.

The dangerous failure mode is not an exception or a crash. It is a confident answer that happens to be wrong. The system returns "Low Risk" for a value that was never intended to be classified at all, because the conditional logic has a default case, or because floating-point comparison behaves unexpectedly at boundary values.

VeriBound addresses this by treating boundary definitions as first-class objects with formally verified properties. The system refuses to classify values that fall into undefined regions. It surfaces gaps in boundary definitions as explicit safety failures rather than silent misclassifications. And it uses Coq-extracted code to ensure that the runtime behaviour matches the formally specified semantics.

---

## Design Principles

### Boundaries Are Data, Not Code

Traditional classification systems encode boundaries as conditional logic scattered throughout the codebase. VeriBound treats boundaries as structured data loaded from YAML definitions. This separation means boundary definitions can be audited, versioned, and formally verified independently of the classification logic.

```yaml
# data/pharma_dose_safety.yaml
boundaries:
  - range: [0.0, 0.5]
    category: Sub_Therapeutic
  - range: [0.5, 2.0]
    category: Therapeutic_Safe
  - range: [2.0, 5.0]
    category: Elevated_Risk
  - range: [5.0, 10.0]
    category: Critical
```

The parser validates that ranges are well-formed, non-overlapping, and cover the expected domain. Gaps between ranges are intentional: they represent regions where classification is undefined, and the system will refuse to produce a result for values in those regions.

### Unknown Is Not an Error

When a value falls outside all defined boundaries, VeriBound returns `Unknown`. This is not a failure state to be caught and handled. It is information: the system is telling you that the input does not belong to any category you have defined.

```ocaml
type classification_result =
  | Classified of category
  | Unknown of { value: float; reason: string }
  | Invalid of { value: float; violation: boundary_violation }
```

The distinction between `Unknown` and `Invalid` matters. `Unknown` means the value is well-formed but falls outside defined boundaries. `Invalid` means the value violates structural constraints (negative values in a domain that requires positivity, NaN, infinity). Both prevent silent misclassification, but they represent different kinds of boundary failure.

### Formal Specification Drives Implementation

The Coq specifications in `lib/coq/` define what it means for a boundary system to be correct. These are not documentation or aspirational properties. They are machine-checked proofs that the boundary definitions satisfy required invariants: no overlaps, no gaps within the intended domain, correct handling of boundary values.

The OCaml runtime uses parameters extracted from these proofs. When the Coq specification says that boundary comparisons use exclusive upper bounds, the OCaml code uses the same convention because it was generated from the same source. This eliminates the class of bugs where specification and implementation disagree about edge cases.

---

## Architecture

```
lib/
├── boundary_kernel.ml    # Core classification logic
├── domain_loader.ml      # YAML parsing and validation
├── safety_types.ml       # Result types encoding success/failure modes
└── coq/
    ├── SafetyCore.v      # Formal boundary specifications
    ├── Extraction.v      # OCaml code extraction
    └── domain_proofs/    # Per-domain correctness proofs
```

The architecture enforces a clear separation between:

1. **Specification** (Coq): What properties must hold for the system to be correct.
2. **Configuration** (YAML): What boundaries apply in a specific domain.
3. **Execution** (OCaml): How classification is performed at runtime.

This separation means you can change boundary definitions without touching code, verify new domains without modifying the kernel, and audit the formal properties without reading the implementation.

---

## Usage

### Classify a Value

```bash
dune exec -- bin/main.exe inspect pharma_dose_safety 1.5
# → Classified: Therapeutic_Safe

dune exec -- bin/main.exe inspect pharma_dose_safety 1.75
# → Unknown: value 1.75 falls in undefined region (1.5, 2.0)
```

The second result is not a bug. If your domain definition has a gap between `[0.5, 1.5]` and `[2.0, 5.0]`, values in that gap are genuinely unclassified. The system surfaces this rather than guessing.

### Scan Domain Definitions

```bash
dune exec -- bin/scan_domains.exe
# Reports which YAMLs load successfully and how many boundaries were extracted
```

This is useful for validating domain definitions before deployment. A domain that loads with zero boundaries is not necessarily broken, but it probably deserves attention.

### Run Tests

```bash
dune exec -- tests/test_alcotest.exe
```

The test suite includes edge cases that most classification systems get wrong: values exactly on boundary edges, negative values in positive-only domains, gaps between ranges, and parse errors in malformed YAML.

---

## Why This Design?

The design reflects a conviction that the most dangerous bugs are not the ones that crash your system. They are the ones that produce plausible-looking results that happen to be wrong. A classification system that returns "Low Risk" for an unclassifiable input is worse than one that refuses to answer, because the wrong answer will propagate through downstream systems while the refusal will be noticed and investigated.

VeriBound is opinionated about this. It will not guess. It will not default. It will tell you exactly what it knows and does not know, and it will do so in a way that is formally verified to be consistent with its specifications.

This is not the right design for every system. If you need a classifier that always produces an answer, VeriBound is not for you. But if you need a classifier that never lies about its confidence, this is what that looks like.

---

## For Educators and New Contributors

If you are trying to understand how VeriBound works, start here:

1. **Read `lib/safety_types.ml` first.** The type definitions tell you what the system considers success and failure. Everything else follows from these types.

2. **Look at a simple domain YAML.** The `data/pharma_dose_safety.yaml` file shows the structure. Notice how ranges are explicit and gaps are visible.

3. **Trace a classification through the code.** Start at `bin/main.exe`, follow the call to `Boundary_kernel.classify`, and watch how the result type forces you to handle all cases.

4. **Read the Coq specifications last.** The formal proofs are the most abstract part of the system. They will make more sense after you understand what properties they are proving.

The codebase is structured to be read, not just executed. If something is unclear, that is a bug in the documentation.

---

## Project Status

VeriBound is research-grade software. It demonstrates a design philosophy and architectural approach rather than providing a production-ready library. The formal verification is real, the OCaml code runs, and the test suite passes, but the system has not been hardened for adversarial inputs or optimised for performance.

Contributions are welcome, particularly:

- Additional domain definitions with interesting boundary structures
- Edge cases that the current test suite does not cover
- Documentation improvements that make the design clearer

See `CONTRIBUTING.md` for guidelines.

---

## License

MIT. See `LICENSE` for details.