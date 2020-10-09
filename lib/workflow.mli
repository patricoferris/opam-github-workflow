open Types

module Types = Types
(** Describes the workflow syntax as OCaml types *)

module Events = Events
(** Describes the triggers for workflows *)

module Pp = Pp
(** Pretty printers *)

(** Yaml combinators *)
module Yaml_util : sig
  val string : string -> Yaml.value
  (** Yaml string constructor *)

  val float : float -> Yaml.value
  (** Yaml float constructor *)

  val int : int -> Yaml.value
  (** Yaml int constructor *)

  val bool : bool -> Yaml.value
  (** Yaml bool constructor *)

  val list : ('a -> Yaml.value) -> 'a list -> Yaml.value
  (** Yaml list constructor *)

  val simple_kv : (string * Yaml.value) list -> Yaml.value
  (** Yaml key-value constructor *)
end

(** {2 Default values and combinators} *)

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

(** {3 Run}*)

val run : run
(** Default run shell (bash) and working directory (scripts) *)

val with_run_shell : string -> run -> run

val with_run_workdir : string -> run -> run

val default : defaults

val with_default_run : run -> defaults

(** {3 Containers & Services}*)

val container : container
(** Default empty container *)

val with_image : string -> container -> container

val with_credentials : kv -> container -> container

val with_container_env : kv -> container -> container

val with_ports : int list -> container -> container

val with_volumes : string list -> container -> container

val with_options : string -> container -> container

(** {3 Steps}*)

val step : step
(** Default empty step *)

val with_step_name : string -> step -> step

val with_uses : string -> step -> step

val with_step_env : env -> step -> step

val with_step_workdir : string -> step -> step

val with_step_shell : string -> step -> step

val with_with : with_ -> step -> step

val with_step_if : string -> step -> step

val with_continue_on_err : bool -> step -> step

val with_step_run : string -> step -> step

(** {3 Strategy}*)

val strategy : strategy
(** Default empty strategy *)

val with_matrix : kv -> strategy -> strategy

val with_fail_fast : bool -> strategy -> strategy

val with_max_parallel : int -> strategy -> strategy

(** {3 Job} *)

val job : string -> job
(** [job runs_on] constructs a new job to run on [runs_on] -- note to get a list
    of items you should use the matrix approach with [expr] *)

val expr : string -> string
(** [expr s] constructs a Github Yaml expressions i.e. ["${{ s }}"] *)

val with_job_name : string -> job -> job

val with_strategy : strategy -> job -> job

val with_runs_on : string -> job -> job

val with_outputs : output -> job -> job

val with_job_env : env -> job -> job

val with_job_defaults : defaults -> job -> job

val with_job_if : string -> job -> job

val with_steps : step list -> job -> job

val with_timeout : int -> job -> job

val with_needs : string -> job -> job

val with_container : container -> job -> job

val with_services : services -> job -> job

(** {3 Workflow} *)

val t : 'a -> 'a t
(** [t a] makes a new workflow *)

val with_name : string -> 'a t -> 'a t

val with_on : on -> 'a t -> 'a t

val with_env : env -> 'a t -> 'a t

val with_defaults : defaults -> 'a t -> 'a t

val with_jobs : 'a -> 'a t -> 'a t
