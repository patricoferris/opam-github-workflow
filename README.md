opam-github-workflow
--------------------

🚧 WIP: Under Construction 🚧

An opam plugin and library for building Github Action workflows in OCaml. Your project must use **opam and dune** for this to work.

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
