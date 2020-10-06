open Types

module Types = Types
(** Describes the workflow syntax as OCaml types *)

module Events = Events
(** Describes the triggers for workflows *)

val string : string -> Yaml.value
(** Yaml string constructor *)

val list : ('a -> Yaml.value) -> 'a list -> Yaml.value
(** Yaml list constructor *)

val simple_kv : (string * Yaml.value) list -> Yaml.value
(** Yaml `O constructor *)

(** {2 Default values} *)

(** The following functions give default values, in essense this means lists are
    set to empty lists and optional values are set to [None]. Where this isn't
    possible the function will have arguments to provide the details to
    construct the values. *)

val simple_event : string list -> on
(** Construct simple triggers for the workflow as a list such as
    [\[push, pull_request\]] *)

val complex_event : Events.t -> on
(** Construct a complex trigger for workflows using
    {{:https://docs.github.com/en/free-pro-team/actions/reference/events-that-trigger-workflows}
    events} *)

val t : 'a -> 'a t
(** [t a] makes a new workflow *)

val expr : string -> string
(** [expr s] constructs a Github Yaml expressions i.e. ["${{ s }}"] *)

val strategy : strategy
(** An empty strategy *)

val job : string -> job
(** [job runs_on] constructs a new job to run on [runs_on] -- note to get a list
    of items you should use the matrix approach *)

val step : step
(** [step] constructs a new step that is completely empty *)

module Pp = Pp
