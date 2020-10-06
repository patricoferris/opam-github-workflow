Building a test workflow with no opam file prints error

  $ opam github-workflow test
  No Opam files found in the current directory
  [255]

Source a project and try building a test workflow

  $ opam source yaml > /dev/null && cd yaml.2.1.0 && opam github-workflow test 
  Successfully created test workflow in ./.github/workflows
  $ cat .github/workflows/test.yml
  name: Tests for yaml
  on: [push, pull_request]
  jobs:
    test:
      strategy:
        matrix:
          operating-system: [macos-latest, ubuntu-latest, windows-latest]
          ocaml-version: [4.11.0, 4.10.0, 4.09.1]
      runs-on: ${{ matrix.operating-system }}
      steps:
      - uses: actions/checkout@v2
      - uses: avsm/setup-ocaml@v1.1.2
      - name: Pinning Package
        run: opam pin add yaml.dev -n .
      - name: Packages
        run: opam depext -yt yaml
      - name: Dependencies
        run: opam install -t . --deps-only
      - name: Building
        run: opam exec -- dune build
      - name: Testing
        run: opam exec -- dune runtest

Passing stdout should print the workflow to standard out 

  $ opam github-workflow test --stdout
  name: Tests for yaml
  on: [push, pull_request]
  jobs:
    test:
      strategy:
        matrix:
          operating-system: [macos-latest, ubuntu-latest, windows-latest]
          ocaml-version: [4.11.0, 4.10.0, 4.09.1]
      runs-on: ${{ matrix.operating-system }}
      steps:
      - uses: actions/checkout@v2
      - uses: avsm/setup-ocaml@v1.1.2
      - name: Pinning Package
        run: opam pin add yaml.dev -n .
      - name: Packages
        run: opam depext -yt yaml
      - name: Dependencies
        run: opam install -t . --deps-only
      - name: Building
        run: opam exec -- dune build
      - name: Testing
        run: opam exec -- dune runtest

