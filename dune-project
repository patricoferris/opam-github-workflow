(lang dune 2.7)

(cram enable)

(name github-workflow)

(generate_opam_files true)

(source
 (github patricoferris/opam-github-workflow))

(license ISC)

(authors "Patrick Ferris")

(maintainers "pf341@patricoferris.com")

(package
 (name opam-github-workflow)
 (synopsis "Plugin to add standard Github Action workflows")
 (description
   "This opam plugin allows you to generate standard github workflows for things like checking changelogs and running tests")
 (depends
  bos
  cmdliner
  opam-format
  opam-state
  github-workflow
  ocaml-version
  (alcotest :with-test)
  (mdx :with-test)))

(package
 (name github-workflow)
 (synopsis "Build Github Workflows in OCaml")
 (description "A library for building Github Action workflows")
 (depends
  yaml
  ppx_deriving_yaml
  (alcotest :with-test)))

(using mdx 0.1)
