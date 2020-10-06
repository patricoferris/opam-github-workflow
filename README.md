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

To do this nicely, each type comes with some functions prefixed with `with_` allowing you to right them in a combinator fashion. For example: 

```ocaml
# #require "github-workflow"
# open Workflow
# step
  |> with_step_name "Pinning Package"
  |> with_step_run "opam pin add -n -y .";
- : Types.step =
{Workflow__.Types.step_name = Some "Pinning Package"; uses = None;
 step_env = None; step_workdir = None; step_shell = None; with_ = None;
 step_if = None; continue_on_err = None; container = None; services = None;
 step_run = Some "opam pin add -n -y ."}
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
