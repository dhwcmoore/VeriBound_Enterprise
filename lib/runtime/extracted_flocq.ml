(* extracted_flocq.ml - Manual implementation of Flocq functions *)
(* This provides the same interface as Coq extraction would generate *)

(* Types matching the Coq definitions *)
type verified_boundary = {
  lower_rational: float; (* Simplified from Q *)
  upper_rational: float;
  lower_float: float;
  upper_float: float;
  category: string;
}

type verified_domain = {
  domain_name: string;
  measurement_unit: string;
  boundaries: verified_boundary list;
  global_bounds: float * float;
  domain_precision_bound: float;
}

(* Core classification functions - manually implemented with same logic as Coq *)
let rec find_category_flocq boundaries x =
  match boundaries with
  | [] -> None
  | boundary :: rest ->
      (* IEEE 754 range checking *)
      if x >= boundary.lower_float && x <= boundary.upper_float then
        Some boundary.category
      else
        find_category_flocq rest x

let classify_flocq domain input =
  match find_category_flocq domain.boundaries input with
  | Some category -> category
  | None -> "CLASSIFICATION_ERROR"

let boundary_distance_flocq x boundary =
  let dist_lower = Float.abs (x -. boundary.lower_float) in
  let dist_upper = Float.abs (x -. boundary.upper_float) in
  Float.min dist_lower dist_upper

let min_distance_to_boundaries x boundaries =
  List.fold_left (fun min_dist boundary ->
    let dist_lower = Float.abs (x -. boundary.lower_float) in
    let dist_upper = Float.abs (x -. boundary.upper_float) in
    let boundary_dist = Float.min dist_lower dist_upper in
    Float.min min_dist boundary_dist
  ) 1000.0 boundaries

let confidence_level_flocq domain input =
  let min_dist = min_distance_to_boundaries input domain.boundaries in
  let bound = domain.domain_precision_bound in
  if min_dist <= (bound /. 3.0) then 1  (* Low *)
  else if min_dist <= (bound /. 1.5) then 2  (* Medium *)
  else 3  (* High *)

(* Helper functions for validation *)
let validate_boundary boundary =
  not (Float.is_nan boundary.lower_float || Float.is_infinite boundary.lower_float ||
       Float.is_nan boundary.upper_float || Float.is_infinite boundary.upper_float) &&
  boundary.lower_float <= boundary.upper_float

let validate_domain domain =
  List.for_all validate_boundary domain.boundaries
