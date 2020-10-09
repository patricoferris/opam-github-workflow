type kv = Yaml.value [@@deriving yaml]

type env = kv [@@deriving yaml]

type output = kv [@@deriving yaml]

type run = {
  run_shell : string; [@key "shell"]
  run_workdir : string; [@key "working-directory"]
}
[@@deriving yaml]

type defaults = { default_run : run [@key "run"] } [@@deriving yaml]

type container = {
  image : string option;
  credentials : kv option;
  container_env : env option; [@key "env"]
  ports : int list option;
  volumes : string list option;
  options : string option;
}
[@@deriving yaml]

type services = container [@@deriving yaml]

type with_ = kv [@@deriving yaml]

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
[@@deriving yaml]

type strategy = {
  matrix : kv option;
  fail_fast : bool option; [@key "fail-fast"]
  max_parallel : int option; [@key "max-parallel"]
}
[@@deriving yaml]

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

type on = List of string list | Complex of Events.t

let on_to_yaml = function
  | List s -> `A (List.map (fun s -> `String s) s)
  | Complex events -> Events.to_yaml events

let on_of_yaml : Yaml.value -> on Yaml.res = function
  | `A lst -> Ok (List (List.map (function `String s -> s | _ -> "") lst))
  | t -> (
      match Events.of_yaml t with Ok e -> Ok (Complex e) | Error e -> Error e)

type 'a t = {
  name : string option;
  on : on;
  env : env option;
  defaults : defaults option;
  jobs : 'a;
}
[@@deriving yaml]
