open Workflow
open Cmdliner

exception NoOpamFiles

type test = { test : Types.job } [@@deriving yaml]

let join s =
  let rec aux acc = function
    | [] -> String.concat "" (List.rev acc)
    | [ x; y ] -> aux ((x ^ " and " ^ y) :: acc) []
    | [ x ] -> x
    | x :: xs -> aux ((x ^ ", ") :: acc) xs
  in
  aux [] s

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

let test ?(oses = Conf.oses) n =
  let open Yaml_util in
  let opam = Opam.get_opam_files () in
  if List.length opam = 0 then raise NoOpamFiles;
  let packages = List.map (fun f -> OpamPackage.Name.to_string (fst f)) opam in
  let name = "Tests for " ^ join packages in
  let packages = List.map (fun f -> f ^ ".dev") packages in
  let joined_packages = String.concat " " packages in
  let pinning = Opam.pin_packages packages in
  let matrix =
    simple_kv
      [
        ("operating-system", list string oses);
        ("ocaml-version", list string @@ Conf.ocaml_versions n);
      ]
  in
  let checkout = { step with uses = Some Conf.checkout } in
  let setup =
    step
    |> with_uses Conf.setup_ocaml
    |> with_with
         (simple_kv [ ("ocaml-version", string (expr "matrix.ocaml-version")) ])
  in
  let build = dune_build_install_test in
  let steps =
    [
      checkout;
      setup;
      step |> with_step_name "Pinning Package" |> with_step_run pinning;
      step
      |> with_step_name "Packages"
      |> with_step_run ("opam depext -yt " ^ joined_packages);
      step
      |> with_step_name "Dependencies"
      |> with_step_run "opam install -t -y . --deps-only";
    ]
    @ build
  in
  ( name,
    {
      test =
        job (expr "matrix.operating-system")
        |> with_strategy (strategy |> with_matrix matrix)
        |> with_steps steps;
    } )

let recent =
  let docv = "RECENT" in
  let doc =
    "The n most recent OCaml versions to use based on OCaml-version library"
  in
  Arg.(value & opt int 3 & info ~doc ~docv [ "recent"; "r" ])

let run recent =
  try
    let name, test_job = test recent in
    let on = simple_event [ "push"; "pull_request" ] in
    let w : test Types.t = t test_job |> with_name name |> with_on on in
    Pp.workflow ~drop_null:true test_to_yaml Format.std_formatter w
  with NoOpamFiles ->
    Format.pp_print_string Format.std_formatter
      "No Opam files found in the current directory"

let info =
  let doc = "Output a standard opam and dune testing workflow" in
  Term.info ~doc "test"

let cmd = (Term.(const run $ recent), info)
