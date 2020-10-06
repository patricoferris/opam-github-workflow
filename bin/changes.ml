open Workflow
open Cmdliner

type changes = { changes : Types.job }

let changes_to_yaml t : Yaml.value =
  `O [ ("changes", Types.job_to_yaml t.changes) ]

let changes changes_file =
  let name = Some "Checking changelog" in
  let checkout = { step with uses = Some Config.checkout } in
  let on =
    complex_event
      {
        Events.event with
        pull_request =
          Some
            {
              Events.push_or_pr with
              types =
                Some
                  [
                    "opened"; "synchronize"; "reopened"; "labeled"; "unlabeled";
                  ];
            };
      }
  in
  let steps =
    [
      checkout;
      {
        step with
        step_name = Some "Diffing";
        step_if =
          Some
            (expr
               "!contains(github.event.pull_request.labels.*.name, \
                'no-changelog-needed')");
        step_env =
          Some
            (simple_kv
               [
                 ("BASE_REF", string (expr "github.event.pull_request.base.ref"));
               ]);
        step_run =
          Some ("git diff --exit-code origin/$BASE_REF -- " ^ changes_file);
      };
    ]
  in
  let diff_job = { changes = { (job "ubuntu-latest") with steps } } in
  let w : changes Types.t = { (t diff_job) with name; on } in
  Pp.workflow ~drop_null:true changes_to_yaml Format.std_formatter w

let run fname =
  changes fname;
  0

let fname =
  let docv = "FNAME" in
  let doc = "The name of the file containing your changelog" in
  Arg.(value & opt string "CHANGES.md" & info ~doc ~docv [ "fname"; "f" ])

let info =
  let doc = "Output a git based check for changelog updates" in
  Term.info ~doc "changes"

let cmd = (Term.(const run $ fname), info)
