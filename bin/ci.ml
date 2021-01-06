open Lwt.Infix
open Workflow
open Yaml_util

(* General idea from the ocurrent docker plugin https://github.com/ocurrent/ocurrent *)
(* open Lwt.Infix *)

module Dd = Dockerfile_distro
module Ov = Ocaml_version

type job = { job : Types.job }

module Docker = struct
  let mk_docker_tag distro ocv =
    Fmt.str "ocaml/opam:%s-ocaml-%s" (Dd.tag_of_distro distro)
      (Ov.to_string ocv)

  let mk_docker_sha = Fmt.str "ocaml/opam@%s"

  let manifest tag = [ "docker"; "manifest"; "inspect"; "--"; tag ]

  let extract_digest arch s =
    let open Yojson.Basic.Util in
    let json = Yojson.Basic.from_string s in
    member "manifests" json
    |> to_list
    |> List.find (fun f ->
           member "platform" f
           |> member "architecture"
           |> to_string
           = Ov.string_of_arch arch)
    |> member "digest"

  let peek ~arch ~tag = Os.read @@ manifest tag >|= extract_digest arch
end

module Platform = struct
  let default_platforms =
    [
      `Debian `V10;
      `Alpine `V3_12;
      `Ubuntu `V20_04;
      `Ubuntu `V18_04;
      `OpenSUSE `V15_2;
      `CentOS `V8;
      `Fedora `V32;
    ]
end

let container image =
  container
  |> with_image image
  |> with_options "--user 1000"
  |> with_container_env (simple_kv [ ("HOME", `String "/home/opam") ])

let workflow ~opam_hash ~from =
  let open Yaml_util in
  let opam = Opam.get_opam_files () in
  if List.length opam = 0 then failwith "No opam files found";
  let packages = List.map (fun f -> OpamPackage.Name.to_string (fst f)) opam in
  let packages = List.map (fun f -> f ^ ".dev") packages in
  let joined_packages = String.concat " " packages in
  let pinning = Opam.pin_packages packages in
  let package = "/home/opam/package" in
  let run_in_package = step |> with_step_workdir package in
  let steps =
    [
      step |> with_step_run opam_hash;
      step |> with_step_run ("mkdir -p " ^ package);
      run_in_package
      |> with_step_name "Cloning"
      |> with_step_run
           "git clone https://github.com/$GITHUB_REPOSITORY . && git checkout \
            $GITHUB_SHA";
      run_in_package
      |> with_step_name "Pinning Packages"
      |> with_step_run pinning;
      run_in_package
      |> with_step_name "Installing external dependencies"
      |> with_step_run ("opam depext -yt " ^ joined_packages);
      run_in_package
      |> with_step_name "Installing dependencies"
      |> with_step_run "opam install -t -y . --deps-only";
      run_in_package
      |> with_step_name "Building, installing & testing"
      |> with_step_run "opam exec -- dune build @install @runtest";
    ]
  in
  job "ubuntu-latest"
  |> with_steps steps
  |> with_container (container from)
  |> with_job_env (simple_kv [ ("HOME", `String "/home/opam") ])
  |> with_job_defaults (with_default_run (run |> with_run_workdir "/home/opam"))
  |> fun job -> { job }

let macos_and_win =
  Test.test ~oses:[ "macos-latest"; "windows-latest" ] 1 |> snd |> fun t ->
  ("macos_and_windows", Types.job_to_yaml t.test)

let run () =
  let yml_name s =
    let to_underscores c s = String.(concat "_" (split_on_char c s)) in
    let remove c s = String.(concat "" (split_on_char c s)) in
    to_underscores '.' s
    |> to_underscores ' '
    |> remove '('
    |> remove ')'
    |> String.lowercase_ascii
  in
  let ocv = Ov.(Releases.latest |> with_just_major_and_minor) in
  let get_string = function
    | `String s -> s
    | _ -> failwith "Expected a string"
  in
  let hash = Opam.reset_opam_repo () in
  let tags =
    Lwt_list.map_p
      (fun d ->
        Docker.peek ~arch:`X86_64 ~tag:(Docker.mk_docker_tag d ocv)
        >|= fun sha -> (d, Docker.mk_docker_sha @@ get_string sha))
      Platform.default_platforms
  in
  Lwt_main.run
    ( hash >>= fun hash ->
      tags >|= fun tags -> (hash, tags) )
  |> fun (opam_hash, tags) ->
  List.map
    (fun (d, from) ->
      ( Dd.human_readable_string_of_distro d |> yml_name,
        workflow ~opam_hash ~from ))
    tags
  |> fun lst ->
  `O
    (macos_and_win
    :: List.map (fun (d, job) -> (d, Types.job_to_yaml job.job)) lst)
  |> t
  |> with_name "OCaml-CI"
  |> with_on (simple_event [ "push"; "pull_request" ])
  |> Pp.workflow ~drop_null:true Fun.id Fmt.stdout

(* Command line values *)
open Cmdliner

let info =
  let doc =
    Fmt.(
      str
        "Generate a full OCaml-CI like workflow file for the latest version of \
         OCaml. This includes %a, Macos and Windows"
        (list ~sep:comma string)
        (List.map Dd.human_readable_string_of_distro Platform.default_platforms))
  in
  Term.info ~doc "ci"

let cmd = (Term.(const run $ const ()), info)
