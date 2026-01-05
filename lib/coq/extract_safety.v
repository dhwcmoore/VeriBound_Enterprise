Require Import SafetyCore.
Require Extraction.
Extraction Language OCaml.

(* Extract specific definitions *)
Extraction "safety_core.ml" 
  SafetyCore.safety_margin
  SafetyCore.safety_precision_requirement
  SafetyCore.safety_critical
  SafetyCore.SimpleBoundary.
