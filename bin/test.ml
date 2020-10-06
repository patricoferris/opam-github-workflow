open Workflow
open Cmdliner
open Rresult.R.Infix

exception NoOpamFiles

type test = { test : Types.job }

let test_to_yaml t : Yaml.value = `O [ ("test", Types.job_to_yaml t.test) ]

let join s =
  let rec aux acc = function
    | [] -> String.concat "" (List.rev acc)
    | [ x; y ] -> aux ((x ^ " and " ^ y) :: acc) []
    | [ x ] -> x
    | x :: xs -> aux ((x ^ ", ") :: acc) xs
  in
  aux [] s

let get_opam_files () =
  let rec remove_and_read acc = function
    | [] -> List.rev acc
    | (Some f, g) :: xs -> remove_and_read ((f, OpamFile.OPAM.read g) :: acc) xs
    | (None, _) :: xs -> remove_and_read acc xs
  in
  OpamPinned.files_in_source (OpamFilename.Dir.of_string ".")
  |> remove_and_read []

let test () =
  let opam = get_opam_files () in
  if List.length opam = 0 then raise NoOpamFiles;
  let packages = List.map (fun f -> OpamPackage.Name.to_string (fst f)) opam in
  let name = Some ("Tests for " ^ join packages) in
  let dev_packages =
    String.concat " " (List.map (fun p -> p ^ ".dev") packages)
  in
  let packages = String.concat " " packages in
  let strategy =
    Some
      (simple_kv
         [
           ("operating-system", list string Config.oses);
           ("ocaml-version", list string Config.ocaml_versions);
         ])
  in
  let checkout = { step with uses = Some Config.checkout } in
  let setup = { step with uses = Some Config.setup_ocaml } in
  let steps =
    [
      checkout;
      setup;
      {
        step with
        step_name = Some "Pinning Package";
        step_run = Some ("opam pin add " ^ dev_packages ^ " -n .");
      };
      {
        step with
        step_name = Some "Packages";
        step_run = Some ("opam depext -yt " ^ packages);
      };
      {
        step with
        step_name = Some "Dependencies";
        step_run = Some "opam install -t . --deps-only";
      };
      {
        step with
        step_name = Some "Building";
        step_run = Some "opam exec -- dune build";
      };
      {
        step with
        step_name = Some "Testing";
        step_run = Some "opam exec -- dune runtest";
      };
    ]
  in
  let test_job =
    { test = { (job (expr "matrix.operating-system")) with strategy; steps } }
  in
  let on = simple_event [ "push"; "pull_request" ] in
  let w : test Types.t = { (t test_job) with name; on } in
  Pp.workflow ~drop_null:true test_to_yaml Format.str_formatter w;
  Format.flush_str_formatter ()

let run fname stdout =
  let pp_string s = Format.(pp_print_string std_formatter s) in
  let open Bos.OS in
  try
    let output = test () in
    let res =
      if stdout then (
        pp_string output;
        Ok false)
      else
        Dir.create Config.output_dir >>= fun _ ->
        let output_path = Fpath.((Config.output_dir / fname) + "yml") in
        File.exists output_path >>= fun b ->
        if b then (
          pp_string "File already exists, doing nothing";
          Ok false)
        else
          match File.write output_path output with
          | Ok _ -> Ok true
          | Error (`Msg m) ->
              pp_string m;
              Ok false
    in
    match res with
    | Ok b ->
        if b then (
          pp_string
            ("Successfully created test workflow in "
            ^ Fpath.to_string Config.output_dir);
          0)
        else 0
    | Error (`Msg m) ->
        pp_string m;
        -1
  with NoOpamFiles ->
    Format.pp_print_string Format.std_formatter
      "No Opam files found in the current directory";
    -1

let fname =
  let docv = "FNAME" in
  let doc = "The name of the file the test workflow will go to e.g. `test' " in
  Arg.(value & opt string "test" & info ~doc ~docv [ "fname"; "f" ])

let stdout =
  let docv = "STDOUT" in
  let doc =
    "With this flag set, the workflow will go to standard out rather than \
     making the file"
  in
  Arg.(value & flag & info ~doc ~docv [ "s"; "stdout" ])

let info =
  let doc = "Output a standard opam and dune testing workflow" in
  Term.info ~doc "test"

let cmd = (Term.(const run $ fname $ stdout), info)
