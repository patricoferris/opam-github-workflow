let oses = [ "macos-latest"; "ubuntu-latest"; "windows-latest" ]

let ocaml_versions = [ "4.11.0"; "4.10.0"; "4.09.1" ]

let setup_ocaml = "avsm/setup-ocaml@v1.1.2"

let checkout = "actions/checkout@v2"

let output_dir = Fpath.v "./.github/workflows"
