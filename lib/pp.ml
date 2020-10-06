open Types

let job ppf j = Yaml.pp ppf (job_to_yaml j)

(* Code within to_string taken from https://github.com/avsm/ocaml-yaml/blob/master/lib/yaml.ml#L65 and modified  *)
let to_string ?len ?(encoding = `Utf8) ?scalar_style ?layout_style
    (v : Yaml.value) =
  let open Yaml in
  let open Rresult in
  let scalar ?anchor ?tag ?(plain_implicit = true) ?(quoted_implicit = false)
      ?(style = `Plain) value =
    { anchor; tag; plain_implicit; quoted_implicit; style; value }
  in
  let all_short =
    List.for_all (function
      | `String _ -> true
      | `Float _ -> true
      | `Bool _ -> true
      | _ -> false)
  in
  Stream.emitter ?len () >>= fun t ->
  Stream.stream_start t encoding >>= fun () ->
  Stream.document_start t >>= fun () ->
  let rec iter = function
    | `Null -> Stream.scalar (scalar "") t
    | `String s -> Stream.scalar (scalar ?style:scalar_style s) t
    | `Float s -> Stream.scalar (scalar (Printf.sprintf "%.16g" s)) t
    (* NOTE: Printf format on the line above taken from the jsonm library *)
    | `Bool s -> Stream.scalar (scalar (string_of_bool s)) t
    | `A l ->
        let style =
          if List.length l <= 5 && all_short l then Some `Flow else layout_style
        in
        Stream.sequence_start ?style t >>= fun () ->
        let rec fn = function
          | [] -> Stream.sequence_end t
          | hd :: tl -> iter hd >>= fun () -> fn tl
        in
        fn l
    | `O l ->
        Stream.mapping_start ?style:layout_style t >>= fun () ->
        let rec fn = function
          | [] -> Stream.mapping_end t
          | (k, v) :: tl ->
              iter (`String k) >>= fun () ->
              iter v >>= fun () -> fn tl
        in
        fn l
  in
  iter v >>= fun () ->
  Stream.document_end t >>= fun () ->
  Stream.stream_end t >>= fun () ->
  let r = Stream.emitter_buf t in
  Ok (Bytes.to_string r)

let no_nulls ppf s =
  let rec remove : Yaml.value -> Yaml.value =
   fun s ->
    match s with
    | `O a ->
        let no_null = List.filter (fun (_, v) -> v <> `Null) a in
        `O (List.map (fun (s, v) -> (s, remove v)) no_null)
    | `A a ->
        let no_null = List.filter (fun v -> v <> `Null) a in
        `A (List.map (fun v -> remove v) no_null)
    | e -> e
  in
  match to_string (remove s) with
  | Ok s -> Format.pp_print_string ppf s
  | Error (`Msg m) ->
      Format.pp_print_string ppf (Printf.sprintf "(error (%s))" m)

let workflow ?(drop_null = false) yaml ppf v =
  let pp = if drop_null then no_nulls else Yaml.pp in
  pp ppf (to_yaml yaml v)
