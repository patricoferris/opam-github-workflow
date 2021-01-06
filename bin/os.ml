open Lwt.Infix

let exec ?cwd ?stdin ?stdout ?stderr argv =
  Lwt_process.exec ?cwd ?stdin ?stdout ?stderr ("", Array.of_list argv)
  >>= function
  | Unix.WEXITED 0 -> Lwt.return_unit
  | Unix.WEXITED n -> Lwt.fail_with (Fmt.strf "failed with exit code %i" n)
  | _ -> Lwt.fail (Failure "Exec failed")

let read ?cwd argv =
  let r, w = Lwt_unix.pipe_in () in
  let f r w =
    (* FD_move closes fd *)
    let proc = exec ?cwd ~stdout:(`FD_move w) argv in
    let r = Lwt_io.(of_fd ~mode:input) r in
    Lwt.finalize (fun () -> Lwt_io.read r) (fun () -> Lwt_io.close r)
    >>= fun data ->
    proc >>= fun () -> Lwt.return data
  in
  Lwt.finalize
    (fun () ->
      Lwt_unix.set_close_on_exec r;
      f r w)
    (fun () -> Lwt.return ())
