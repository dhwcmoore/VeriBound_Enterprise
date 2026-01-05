(* Flocq Engine - IEEE 754 Formal Verification Engine *)
open Engine_interface
open Shared_types

(* Import the extracted Flocq code *)
module Extracted = Extracted_flocq

(* Convert between interface types and Flocq types *)
let convert_boundary (b : boundary) : Extracted.verified_boundary =
  {
    lower_rational = b.lower;
    upper_rational = b.upper;
    lower_float = b.lower;
    upper_float = b.upper;
    category = b.category;
  }

let convert_domain (d : domain) : Extracted.verified_domain =
  {
    domain_name = d.name;
    measurement_unit = d.unit;
    boundaries = List.map convert_boundary d.boundaries;
    global_bounds = d.global_bounds;
    domain_precision_bound = 0.001;
  }

(* Main Flocq Engine Module implementing CLASSIFICATION_ENGINE *)
module FlocqEngine : CLASSIFICATION_ENGINE = struct
  
  type boundary = Shared_types.boundary
  type domain = Shared_types.domain
  type float_value = float
  
  (* Parse string to float with IEEE 754 validation *)
  let parse_value (s : string) : float_value =
    try
      let f = Float.of_string s in
      if Float.is_nan f || Float.is_infinite f then
        failwith ("Invalid IEEE 754 float value: " ^ s)
      else f
    with Failure _ -> 
      failwith ("Cannot parse as float: " ^ s)

  (* IEEE 754 proven classification using extracted Flocq engine *)
  let classify (domain : domain) (input : float_value) : string =
    let flocq_domain = convert_domain domain in
    Extracted.classify_flocq flocq_domain input

  (* Confidence level using verified boundary distance calculation *)
  let confidence_level (domain : domain) (input : float_value) : [`High | `Medium | `Low] =
    let flocq_domain = convert_domain domain in
    match Extracted.confidence_level_flocq flocq_domain input with
    | 1 -> `Low
    | 2 -> `Medium  
    | 3 -> `High
    | _ -> `Low

  (* Boundary distance calculation with verified precision *)
  let boundary_distance (domain : domain) (input : float_value) : float =
    let flocq_domain = convert_domain domain in
    Extracted.min_distance_to_boundaries input flocq_domain.boundaries
    
  (* Engine metadata *)
  let engine_name = "FlocqEngine"
  
  let precision_guarantee = 
    "IEEE 754 double precision with formal verification guarantees. " ^
    "Mathematically proven: classification soundness, boundary precision, " ^
    "mutual exclusion, and complete coverage. All operations verified using Coq/Rocq. " ^
    "Provides mathematical correctness guarantees. Recommended for safety-critical, medical, " ^
    "financial, and regulatory compliance applications where formal verification is required."
    
end
