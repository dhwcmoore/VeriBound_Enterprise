(* Alcotest-based classification tests for VeriBound *)

let tests = [
  ("pharma_dose_safety.yaml", "1.5", "Therapeutic_Safe");
  ("pharma_dose_safety.yaml", "3.5", "Unknown");
  ("aqi.yaml", "50", "Moderate");
  ("aqi.yaml", "100", "Unhealthy for Sensitive Groups");
  ("aqi.yaml", "150", "Unhealthy");
  ("aqi.yaml", "250", "Very Unhealthy");
  ("basel_iii.yaml", "2.0", "Insolvent_Regulatory_Breach");
  ("nuclear_reactor.yaml", "335", "CRITICAL_SCRAM_IMMEDIATE");
  ("diabetes.yaml", "5.0", "Normal");
  ("diabetes.yaml", "6.0", "Prediabetes");
  ("diabetes.yaml", "-1", "Unknown");
  ("diabetes.yaml", "20.0", "Unknown");
  ("clinical_trial_safety.yaml", "0.01", "No_Adverse_Events_CONTINUE");
  ("medical_device_performance.yaml", "100.0", "Within_Specification_COMPLIANT");
  ("medical_device_performance.yaml", "0.0", "Out_of_Specification_FAIL");
  ("blood_pressure.yaml", "120", "Elevated");
]

let run_case (file, value, expected) () =
  let path = Filename.concat "data" file in
  match Boundary_classifier.BoundaryClassifier.classify_from_yaml path value with
  | Ok res -> Alcotest.(check string) (file ^ " " ^ value) expected res.category
  | Error _msg -> Alcotest.(check string) (file ^ " " ^ value) expected "Parse_Error"

let () =
  let test_cases = List.map (fun (f,v,e) -> (f ^ " " ^ v, `Quick, run_case (f,v,e))) tests in
  Alcotest.run "veribound_classification" [ ("classification", test_cases) ]
