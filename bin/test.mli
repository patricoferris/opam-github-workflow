open Workflow

type test = { test : Types.job } [@@deriving yaml]

val cmd : unit Cmdliner.Term.t * Cmdliner.Term.info

val test : ?oses:string list -> int -> string * test
(** [test oses n] creates a standard testing workflow using Github runners for
    the [n] most recent versions of OCaml on [oses] platforms *)
