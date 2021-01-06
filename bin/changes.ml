open Workflow
open Cmdliner

type changes = { changes : Types.job }

let changes_to_yaml t : Yaml.value =
  `O [ ("changes", Types.job_to_yaml t.changes) ]

let changes changes_file =
  let open Yaml_util in
  let open Events in
  let name = "Checking changelog" in
  let checkout = step |> with_uses Conf.checkout in
  let on =
    complex_event
      (event
      |> with_pull_request
           (push_or_pr
           |> with_types
                [ "opened"; "synchronize"; "reopened"; "labeled"; "unlabeled" ]
           ))
  in
  let steps =
    [
      checkout;
      step
      |> with_step_name "Diffing"
      |> with_step_if
           (expr
              "!contains(github.event.pull_request.labels.*.name, \
               'no-changelog-needed')")
      |> with_step_env
           (simple_kv
              [
                ("BASE_REF", string (expr "github.event.pull_request.base.ref"));
              ])
      |> with_step_run
           ("git diff --exit-code origin/$BASE_REF -- " ^ changes_file);
    ]
  in
  let diff_job = { changes = job "ubuntu-latest" |> with_steps steps } in
  let w : changes Types.t = t diff_job |> with_name name |> with_on on in
  Pp.workflow ~drop_null:true changes_to_yaml Format.std_formatter w

let run fname = changes fname

let fname =
  let docv = "FNAME" in
  let doc = "The name of the file containing your changelog" in
  Arg.(value & opt string "CHANGES.md" & info ~doc ~docv [ "fname"; "f" ])

let info =
  let doc = "Output a git based check for changelog updates" in
  Term.info ~doc "changes"

let cmd = (Term.(const run $ fname), info)
