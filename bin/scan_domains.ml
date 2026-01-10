(* Simple domain scanner that tries to load each YAML in `data/` and reports parse/load status *)

let () =
  let data_dir = "data" in
  let files = Sys.readdir data_dir |> Array.to_list |> List.filter (fun f -> Filename.check_suffix f ".yaml") in
  List.iter (fun file ->
    let path = Filename.concat data_dir file in
    match Domain_manager.DomainManager.load_domain path with
    | Ok dom ->
        Printf.printf "✓ LOADED: %s -> %d boundaries (unit: %s)\n" file (List.length dom.boundaries) dom.unit
    | Error msg ->
        Printf.printf "✗ FAILED: %s -> %s\n" file msg
  ) files
