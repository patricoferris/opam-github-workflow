module OV = Ocaml_version

let oses = [ "macos-latest"; "ubuntu-latest"; "windows-latest" ]

let ocaml_versions n =
  let rec take m acc = function
    | [] -> List.rev acc
    | _ when m <= 0 -> List.rev acc
    | x :: xs -> take (m - 1) (x :: acc) xs
  in
  take n [] (List.rev OV.Releases.recent) |> List.map OV.to_string

let setup_ocaml = "ocaml/setup-ocaml@v2"

let checkout = "actions/checkout@v2"

let output_dir = "./.github/workflows"
