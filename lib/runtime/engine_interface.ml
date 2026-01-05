(* File: src/flocq/engine_interface.ml *)
module type CLASSIFICATION_ENGINE = sig
  type boundary
  type domain
  type float_value = float
  
  val engine_name : string
  val precision_guarantee : string
  
  (* Core engine functions *)
  val parse_value : string -> float_value
  val classify : domain -> float_value -> string
  val confidence_level : domain -> float_value -> [`High | `Medium | `Low]
  val boundary_distance : domain -> float_value -> float
end
