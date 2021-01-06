open Cmdliner

let cmds = [ Test.cmd; Changes.cmd; Ci.cmd ]

let doc = "Opam Github Workflows"

let main =
  ( Term.ret @@ Term.pure (`Help (`Pager, None)),
    Term.info "opam-github-workflow" ~doc )

let main () = Term.(exit @@ eval_choice main cmds)

let () = main ()
