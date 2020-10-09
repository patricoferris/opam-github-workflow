type kv = Yaml.value [@@deriving yaml]
(** A Yaml key-value store -- this is exposed in order to be flexible with
    things like environment variable names which cannot be dynamically decided
    by the user if bound to a record type *)

type env = kv
(** The type of environment variables *)

type output = kv
(** The type of outputs *)

type run = {
  run_shell : string; [@key "shell"]
  run_workdir : string; [@key "working-directory"]
}
(** The type of run statements *)

type defaults = { default_run : run [@key "run"] }
(** The type of defaults *)

type container = {
  image : string option;
  credentials : kv option;
  container_env : env option; [@key "env"]
  ports : int list option;
  volumes : string list option;
  options : string option;
}
(** The type of docker containers *)

type services = container

type with_ = kv
(** The type of input variables for external actions *)

type step = {
  step_name : string option; [@key "name"]
  uses : string option;
  step_run : string option; [@key "run"]
  step_env : env option; [@key "env"]
  step_workdir : string option; [@key "working-directory"]
  step_shell : string option; [@key "shell"]
  with_ : with_ option; [@key "with"]
  step_if : string option; [@key "if"]
  continue_on_err : bool option; [@key "continue-on-error"]
}
(** The type of steps in a job *)

type strategy = {
  matrix : kv option;
  fail_fast : bool option; [@key "fail-fast"]
  max_parallel : int option; [@key "max-parallel"]
}
(** The type of strategies to define things like matrices *)

type job = {
  job_name : string option; [@key "name"]
  strategy : strategy option;
  runs_on : string; [@key "runs-on"]
  container : container option;
  services : services option;
  outputs : output option;
  job_env : env option; [@key "env"]
  job_defaults : defaults option; [@key "defaults"]
  job_if : string option; [@key "if"]
  steps : step list;
  timeout : int option; [@key "timeout-minutes"]
  needs : string option;
}
[@@deriving yaml]
(** The type of jobs *)

type on =
  | List of string list
  | Complex of Events.t  (** The type of triggers for the workflow *)

type 'a t = {
  name : string option;
  on : on;
  env : env option;
  defaults : defaults option;
  jobs : 'a;
}
[@@deriving yaml]
(** The type of Github Workflows -- the parameter ['a] allows you supply names
    to your jobs *)
