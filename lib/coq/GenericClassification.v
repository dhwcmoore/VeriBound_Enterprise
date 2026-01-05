(* File: core/ocaml/domain_parser.ml *)
open Yaml

(* Type representing a classification boundary *)
type class_boundary = {
  lower: int;
  upper: int;
  category: string;
}

(* Type representing a domain configuration *)
type classification_domain = {
  name: string;
  unit: string;
  boundaries: class_boundary list;
  global_bounds: int * int;
}

let extract_string field key =
  match field with
  | `O assoc ->
      (match List.assoc_opt key assoc with
       | Some (`String s) -> s
       | _ -> failwith ("Missing or invalid string field: " ^ key))
  | _ -> failwith "Expected object for domain"

let parse_boundary_yaml = function
  | `O assoc ->
      let range = List.assoc "range" assoc in
      let category = List.assoc "category" assoc in
      (match range, category with
       | `A [`Float lower; `Float upper], `String cat ->
           { lower = int_of_float lower; upper = int_of_float upper; category = cat }
       | _ -> failwith "Invalid boundary format")
  | _ -> failwith "Boundary must be an object"

let parse_domain_config filename =
  match Yaml.of_file filename with
  | Error (`Msg msg) -> failwith ("YAML parse error: " ^ msg)
  | Ok (`O yaml_assoc) ->
      let domain = List.assoc "domain" yaml_assoc in
      let boundaries = List.assoc "boundaries" yaml_assoc in
      let name = extract_string domain "name" in
      let unit = extract_string domain "unit" in
      let boundary_list = match boundaries with
        | `A list -> List.map parse_boundary_yaml list
        | _ -> failwith "boundaries must be array" in
      let lower_bounds = List.map (fun b -> b.lower) boundary_list in
      let upper_bounds = List.map (fun b -> b.upper) boundary_list in
      let global_bounds = (List.fold_left min max_int lower_bounds, List.fold_left max min_int upper_bounds) in
      { name; unit; boundaries = boundary_list; global_bounds }
  | _ -> failwith "Invalid YAML structure"

(* Expose types *)
let get_domain_name d = d.name
let get_unit d = d.unit
let get_boundaries d = d.boundaries
let get_bounds d = d.global_bounds
