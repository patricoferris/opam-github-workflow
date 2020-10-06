open Types
module Types = Types
module Events = Events
module Pp = Pp

module Yaml_util = struct
  let string s = `String s

  let float f = `Float f

  let int i = `Float (float_of_int i)

  let bool b = `Bool b

  let list : 'a. ('a -> Yaml.value) -> 'a list -> Yaml.value =
   fun f lst -> `A (List.map f lst)

  let simple_kv s : Yaml.value = `O s
end

(* Run *)
let run = { run_shell = ""; run_workdir = "" }

let with_run_shell s r = { r with run_shell = s }

let with_run_workdir s r = { r with run_workdir = s }

(* Container *)

let container =
  {
    image = None;
    credentials = None;
    container_env = None;
    ports = None;
    volumes = None;
  }

let with_image v c = { c with image = Some v }

let with_credentials v c = { c with credentials = Some v }

let with_container_env v c = { c with container_env = Some v }

let with_ports v c = { c with ports = Some v }

let with_volumes v c = { c with volumes = Some v }

(* Steps *)

let step : step =
  {
    step_name = None;
    uses = None;
    step_env = None;
    step_run = None;
    step_workdir = None;
    step_shell = None;
    with_ = None;
    step_if = None;
    continue_on_err = None;
    container = None;
    services = None;
  }

let with_step_name v s = { s with step_name = Some v }

let with_uses v s = { s with uses = Some v }

let with_step_env v s = { s with step_env = Some v }

let with_step_workdir v s = { s with step_workdir = Some v }

let with_step_shell v s = { s with step_shell = Some v }

let with_with v s = { s with with_ = Some v }

let with_step_if v s = { s with step_if = Some v }

let with_continue_on_err v s = { s with continue_on_err = Some v }

let with_container v s = { s with container = Some v }

let with_services v s = { s with services = Some v }

let with_step_run v s = { s with step_run = Some v }

(* Strategy *)

let strategy : strategy =
  { matrix = None; fail_fast = None; max_parallel = None }

let with_matrix v s = { s with matrix = Some v }

let with_fail_fast v s = { s with fail_fast = Some v }

let with_max_parallel v s = { s with max_parallel = Some v }

(* Job *)

let job runs_on : job =
  {
    job_name = None;
    needs = None;
    runs_on;
    outputs = None;
    job_env = None;
    job_defaults = None;
    job_if = None;
    steps = [];
    timeout = None;
    strategy = None;
  }

let with_job_name v j = { j with job_name = Some v }

let with_strategy v j = { j with strategy = Some v }

let with_runs_on v j = { j with runs_on = v }

let with_outputs v j = { j with outputs = Some v }

let with_job_env v j = { j with job_env = Some v }

let with_job_defaults v j = { j with job_defaults = Some v }

let with_job_if v j = { j with job_if = Some v }

let with_steps v j = { j with steps = v }

let with_timeout v j = { j with timeout = Some v }

let with_needs v j = { j with needs = Some v }

let default_event = List [ "push" ]

let simple_event s = List s

let complex_event e = Complex e

(* Workflow *)

let t : 'a. 'a -> 'a t =
 fun jobs ->
  { name = None; on = default_event; env = None; defaults = None; jobs }

let with_name v t = { t with name = Some v }

let with_on v t = { t with on = v }

let with_env v t = { t with env = Some v }

let with_defaults v t = { t with defaults = Some v }

let with_jobs v t = { t with jobs = v }

let expr s = "${{ " ^ s ^ " }}"
