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

let dune_build_install_test =
  [
    step |> with_step_name "Building" |> with_step_run "opam exec -- dune build";
    step
    |> with_step_name "Installing"
    |> with_step_run "opam exec -- dune install";
    step
    |> with_step_name "Testing"
    |> with_step_run "opam exec -- dune runtest";
  ]

let opam_install_test =
  [
    step
    |> with_step_name "Opam install and test"
    |> with_step_run "opam install --with-test .";
  ]

let test dune () =
  let open Yaml_util in
  let opam = get_opam_files () in
  if List.length opam = 0 then raise NoOpamFiles;
  let packages = List.map (fun f -> OpamPackage.Name.to_string (fst f)) opam in
  let name = "Tests for " ^ join packages in
  let packages = String.concat " " packages in
  let matrix =
    simple_kv
      [
        ("operating-system", list string Conf.oses);
        ("ocaml-version", list string Conf.ocaml_versions);
      ]
  in
  let checkout = { step with uses = Some Conf.checkout } in
  let setup =
    step
    |> with_uses Conf.setup_ocaml
    |> with_with
         (simple_kv [ ("ocaml-version", string (expr "matrix.ocaml-version")) ])
  in
  let build = if dune then dune_build_install_test else opam_install_test in
  let steps =
    [
      checkout;
      setup;
      step
      |> with_step_name "Pinning Package"
      |> with_step_run "opam pin add -n -y .";
      step
      |> with_step_name "Packages"
      |> with_step_run ("opam depext -yt " ^ packages);
      step
      |> with_step_name "Dependencies"
      |> with_step_run "opam install -t -y . --deps-only";
    ]
    @ build
  in
  let test_job =
    {
      test =
        job (expr "matrix.operating-system")
        |> with_strategy (strategy |> with_matrix matrix)
        |> with_steps steps;
    }
  in
  let on = simple_event [ "push"; "pull_request" ] in
  let w : test Types.t = t test_job |> with_name name |> with_on on in
  Pp.workflow ~drop_null:true test_to_yaml Format.str_formatter w;
  Format.flush_str_formatter ()

let run fname stdout dune =
  let pp_string s = Format.(pp_print_string std_formatter s) in
  let open Bos.OS in
  try
    let output = test dune () in
    let res =
      if stdout then (
        pp_string output;
        Ok false)
      else
        Dir.create (Fpath.v Conf.output_dir) >>= fun _ ->
        let output_path = Fpath.((v Conf.output_dir / fname) + "yml") in
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
            ^ Fpath.(to_string (v Conf.output_dir)));
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

let dune =
  let docv = "DUNE" in
  let doc =
    "With this flag set, the workflow will run dune build, install and runtest \
     after installing dependencies. The default behaviour is to run `opam \
     install --with-test .'"
  in
  Arg.(value & flag & info ~doc ~docv [ "d"; "dune" ])

let info =
  let doc = "Output a standard opam and dune testing workflow" in
  Term.info ~doc "test"

let cmd = (Term.(const run $ fname $ stdout $ dune), info)
