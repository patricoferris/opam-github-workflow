Building a test workflow with no opam file prints error

  $ opam github-workflow test
  Fatal error: exception Dune__exe__Test.NoOpamFiles
  [2]

Source a project and try building a test workflow

  $ opam source yaml > /dev/null && cd yaml.2.1.0 && opam github-workflow test 
  name: Tests for yaml
  on: [push, pull_request]
  jobs:
    test:
      strategy:
        matrix:
          operating-system: [macos-latest, ubuntu-latest, windows-latest]
          ocaml-version: [4.11.1, 4.10.2, 4.09.1]
      runs-on: ${{ matrix.operating-system }}
      steps:
      - uses: actions/checkout@v2
      - uses: avsm/setup-ocaml@v1
        with:
          ocaml-version: ${{ matrix.ocaml-version }}
      - name: Pinning Package
        run: opam pin add -yn yaml.dev './'
      - name: Packages
        run: opam depext -yt yaml.dev
      - name: Dependencies
        run: opam install -t -y . --deps-only
      - name: Building, Installing and Testing
        run: opam exec -- dune build @install @runtest

Using a different number of 'recent version'

  $ opam github-workflow test --recent=5
  name: Tests for yaml
  on: [push, pull_request]
  jobs:
    test:
      strategy:
        matrix:
          operating-system: [macos-latest, ubuntu-latest, windows-latest]
          ocaml-version: [4.11.1, 4.10.2, 4.09.1, 4.08.1, 4.07.1]
      runs-on: ${{ matrix.operating-system }}
      steps:
      - uses: actions/checkout@v2
      - uses: avsm/setup-ocaml@v1
        with:
          ocaml-version: ${{ matrix.ocaml-version }}
      - name: Pinning Package
        run: opam pin add -yn yaml.dev './'
      - name: Packages
        run: opam depext -yt yaml.dev
      - name: Dependencies
        run: opam install -t -y . --deps-only
      - name: Building, Installing and Testing
        run: opam exec -- dune build @install @runtest

Help page of the plugin 

  $ opam github-workflow --help=plain
  NAME
         opam-github-workflow - Opam Github Workflows
  
  SYNOPSIS
         opam-github-workflow COMMAND ...
  
  COMMANDS
         changes
             Output a git based check for changelog updates
  
         ci  Generate a full OCaml-CI like workflow file for the latest version
             of OCaml. This includes Debian 10 (Buster), Alpine 3.12, Ubuntu
             20.04, Ubuntu 18.04, OpenSUSE 15.2 (Leap), CentOS 8, Fedora 32,
             Macos and Windows
  
         test
             Output a standard opam and dune testing workflow
  
  OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of `auto',
             `pager', `groff' or `plain'. With `auto', the format is `pager` or
             `plain' whenever the TERM env var is `dumb' or undefined.
  
