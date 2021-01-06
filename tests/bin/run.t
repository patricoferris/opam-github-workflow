Building a test workflow with no opam file prints error

  $ opam github-workflow test
  No Opam files found in the current directory

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
      - name: Building
        run: opam exec -- dune build
      - name: Installing
        run: opam exec -- dune install
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
      - name: Building
        run: opam exec -- dune build
      - name: Installing
        run: opam exec -- dune install
      - name: Testing
        run: opam exec -- dune runtest

Using a different number of 'recent version'

  $ opam github-workflow test --recent=5 --stdout
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
      - name: Building
        run: opam exec -- dune build
      - name: Installing
        run: opam exec -- dune install
      - name: Testing
        run: opam exec -- dune runtest
