(* Main classification engine - smooth runtime layer *)

module Classifier = struct
  module RuntimeClassifier = struct
  
  type simple_domain = {
    name: string;
    boundaries: (float * float * string) list;  (* lower, upper, category *)
  }
  
  type classification = {
    input_value: string;
    category: string;
    confidence: string;
    engine: string;
  }
  
  let classify_simple domain input_str =
    try
      let input_val = Float.of_string input_str in
      let rec find_category = function
        | [] -> "Unknown"
        | (lower, upper, category) :: rest ->
            if input_val >= lower && input_val < upper then category
            else find_category rest
      in
      {
        input_value = input_str;
        category = find_category domain.boundaries;
        confidence = "Runtime_Fast";
        engine = "Simple_Boundary_Logic";
      }
    with _ -> 
      {
        input_value = input_str;
        category = "Parse_Error";
        confidence = "Error";
        engine = "Simple_Boundary_Logic";
      }
      
end

end
