open Types
module Types = Types
module Events = Events

let string s = `String s

let list : 'a. ('a -> Yaml.value) -> 'a list -> Yaml.value =
 fun f lst -> `A (List.map f lst)

let simple_kv s : Yaml.value = `O s

let default_event = List [ "push" ]

let simple_event s = List s

let complex_event e = Complex e

let t : 'a. 'a -> 'a t =
 fun jobs ->
  { name = None; on = default_event; env = None; defaults = None; jobs }

let expr s = "${{ " ^ s ^ " }}"

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

let strategy : strategy =
  { matrix = None; fail_fast = None; max_parallel = None }

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

module Pp = Pp
