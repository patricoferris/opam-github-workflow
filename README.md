opam-github-workflow
--------------------

🚧 WIP: Under Construction 🚧

An opam plugin and library for building Github Action workflows in OCaml. For the plugin to work your project must use **opam and dune**.

## Plugin Usage 

```
$ opam pin add --yes git+https://github.com/patricoferris/opam-github-workflow
$ cd <my-cool-project>
$ opam github-workflow test
```

## Library Usage 

```
$ opam pin add --yes git+https://github.com/patricoferris/opam-github-workflow
$ opam install github-workflow
```

The library follows the [workflow syntax](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) for Github Actions. Each key for the Yaml has a type such as `job` or `on` with each having a default that you can build on top of to produce new values. 

To do this nicely, each type comes with some functions prefixed with `with_` allowing you to write them in a combinator fashion. For example: 

```ocaml env=example
# #require "github-workflow"
# open Workflow
# let steps = [ 
  step
  |> with_step_name "Hello \o/"
  |> with_step_run "echo 'Hello World'"]
File "_none_", line 3, characters 27-29:
Warning 14: illegal backslash escape in string.
val steps : Types.step list =
  [{Workflow__.Types.step_name = Some "Hello \\o/"; uses = None;
    step_env = None; step_workdir = None; step_shell = None; with_ = None;
    step_if = None; continue_on_err = None; container = None;
    services = None; step_run = Some "echo 'Hello World'"}]
```

Then you can create a new job giving it any name you want by creating a new record type. Note you can generate the `to_yaml` function using [ppx_deriving_yaml](https://github.com/patricoferris/ppx_deriving_yaml) or by hand.

```ocaml env=example
# type test = { test : Types.job }
type test = { test : Types.job; }
# let test_to_yaml t : Yaml.value = `O [ ("test", Types.job_to_yaml t.test) ]
val test_to_yaml : test -> Yaml.value = <fun>
```

You are now ready to combine everything into a new workflow.

```ocaml env=example
# let () = 
  let name = "A `Hello World' Workflow" in 
  let test_job =
    {
      test =
        job "ubuntu-latest"
        |> with_steps steps;
    }
  in
  let on = simple_event [ "push"; "pull_request" ] in
  let w : test Types.t = t test_job |> with_name name |> with_on on in
  Pp.workflow ~drop_null:true test_to_yaml Format.std_formatter w;
name: A `Hello World' Workflow
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Hello \o/
      run: echo 'Hello World'
```

## Plugin Help 

```sh
$ opam github-workflow --help=plain
NAME
       opam-github-workflow - Opam Github Workflows

SYNOPSIS
       opam-github-workflow COMMAND ...

COMMANDS
       changes
           Output a git based check for changelog updates

       test
           Output a standard opam and dune testing workflow

OPTIONS
       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of `auto',
           `pager', `groff' or `plain'. With `auto', the format is `pager` or
           `plain' whenever the TERM env var is `dumb' or undefined.

```
