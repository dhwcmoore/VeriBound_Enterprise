(* Shared Types - Common types across engines *)

(* Configuration types that work across engines *)
type raw_boundary = {
  lower_str: string; (* "5.6" or "5" - parsed by each engine *)
  upper_str: string;
  category: string;
}

type raw_domain = {
  name: string;
  unit: string;
  description: string option;
  boundaries: raw_boundary list;
  global_bounds_str: string * string;
}

(* Common boundary and domain types for engines *)
type boundary = {
  lower: float;
  upper: float;
  category: string;
}

type domain = {
  name: string;
  unit: string;
  boundaries: boundary list;
  global_bounds: float * float;
}

(* Output types for unified CLI *)
type classification_result = {
  input_value: string;
  category: string; 
  confidence: [`High | `Medium | `Low];
  boundary_distance: float;
  engine_used: string;
  precision_info: string;
  timestamp: float;
}

type output_format = [`Text | `JSON | `Detailed]

(* Error types for consistent error handling *)
type veribound_error = 
  | ParseError of string
  | ClassificationError of string 
  | EngineError of string * string (* engine_name, error_msg *)
  | ConfigError of string
