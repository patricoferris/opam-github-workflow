val get_opam_files : unit -> (OpamTypes.name * OpamFile.OPAM.t) list

val pin_packages : string list -> string

val reset_opam_repo : unit -> string Lwt.t
