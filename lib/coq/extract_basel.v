Require Import Basel_Risk_Boundaries.
Require Extraction.
Extraction Language OCaml.

Extraction "basel_risk.ml"
  Basel_Risk_Management.basel_minimum_capital_ratio
  Basel_Risk_Management.var_confidence_level
  Basel_Risk_Management.basel_tier1_ratio.
