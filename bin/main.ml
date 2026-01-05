open Cmdliner

(* --- CORRECTED MODULE ALIASES --- *)
(* Pointing to the inner structs inside lib/runtime *)
module BC = Boundary_classifier.BoundaryClassifier
module DM = Domain_manager.DomainManager

(* --- UTILITY: Smart Path Resolution --- *)
let resolve_domain_path input =
  if Sys.file_exists input then input
  else
    let default_dir = "data" in
    let with_ext = if Filename.check_suffix input ".yaml" then input else input ^ ".yaml" in
    let candidate = Filename.concat default_dir with_ext in
    if Sys.file_exists candidate then candidate
    else
      failwith (Printf.sprintf "Could not find domain file: %s" input)

(* --- COMMAND: Inspect --- *)
let inspect_cmd =
  let domain_arg = Arg.(required & pos 0 (some string) None & info [] ~docv:"DOMAIN" ~doc:"Domain name") in
  let value_arg = Arg.(required & pos 1 (some float) None & info [] ~docv:"VALUE" ~doc:"Value to verify") in
  let show_process_flag = Arg.(value & flag & info ["show-process"] ~doc:"Show audit trail") in
  
  let inspect_fn domain value show_process =
    try
      let domain_file = resolve_domain_path domain in
      let value_str = Float.to_string value in
      Printf.printf "🔍 Verifying Value: %.4f against %s...\n" value (Filename.basename domain_file);
      
      match BC.classify_from_yaml domain_file value_str with
      | Ok result ->
          Printf.printf "✅ RESULT: %s\n" result.category;
          if show_process then Printf.printf "   (Kernel Decision Engine: %s)\n" result.engine
      | Error msg -> 
          Printf.eprintf "⛔ REFUSAL: %s\n" msg;
          exit 1
    with Failure msg -> Printf.eprintf "❌ ERROR: %s\n" msg; exit 1
  in
  Cmd.v (Cmd.info "inspect" ~doc:"Inspect a value") Term.(const inspect_fn $ domain_arg $ value_arg $ show_process_flag)

(* --- ENTRY POINT --- *)
let main_cmd = 
  let info = Cmd.info "veribound" ~version:"2.1-Enterprise" in
  Cmd.group info [inspect_cmd]

let () = exit (Cmd.eval main_cmd)
