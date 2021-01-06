opam-github-workflow
--------------------

🚧 WIP: Under Construction 🚧

An opam plugin and library for building Github Action workflows in OCaml. For the plugin to work your project must use **opam and dune**.

## Plugin Usage 

We're still working out the kinks so you need to pin it!

```
$ opam pin add --yes git+https://github.com/patricoferris/opam-github-workflow
$ cd <my-cool-project>
$ opam github-workflow test
```

### OCaml-CI Behaviour 

[OCaml-CI](https://github.com/ocurrent/ocaml-ci) is an OCurrent-powered CI pipeline for OCaml projects. If you can add yourself to that CI I would highly recommend it. Otherwise, you can make Github do the work for you by using the `opam github-workflow ci` command. This generates a similar workflow to what happens in OCaml-CI using docker images for the Linux distributions and the Github runners for MacOS and Windows. 

The command takes a little time to run as it tries (like OCaml-CI) to be reproducible by: 

  - Getting the latest *sha256* hash of the docker container 
  - Getting the latest commit hash of the opam-repository 

That means running this command twice may produce different results. A nice workflow is to add a `dune` file at the root of your project with the following contents: 

```
(dirs :standard .github)

(rule
 (with-stdout-to
  data.out
  (run opam github-workflow ci)))

(rule
 (alias ci)
 (action
  (diff ./.github/workflows/test.yml data.out)))
```

This allows you to run `dune build @ci` which will run the command and suggest changes to your workflow file for you. If you like the changes then you run `dune promote`. By default dune ignore files and directories that start with `.` and `_` hence the `(dirs :standard .github)`.

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
    step_run = Some "echo 'Hello World'"; step_env = None;
    step_workdir = None; step_shell = None; with_ = None; step_if = None;
    continue_on_err = None}]
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

See `tests/bin/run.t` for the help page of the plugin tool.

