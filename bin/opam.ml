open Lwt.Infix

let opam_repo = "https://github.com/ocaml/opam-repository"

let get_opam_files () =
  let rec remove_and_read acc = function
    | [] -> List.rev acc
    | (Some f, g, _) :: xs ->
        remove_and_read ((f, OpamFile.OPAM.read g) :: acc) xs
    | (None, _, _) :: xs -> remove_and_read acc xs
  in
  OpamPinned.files_in_source (OpamFilename.Dir.of_string ".")
  |> remove_and_read []

let pin_packages ps =
  let rec aux acc = function
    | [] -> List.rev acc
    | [ x ] -> aux (("opam pin add -yn " ^ x ^ " './'") :: acc) []
    | x :: xs -> aux (("opam pin add -yn " ^ x ^ " './' &&") :: acc) xs
  in
  String.concat " " (aux [] ps)

let opam_hash () =
  Lwt_io.with_temp_dir (fun cwd ->
      Os.exec ~cwd [ "git"; "clone"; "--depth"; "1"; opam_repo ] >>= fun () ->
      Os.read
        ~cwd:(Filename.concat cwd "opam-repository")
        [ "git"; "rev-parse"; "HEAD" ])
  >|= String.trim

let reset_opam_repo () =
  opam_hash () >|= fun hash ->
  Fmt.str
    "cd ~/opam-repository && (git cat-file -e %s || git fetch origin master) \
     && git reset -q --hard %s && git log --no-decorate -n1 --oneline && opam \
     update -u"
    hash hash
