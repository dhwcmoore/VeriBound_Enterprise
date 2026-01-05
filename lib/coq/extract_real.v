From VeriboundCore Require Import FlocqTypes.
From VeriboundCore Require Import FlocqClassification.
Require Extraction.

(* Extract your PROVEN functions *)
Extraction "extracted_flocq_REAL.ml" 
  classify_flocq 
  boundary_distance_flocq 
  confidence_level_flocq.
