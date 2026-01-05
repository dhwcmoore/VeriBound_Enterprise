Require Import EPA_Precision_Standards.
Require Extraction.
Extraction Language OCaml.

Extraction "epa_standards.ml"
  EPA_Environmental_Standards.epa_measurement_precision
  EPA_Environmental_Standards.aqi_good_limit
  EPA_Environmental_Standards.nox_emission_limit.
