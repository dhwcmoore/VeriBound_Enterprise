(* Clean interface between mathematical extraction and classification runtime *)
module BoundaryClassifier = struct
  
  (* Use the correct full module paths *)
  module RC = Runtime_classifier.Classifier.RuntimeClassifier
  module DM = Domain_manager.DomainManager
  
  (* Use RuntimeClassifier types *)
  type domain = RC.simple_domain
  type classification_result = RC.classification
  
  (* Conversion function: DomainManager.domain -> RuntimeClassifier.simple_domain *)
  let convert_domain_to_simple (dm_domain : DM.domain) : RC.simple_domain =
    {
      name = dm_domain.name;
      boundaries = List.map (fun (boundary : DM.boundary) ->
        (boundary.lower, boundary.upper, boundary.category)
      ) dm_domain.boundaries;
    }
  
  (* Main classification function *)
  let classify_value domain input_str =
    RC.classify_simple domain input_str
    
  (* Load domain from YAML file *)
  let load_domain yaml_path =
    (* Use DomainManager to load domain *)
    match DM.load_domain yaml_path with
    | Ok dm_domain -> 
        (* Convert DomainManager.domain to RuntimeClassifier.simple_domain *)
        let simple_domain = convert_domain_to_simple dm_domain in
        Ok simple_domain
    | Error err -> Error err
        
  (* Convenience function: load and classify in one step *)
  let classify_from_yaml yaml_path input_value =
    match load_domain yaml_path with
    | Ok domain -> Ok (classify_value domain input_value)
    | Error msg -> Error msg
    
end
