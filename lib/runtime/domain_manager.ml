(* Domain management with YAML configuration support *)
(* Uses existing Shared_types definitions - no Coq conversion needed *)

module DomainManager = struct
  
  (* Try accessing types directly from the library *)
  (* Since shared_types is compiled into flocq_engine library *)
  
  (* Define the types we need - match exactly what's in shared_types.ml *)
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
  
  (* Define raw types locally to match actual YAML structure *)
  type raw_boundary = {
    range: float * float;  (* [lower, upper] from YAML *)
    category: string;
    color: string option;  (* Optional color field *)
  }
  
  type monitoring_config = {
    base_tolerance: float;
    confidence_thresholds: float list;
  }
  
  type raw_domain = {
    name: string;
    unit: string;
    description: string option;
    boundaries: raw_boundary list;
    global_bounds: float * float;  (* [lower, upper] from YAML *)
    monitoring: monitoring_config option;
  }
  
  (* Read file content using compatible approach *)
  let read_file filename =
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    content
  type domain_load_result = {
    domain: domain;  (* Uses existing Shared_types.domain *)
    source_file: string;
    boundary_count: int;
    validation_status: [`Valid | `Warning of string];
  }
  
  type domain_error = 
    | FileNotFound of string
    | ParseError of string * int * string  (* file, line, error *)
    | ValidationError of string
    | ConversionError of string
  
  (* Convert raw_domain (from YAML) to domain (for engine) *)
  let raw_to_domain raw_domain =
    try
      (* Convert range boundaries to separate lower/upper boundaries *)
      let boundaries = List.map (fun raw_boundary ->
        let (lower_val, upper_val) = raw_boundary.range in
        {
          lower = lower_val;
          upper = upper_val;
          category = raw_boundary.category;
        }
      ) raw_domain.boundaries in
      
      (* Global bounds are already float tuple *)
      let global_bounds = raw_domain.global_bounds in
      
      (* Create the domain using our local types *)
      let domain = {
        name = raw_domain.name;
        unit = raw_domain.unit;
        boundaries = boundaries;
        global_bounds = global_bounds;
      } in
      
      Ok {
        domain = domain;
        source_file = ""; (* Will be filled by load_from_yaml *)
        boundary_count = List.length boundaries;
        validation_status = `Valid;
      }
    with
    | Failure msg -> Error (ConversionError ("Float conversion failed: " ^ msg))
    | exn -> Error (ConversionError (Printexc.to_string exn))
  
  (* Simple YAML parser for our specific domain format *)
  let parse_yaml_content content _filename =
    try
      let lines = String.split_on_char '\n' content in
      let lines = List.map String.trim lines in
      let non_empty_lines = List.filter (fun line -> line <> "" && not (String.starts_with ~prefix:"#" line)) lines in
      
      (* Extract domain section *)
      let rec extract_domain_field field_name lines =
        match lines with
        | [] -> None
        | line :: rest ->
          if String.contains line ':' then
            let parts = String.split_on_char ':' line in
            match parts with
            | key :: value_parts ->
              let key = String.trim key in
              let value = String.trim (String.concat ":" value_parts) in
              let value = String.trim (String.map (function '"' -> ' ' | c -> c) value) in
              let value = String.trim value in
              if key = field_name then Some value
              else extract_domain_field field_name rest
            | _ -> extract_domain_field field_name rest
          else extract_domain_field field_name rest
      in
      
      (* Extract boundaries *)
      let extract_boundaries lines =
        let rec find_boundaries_start = function
          | [] -> []
          | line :: rest ->
            if String.trim line = "boundaries:" then extract_boundary_list rest
            else find_boundaries_start rest
        and extract_boundary_list lines =
          let rec extract_one_boundary acc = function
            | [] -> List.rev acc
            | line :: rest ->
              if String.starts_with ~prefix:"- range:" line then
                (* Parse range: [0.0, 5.7] *)
                let range_part = String.sub line 9 (String.length line - 9) in
                let range_part = String.trim range_part in
                let range_part = String.map (function '[' | ']' -> ' ' | c -> c) range_part in
                let range_nums = String.split_on_char ',' range_part in
                let lower = Float.of_string (String.trim (List.hd range_nums)) in
                let upper = Float.of_string (String.trim (List.nth range_nums 1)) in
                
                (* Extract category and color from following lines *)
                let (category, color, remaining) = extract_boundary_fields rest in
                let boundary = { range = (lower, upper); category; color } in
                extract_one_boundary (boundary :: acc) remaining
              else extract_one_boundary acc rest
          in
          extract_one_boundary [] lines
        and extract_boundary_fields = function
          | line1 :: line2 :: rest when String.contains line1 ':' && String.contains line2 ':' ->
            let cat = extract_field_value line1 in
            let col = extract_field_value line2 in
            (cat, Some col, rest)
          | line1 :: rest when String.contains line1 ':' ->
            let cat = extract_field_value line1 in
            (cat, None, rest)
          | rest -> ("unknown", None, rest)
        and extract_field_value line =
          if String.contains line ':' then
            let parts = String.split_on_char ':' line in
            match parts with
            | _key :: value_parts ->
              let value = String.trim (String.concat ":" value_parts) in
              String.trim (String.map (function '"' -> ' ' | c -> c) value)
            | _ -> "unknown"
          else "unknown"
        in
        find_boundaries_start lines
      in
      
      (* Extract global_bounds: [0.0, 20.0] *)
      let extract_global_bounds lines =
        match extract_domain_field "global_bounds" lines with
        | Some bounds_str ->
          let bounds_str = String.map (function '[' | ']' -> ' ' | c -> c) bounds_str in
          let bounds_parts = String.split_on_char ',' bounds_str in
          let lower = Float.of_string (String.trim (List.hd bounds_parts)) in
          let upper = Float.of_string (String.trim (List.nth bounds_parts 1)) in
          (lower, upper)
        | None -> (0.0, 100.0) (* default *)
      in
      
      (* Parse the content *)
      let name = Option.value (extract_domain_field "name" non_empty_lines) ~default:"Unknown Domain" in
      let unit = Option.value (extract_domain_field "unit" non_empty_lines) ~default:"units" in
      let description = extract_domain_field "description" non_empty_lines in
      let boundaries = extract_boundaries non_empty_lines in
      let global_bounds = extract_global_bounds non_empty_lines in
      
      (* Create raw_domain *)
      let raw_domain = {
        name; unit; description; boundaries; global_bounds;
        monitoring = None; (* TODO: implement monitoring parsing *)
      } in
      
      Ok raw_domain
      
    with
    | exn -> Error ("YAML parsing exception: " ^ (Printexc.to_string exn))
  
  (* Main domain loading function *)
  let load_from_yaml yaml_path =
    try
      (* Check file exists *)
      if not (Sys.file_exists yaml_path) then
        Error (FileNotFound yaml_path)
      else
        (* Read file content using compatible approach *)
        let content = read_file yaml_path in
        (* Parse YAML to raw_domain *)
        match parse_yaml_content content yaml_path with
        | Ok raw_domain ->
          (* Convert raw_domain to domain *)
          (match raw_to_domain raw_domain with
           | Ok result -> Ok { result with source_file = yaml_path }
           | Error err -> Error err)
        | Error msg -> Error (ParseError (yaml_path, 0, msg))
    with
    | Sys_error msg -> Error (FileNotFound (yaml_path ^ ": " ^ msg))
    | exn -> Error (ValidationError (Printexc.to_string exn))
  
  (* Validation function for raw_domain *)
  let validate_raw_domain raw_domain =
    
    let errors = ref [] in

    (* Check each boundary range is valid *)
    List.iteri (fun i raw_boundary ->
      let (lower, upper) = raw_boundary.range in
      if lower >= upper then
        errors := ("Boundary " ^ (Int.to_string i) ^ ": range lower >= upper") :: !errors;
      if Float.is_nan lower || Float.is_nan upper then
        errors := ("Boundary " ^ (Int.to_string i) ^ ": invalid range values") :: !errors;
    ) raw_domain.boundaries;
    
    (* Check global bounds are valid *)
    let (global_lower, global_upper) = raw_domain.global_bounds in
    if Float.is_nan global_lower || Float.is_nan global_upper then
      errors := "Invalid global bounds" :: !errors;
    if global_lower >= global_upper then
      errors := "Global bounds: lower >= upper" :: !errors;
    
    match !errors with
    | [] -> `Valid
    | errs -> `Warning (String.concat "; " errs)
  
  (* Validation function for processed domain *)
  let validate_domain (domain : domain) =
    let errors = ref [] in
    
    (* Check boundaries are properly ordered and non-overlapping *)
    let sorted_boundaries = List.sort (fun a b -> Float.compare a.lower b.lower) domain.boundaries in
    List.iteri (fun i boundary ->
      if boundary.lower >= boundary.upper then
        errors := ("Boundary " ^ (Int.to_string i) ^ ": lower >= upper") :: !errors;
      if i > 0 then
        let prev = List.nth sorted_boundaries (i-1) in
        if prev.upper > boundary.lower then
          errors := ("Boundaries " ^ (Int.to_string (i-1)) ^ " and " ^ (Int.to_string i) ^ " overlap") :: !errors
    ) sorted_boundaries;
    
    (* Check global bounds encompass all boundaries *)
    let global_lower, global_upper = domain.global_bounds in
    List.iteri (fun i boundary ->
      if boundary.lower < global_lower || boundary.upper > global_upper then
        errors := ("Boundary " ^ (Int.to_string i) ^ " outside global bounds") :: !errors
    ) domain.boundaries;
    
    match !errors with
    | [] -> `Valid
    | errs -> `Warning (String.concat "; " errs)
    
  (* Main interface function *)

  (* Convert domain_error to string *)
  let error_to_string = function
    | FileNotFound msg -> "File not found: " ^ msg
    | ParseError (file, line, msg) -> Printf.sprintf "Parse error in %s line %d: %s" file line msg
    | ValidationError msg -> "Validation error: " ^ msg
    | ConversionError msg -> "Conversion error: " ^ msg

  let load_domain filename =
    try
      let content = read_file filename in
      match parse_yaml_content content filename with
      | Ok raw_domain ->
          (match validate_raw_domain raw_domain with
           | `Valid ->
               (match raw_to_domain raw_domain with
                | Ok result ->
                    (match validate_domain result.domain with
                     | `Valid -> Ok result.domain
                     | `Warning _msg -> Ok result.domain
                    )
                | Error msg -> Error (error_to_string msg)
               )
           | `Invalid msg -> Error ("Validation error: " ^ msg)
           | `Warning msg -> Error ("Validation warning: " ^ msg)
          )
      | Error msg -> Error ("Parse error: " ^ msg)
    with
    | Sys_error msg -> Error ("File error: " ^ msg)
    | exn -> Error ("Unexpected error: " ^ (Printexc.to_string exn))


  (* Main interface function *)

  (* Convert domain_error to string *)
  let error_to_string = function
    | FileNotFound msg -> "File not found: " ^ msg
    | ParseError (file, line, msg) -> Printf.sprintf "Parse error in %s line %d: %s" file line msg
    | ValidationError msg -> "Validation error: " ^ msg
    | ConversionError msg -> "Conversion error: " ^ msg

end
