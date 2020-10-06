type kv = Yaml.value [@@deriving yaml]

type env = kv

type output = kv

type run = {
  run_shell : string; [@key "shell"]
  run_workdir : string; [@key "working-directory"]
}

type defaults = { default_run : run [@key "run"] }

type container = {
  image : string option;
  credentials : kv option;
  container_env : env option; [@key "env"]
  ports : int list option;
  volumes : string list option;
}

type services = container

type with_ = kv

type step = {
  step_name : string option; [@key "name"]
  uses : string option;
  step_env : env option; [@key "env"]
  step_workdir : string option; [@key "working-directory"]
  step_shell : string option; [@key "shell"]
  with_ : with_ option; [@key "with"]
  step_if : string option; [@key "if"]
  continue_on_err : bool option; [@key "continue-on-error"]
  container : container option;
  services : services option;
  step_run : string option; [@key "run"]
}

type job = {
  job_name : string option; [@key "name"]
  strategy : kv option;
  runs_on : string; [@key "runs-on"]
  outputs : output option;
  job_env : env option; [@key "env"]
  job_defaults : defaults option; [@key "defaults"]
  job_if : string option; [@key "if"]
  steps : step list;
  timeout : int option; [@key "timeout-minutes"]
  needs : string option;
}
[@@deriving yaml]

type on = List of string list | Complex of Events.t

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
